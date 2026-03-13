import { Injectable } from '@nestjs/common';
import {
  GroupRuleFrequency,
  JoinRequestStatus,
  MemberStatus,
} from '@prisma/client';

import { PARTICIPATING_MEMBER_STATUSES } from '../../common/membership/member-status.util';
import { PrismaService } from '../../common/prisma/prisma.service';
import { REPUTATION_BASELINE_SCORE } from '../reputation/reputation.constants';
import { DiscoverRankingService } from './discover-ranking.service';
import { DISCOVER_LIMITS } from './discover.constants';

@Injectable()
export class DiscoverMetricsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly discoverRankingService: DiscoverRankingService,
  ) {}

  async ensureMetricsForGroups(groupIds: string[]): Promise<void> {
    const uniqueGroupIds = [...new Set(groupIds.filter(Boolean))];
    if (uniqueGroupIds.length === 0) {
      return;
    }

    const existingMetrics = await (
      this.prisma as any
    ).equbDiscoverMetrics.findMany({
      where: {
        equbId: {
          in: uniqueGroupIds,
        },
      },
      select: {
        equbId: true,
        updatedAt: true,
      },
    });

    const now = Date.now();
    const staleGroupIds = uniqueGroupIds.filter((groupId) => {
      const existing = existingMetrics.find((item) => item.equbId === groupId);
      if (!existing) {
        return true;
      }

      return (
        now - existing.updatedAt.getTime() >=
        DISCOVER_LIMITS.metricsStaleAfterMs
      );
    });

    if (staleGroupIds.length === 0) {
      return;
    }

    await this.refreshMetricsForGroups(staleGroupIds);
  }

  async refreshMetricsForGroups(groupIds: string[]): Promise<void> {
    const uniqueGroupIds = [...new Set(groupIds.filter(Boolean))];
    if (uniqueGroupIds.length === 0) {
      return;
    }

    const groups = await this.prisma.equbGroup.findMany({
      where: {
        id: {
          in: uniqueGroupIds,
        },
      },
      select: {
        id: true,
        createdAt: true,
        createdByUserId: true,
        hostTier: true,
        contributionAmount: true,
        visibility: true,
        status: true,
        createdByUser: {
          select: {
            fullName: true,
            phone: true,
            reputationMetrics: {
              select: {
                trustScore: true,
                trustLevel: true,
                equbsHosted: true,
                hostedEqubsCompleted: true,
                cancelledGroupsCount: true,
                hostDisputesCount: true,
              },
            },
          },
        },
        rules: {
          select: {
            contributionAmount: true,
            frequency: true,
            customIntervalDays: true,
            roundSize: true,
          },
        },
        members: {
          where: {
            status: {
              in: PARTICIPATING_MEMBER_STATUSES,
            },
          },
          select: {
            status: true,
            joinedAt: true,
            user: {
              select: {
                reputationMetrics: {
                  select: {
                    trustScore: true,
                  },
                },
              },
            },
          },
        },
        joinRequests: {
          where: {
            status: {
              equals: JoinRequestStatus.REQUESTED,
            },
          },
          select: {
            createdAt: true,
          },
        },
        cycles: {
          select: {
            createdAt: true,
          },
          orderBy: {
            createdAt: 'desc',
          },
          take: 1,
        },
      },
    });

    await Promise.all(
      groups.map(async (group) => {
        const hostMetrics = group.createdByUser.reputationMetrics;
        const hostTrustScore =
          hostMetrics?.trustScore ?? REPUTATION_BASELINE_SCORE;
        const memberScores = group.members.map(
          (member) =>
            member.user.reputationMetrics?.trustScore ??
            REPUTATION_BASELINE_SCORE,
        );
        const avgMemberScore =
          memberScores.length > 0
            ? Math.round(
                memberScores.reduce((sum, score) => sum + score, 0) /
                  memberScores.length,
              )
            : REPUTATION_BASELINE_SCORE;
        const verifiedMembersCount = group.members.filter(
          (member) => member.status === MemberStatus.VERIFIED,
        ).length;
        const verifiedMembersPercent =
          group.members.length > 0
            ? Math.round((verifiedMembersCount / group.members.length) * 100)
            : 0;
        const groupTrustLevel = this.resolveGroupTrustLevel(
          hostTrustScore,
          avgMemberScore,
          verifiedMembersPercent,
        );
        const contributionAmount =
          group.rules?.contributionAmount ?? group.contributionAmount;
        const maxMembers = group.rules?.roundSize ?? 0;
        const joinedCount = group.members.length;
        const fillPercent =
          maxMembers > 0
            ? Math.min(100, Math.round((joinedCount / maxMembers) * 100))
            : 0;

        const now = new Date();
        const dayAgo = new Date(now.getTime() - 24 * 60 * 60 * 1000);
        const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        const joinVelocity24h = group.members.filter(
          (member) => member.joinedAt != null && member.joinedAt >= dayAgo,
        ).length;
        const joinVelocity7d = group.members.filter(
          (member) => member.joinedAt != null && member.joinedAt >= weekAgo,
        ).length;
        const lastMemberJoinAt = group.members
          .map((member) => member.joinedAt)
          .filter((value): value is Date => value != null)
          .sort((left, right) => right.getTime() - left.getTime())[0];
        const lastJoinRequestAt = group.joinRequests
          .map((request) => request.createdAt)
          .sort((left, right) => right.getTime() - left.getTime())[0];
        const lastCycleActivityAt = group.cycles[0]?.createdAt ?? null;
        const lastActivityAt = [
          group.createdAt,
          lastMemberJoinAt,
          lastJoinRequestAt,
          lastCycleActivityAt,
        ]
          .filter((value): value is Date => value != null)
          .sort((left, right) => right.getTime() - left.getTime())[0];
        const freshnessScore = this.discoverRankingService.buildFreshnessScore(
          group.createdAt,
          lastActivityAt,
          now,
        );
        const hostCompletionRate =
          hostMetrics != null && hostMetrics.equbsHosted > 0
            ? Math.round(
                (hostMetrics.hostedEqubsCompleted / hostMetrics.equbsHosted) *
                  100,
              )
            : REPUTATION_BASELINE_SCORE;
        const discoverScore = this.discoverRankingService.buildDiscoverScore({
          equbId: group.id,
          hostTrustScore,
          hostTrustLevel: hostMetrics?.trustLevel ?? 'New',
          avgMemberScore,
          groupTrustLevel,
          joinedCount,
          maxMembers,
          fillPercent,
          pendingRequestCount: group.joinRequests.length,
          waitlistCount: 0,
          joinVelocity24h,
          joinVelocity7d,
          hostCompletionRate,
          freshnessScore,
          createdAt: group.createdAt,
          lastActivityAt,
          hostCancelledGroupsCount: hostMetrics?.cancelledGroupsCount ?? 0,
          hostDisputesCount: hostMetrics?.hostDisputesCount ?? 0,
          contributionAmount,
          durationDays: this.resolveDurationDays(group.rules),
          hostTier: group.hostTier ?? null,
        });

        await (this.prisma as any).equbDiscoverMetrics.upsert({
          where: {
            equbId: group.id,
          },
          create: {
            equbId: group.id,
            hostUserId: group.createdByUserId,
            hostTrustScore,
            hostTrustLevel: hostMetrics?.trustLevel ?? 'New',
            avgMemberScore,
            groupTrustLevel,
            verifiedMembersPercent,
            joinedCount,
            maxMembers,
            fillPercent,
            pendingRequestCount: group.joinRequests.length,
            waitlistCount: 0,
            joinVelocity24h,
            joinVelocity7d,
            hostCompletionRate,
            freshnessScore,
            discoverScore,
            createdAt: group.createdAt,
            lastActivityAt,
          },
          update: {
            hostUserId: group.createdByUserId,
            hostTrustScore,
            hostTrustLevel: hostMetrics?.trustLevel ?? 'New',
            avgMemberScore,
            groupTrustLevel,
            verifiedMembersPercent,
            joinedCount,
            maxMembers,
            fillPercent,
            pendingRequestCount: group.joinRequests.length,
            waitlistCount: 0,
            joinVelocity24h,
            joinVelocity7d,
            hostCompletionRate,
            freshnessScore,
            discoverScore,
            createdAt: group.createdAt,
            lastActivityAt,
          },
        });
      }),
    );
  }

  private resolveGroupTrustLevel(
    hostTrustScore: number,
    averageMemberScore: number,
    verifiedMembersPercent: number,
  ): string {
    if (
      hostTrustScore >= 90 &&
      averageMemberScore >= 80 &&
      verifiedMembersPercent >= 75
    ) {
      return 'High';
    }

    if (hostTrustScore >= 75 && averageMemberScore >= 65) {
      return 'Medium';
    }

    return 'Low';
  }

  private resolveDurationDays(
    rules: {
      frequency: GroupRuleFrequency;
      customIntervalDays: number | null;
    } | null,
  ): number {
    if (!rules) {
      return 0;
    }

    if (rules.frequency === 'CUSTOM_INTERVAL') {
      return rules.customIntervalDays ?? 0;
    }

    if (rules.frequency === 'WEEKLY') {
      return 7;
    }

    return 30;
  }
}
