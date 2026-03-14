import { Injectable } from '@nestjs/common';
import {
  GroupRuleFrequency,
  GroupRulePayoutMode,
  GroupStatus,
  GroupVisibility,
  JoinRequestStatus,
  StartPolicy,
  WinnerSelectionTiming,
} from '@prisma/client';

import { PARTICIPATING_MEMBER_STATUSES } from '../../common/membership/member-status.util';
import { PrismaService } from '../../common/prisma/prisma.service';
import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import { ReputationService } from '../reputation/reputation.service';
import {
  GroupTrustSummaryDto,
  HostReputationSummaryDto,
} from '../reputation/entities/reputation.entities';
import {
  DISCOVER_HIGH_VALUE_CONTRIBUTION_AMOUNT,
  DISCOVER_LIMITS,
  DISCOVER_SECTION_KEYS,
  DISCOVER_SECTION_TITLES,
} from './discover.constants';
import { ListDiscoverGroupsDto } from './dto/list-discover-groups.dto';
import { DiscoverMetricsService } from './discover-metrics.service';
import {
  DiscoverRankingService,
  type DiscoverMetricsSnapshot,
  type DiscoverUserPreferenceProfile,
} from './discover-ranking.service';
import {
  DiscoverGroupItemResponseDto,
  DiscoverGroupSectionResponseDto,
  DiscoverGroupsResponseDto,
} from './entities/groups.entities';

type DiscoverCandidateRecord = {
  id: string;
  name: string;
  description: string | null;
  currency: string;
  contributionAmount: number;
  frequency: GroupRuleFrequency;
  hostTier: string | null;
  hostReputationAtCreation: number | null;
  createdAt: Date;
  createdByUserId: string;
  createdByUser: {
    fullName: string | null;
    phone: string;
    reputationMetrics: {
      trustScore: number;
      trustLevel: string;
      equbsCompleted: number;
      equbsHosted: number;
      hostedEqubsCompleted: number;
      turnsParticipated: number;
      cancelledGroupsCount: number;
      hostDisputesCount: number;
    } | null;
  };
  rules: {
    contributionAmount: number;
    frequency: GroupRuleFrequency;
    customIntervalDays: number | null;
    payoutMode: GroupRulePayoutMode;
    roundSize: number;
    startPolicy: StartPolicy;
    startAt: Date | null;
    minToStart: number | null;
    winnerSelectionTiming: WinnerSelectionTiming;
  };
  discoverMetrics: {
    hostTrustScore: number;
    hostTrustLevel: string;
    avgMemberScore: number;
    groupTrustLevel: string;
    verifiedMembersPercent: number;
    joinedCount: number;
    maxMembers: number;
    fillPercent: number;
    pendingRequestCount: number;
    waitlistCount: number;
    joinVelocity24h: number;
    joinVelocity7d: number;
    hostCompletionRate: number;
    freshnessScore: number;
    discoverScore: number;
    createdAt: Date;
    lastActivityAt: Date;
  } | null;
};

@Injectable()
export class GroupsDiscoverService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly discoverMetricsService: DiscoverMetricsService,
    private readonly discoverRankingService: DiscoverRankingService,
    private readonly reputationService: ReputationService,
  ) {}

  async listDiscoverSections(
    currentUser: AuthenticatedUser,
    query: ListDiscoverGroupsDto,
  ): Promise<DiscoverGroupsResponseDto> {
    const [profile, eligibility, candidateIds] = await Promise.all([
      this.buildUserPreferenceProfile(currentUser.id),
      this.reputationService.getEligibility(currentUser.id),
      this.listCandidateGroupIds(currentUser.id, query),
    ]);

    await this.discoverMetricsService.ensureMetricsForGroups(candidateIds);

    const candidates = (await this.prisma.equbGroup.findMany({
      where: {
        id: {
          in: candidateIds,
        },
      },
      select: {
        id: true,
        name: true,
        description: true,
        currency: true,
        contributionAmount: true,
        createdAt: true,
        hostTier: true,
        hostReputationAtCreation: true,
        createdByUserId: true,
        createdByUser: {
          select: {
            fullName: true,
            phone: true,
            reputationMetrics: {
              select: {
                trustScore: true,
                trustLevel: true,
                equbsCompleted: true,
                equbsHosted: true,
                hostedEqubsCompleted: true,
                turnsParticipated: true,
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
            payoutMode: true,
            roundSize: true,
            startPolicy: true,
            startAt: true,
            minToStart: true,
            winnerSelectionTiming: true,
          },
        },
        discoverMetrics: {
          select: {
            hostTrustScore: true,
            hostTrustLevel: true,
            avgMemberScore: true,
            groupTrustLevel: true,
            verifiedMembersPercent: true,
            joinedCount: true,
            maxMembers: true,
            fillPercent: true,
            pendingRequestCount: true,
            waitlistCount: true,
            joinVelocity24h: true,
            joinVelocity7d: true,
            hostCompletionRate: true,
            freshnessScore: true,
            discoverScore: true,
            createdAt: true,
            lastActivityAt: true,
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    } as any)) as unknown as DiscoverCandidateRecord[];

    const eligibleCandidates = candidates
      .filter(
        (
          candidate,
        ): candidate is DiscoverCandidateRecord & {
          discoverMetrics: NonNullable<
            DiscoverCandidateRecord['discoverMetrics']
          >;
        } => candidate.rules != null && candidate.discoverMetrics != null,
      )
      .filter(
        (candidate) =>
          candidate.discoverMetrics.joinedCount < candidate.rules.roundSize,
      )
      .filter(
        (candidate) =>
          eligibility.canJoinHighValuePublicGroup ||
          candidate.rules.contributionAmount <
            DISCOVER_HIGH_VALUE_CONTRIBUTION_AMOUNT,
      );

    const scored = eligibleCandidates.map((candidate) => {
      const metrics = this.toMetricsSnapshot(candidate);
      const breakdown = this.discoverRankingService.buildScoreBreakdown(
        metrics,
        profile,
      );

      return {
        candidate,
        metrics,
        breakdown,
      };
    });

    const sectionLimit = Math.min(
      query.sectionLimit ?? DISCOVER_LIMITS.defaultSectionLimit,
      DISCOVER_LIMITS.maxSectionLimit,
    );

    const sections: DiscoverGroupSectionResponseDto[] = [
      this.buildSection(
        DISCOVER_SECTION_KEYS.recommended,
        scored,
        sectionLimit,
        (item) =>
          item.breakdown.sectionScores[DISCOVER_SECTION_KEYS.recommended],
        () => true,
      ),
      this.buildSection(
        DISCOVER_SECTION_KEYS.fillingFast,
        scored,
        sectionLimit,
        (item) =>
          item.breakdown.sectionScores[DISCOVER_SECTION_KEYS.fillingFast],
        (item) => this.discoverRankingService.isFillingFast(item.metrics),
      ),
      this.buildSection(
        DISCOVER_SECTION_KEYS.trustedHosts,
        scored,
        sectionLimit,
        (item) =>
          item.breakdown.sectionScores[DISCOVER_SECTION_KEYS.trustedHosts],
        (item) => this.discoverRankingService.isTrustedHost(item.metrics),
      ),
      this.buildSection(
        DISCOVER_SECTION_KEYS.newEqubs,
        scored,
        sectionLimit,
        (item) => item.breakdown.sectionScores[DISCOVER_SECTION_KEYS.newEqubs],
        (item) => this.discoverRankingService.isNewEqub(item.metrics),
      ),
      this.buildSection(
        DISCOVER_SECTION_KEYS.starterEqubs,
        scored,
        sectionLimit,
        (item) =>
          item.breakdown.sectionScores[DISCOVER_SECTION_KEYS.starterEqubs],
        (item) => this.discoverRankingService.isStarterEqub(item.metrics),
      ),
    ].filter((section) => section.items.length > 0);

    return {
      sections,
    };
  }

  async refreshGroupMetrics(groupId: string): Promise<void> {
    await this.discoverMetricsService.refreshMetricsForGroups([groupId]);
  }

  private async listCandidateGroupIds(
    userId: string,
    query: ListDiscoverGroupsDto,
  ): Promise<string[]> {
    const groups = await this.prisma.equbGroup.findMany({
      where: {
        visibility: GroupVisibility.PUBLIC,
        status: GroupStatus.ACTIVE,
        createdByUserId: {
          not: userId,
        },
        rules: {
          is: {
            ...(query.frequency ? { frequency: query.frequency } : {}),
            ...(query.groupSizeMin != null || query.groupSizeMax != null
              ? {
                  roundSize: {
                    ...(query.groupSizeMin != null
                      ? { gte: query.groupSizeMin }
                      : {}),
                    ...(query.groupSizeMax != null
                      ? { lte: query.groupSizeMax }
                      : {}),
                  },
                }
              : {}),
            ...(query.contributionMin != null || query.contributionMax != null
              ? {
                  contributionAmount: {
                    ...(query.contributionMin != null
                      ? { gte: query.contributionMin }
                      : {}),
                    ...(query.contributionMax != null
                      ? { lte: query.contributionMax }
                      : {}),
                  },
                }
              : {}),
            ...(query.durationMin != null || query.durationMax != null
              ? {
                  OR: this.buildDurationFilter(
                    query.durationMin,
                    query.durationMax,
                  ),
                }
              : {}),
          },
        },
        cycles: {
          none: {},
        },
        members: {
          none: {
            userId,
            status: {
              in: PARTICIPATING_MEMBER_STATUSES,
            },
          },
        },
        joinRequests: {
          none: {
            userId,
            status: {
              in: [JoinRequestStatus.REQUESTED, JoinRequestStatus.APPROVED],
            },
          },
        },
        ...(query.hostTier
          ? {
              hostTier: query.hostTier,
            }
          : {}),
      },
      select: {
        id: true,
      },
    });

    if (groups.length === 0) {
      return [];
    }

    if (!query.trustLevel) {
      return groups.map((group) => group.id);
    }

    await this.discoverMetricsService.ensureMetricsForGroups(
      groups.map((group) => group.id),
    );

    const normalizedTrustLevel = query.trustLevel.toLowerCase();
    const metrics = await (this.prisma as any).equbDiscoverMetrics.findMany({
      where: {
        equbId: {
          in: groups.map((group) => group.id),
        },
        hostTrustLevel: {
          equals: normalizedTrustLevel,
          mode: 'insensitive',
        },
      },
      select: {
        equbId: true,
      },
    });

    return metrics.map((item) => item.equbId);
  }

  private buildDurationFilter(durationMin?: number, durationMax?: number) {
    const filters: Array<Record<string, unknown>> = [];
    const weeklyAllowed =
      (durationMin == null || durationMin <= 7) &&
      (durationMax == null || durationMax >= 7);
    const monthlyAllowed =
      (durationMin == null || durationMin <= 30) &&
      (durationMax == null || durationMax >= 30);

    if (weeklyAllowed) {
      filters.push({ frequency: GroupRuleFrequency.WEEKLY });
    }
    if (monthlyAllowed) {
      filters.push({ frequency: GroupRuleFrequency.MONTHLY });
    }
    filters.push({
      frequency: GroupRuleFrequency.CUSTOM_INTERVAL,
      customIntervalDays: {
        ...(durationMin != null ? { gte: durationMin } : {}),
        ...(durationMax != null ? { lte: durationMax } : {}),
      },
    });

    return filters;
  }

  private buildSection(
    key: string,
    scored: Array<{
      candidate: DiscoverCandidateRecord;
      metrics: DiscoverMetricsSnapshot;
      breakdown: ReturnType<DiscoverRankingService['buildScoreBreakdown']>;
    }>,
    sectionLimit: number,
    scoreSelector: (item: {
      candidate: DiscoverCandidateRecord;
      metrics: DiscoverMetricsSnapshot;
      breakdown: ReturnType<DiscoverRankingService['buildScoreBreakdown']>;
    }) => number,
    predicate: (item: {
      candidate: DiscoverCandidateRecord;
      metrics: DiscoverMetricsSnapshot;
      breakdown: ReturnType<DiscoverRankingService['buildScoreBreakdown']>;
    }) => boolean,
  ): DiscoverGroupSectionResponseDto {
    const items = scored
      .filter(predicate)
      .sort((left, right) => scoreSelector(right) - scoreSelector(left))
      .slice(0, sectionLimit)
      .map((item) =>
        this.toDiscoverGroupItem(item.candidate, item.breakdown.reasonLabels),
      );

    return {
      key,
      title: DISCOVER_SECTION_TITLES[key],
      items,
    };
  }

  private async buildUserPreferenceProfile(
    userId: string,
  ): Promise<DiscoverUserPreferenceProfile> {
    const memberships = await this.prisma.equbMember.findMany({
      where: {
        userId,
        status: {
          in: PARTICIPATING_MEMBER_STATUSES,
        },
      },
      select: {
        group: {
          select: {
            contributionAmount: true,
            rules: {
              select: {
                contributionAmount: true,
                frequency: true,
                customIntervalDays: true,
                roundSize: true,
              },
            },
          },
        },
      },
    });

    if (memberships.length === 0) {
      return null;
    }

    const contributions = memberships.map(
      (membership) =>
        membership.group.rules?.contributionAmount ??
        membership.group.contributionAmount,
    );
    const durations = memberships.map((membership) =>
      this.resolveDurationDays(membership.group.rules),
    );
    const groupSizes = memberships.map(
      (membership) => membership.group.rules?.roundSize ?? 0,
    );

    return {
      averageContribution: Math.round(
        contributions.reduce((sum, value) => sum + value, 0) /
          contributions.length,
      ),
      averageDurationDays: Math.round(
        durations.reduce((sum, value) => sum + value, 0) / durations.length,
      ),
      averageGroupSize: Math.round(
        groupSizes.reduce((sum, value) => sum + value, 0) / groupSizes.length,
      ),
      historyCount: memberships.length,
    };
  }

  private toMetricsSnapshot(
    candidate: DiscoverCandidateRecord,
  ): DiscoverMetricsSnapshot {
    const hostMetrics = candidate.createdByUser.reputationMetrics;
    const metrics = candidate.discoverMetrics!;

    return {
      equbId: candidate.id,
      hostTrustScore: metrics.hostTrustScore,
      hostTrustLevel: metrics.hostTrustLevel,
      avgMemberScore: metrics.avgMemberScore,
      groupTrustLevel: metrics.groupTrustLevel,
      joinedCount: metrics.joinedCount,
      maxMembers: metrics.maxMembers,
      fillPercent: metrics.fillPercent,
      pendingRequestCount: metrics.pendingRequestCount,
      waitlistCount: metrics.waitlistCount,
      joinVelocity24h: metrics.joinVelocity24h,
      joinVelocity7d: metrics.joinVelocity7d,
      hostCompletionRate: metrics.hostCompletionRate,
      freshnessScore: metrics.freshnessScore,
      createdAt: metrics.createdAt,
      lastActivityAt: metrics.lastActivityAt,
      hostCancelledGroupsCount: hostMetrics?.cancelledGroupsCount ?? 0,
      hostDisputesCount: hostMetrics?.hostDisputesCount ?? 0,
      contributionAmount: candidate.rules.contributionAmount,
      durationDays: this.resolveDurationDays(candidate.rules),
      hostTier: candidate.hostTier,
    };
  }

  private toDiscoverGroupItem(
    candidate: DiscoverCandidateRecord,
    reasonLabels: string[],
  ): DiscoverGroupItemResponseDto {
    const hostMetrics = candidate.createdByUser.reputationMetrics;
    const publicPresentation = this.reputationService.getPublicPresentation({
      trustScore: hostMetrics?.trustScore ?? 50,
      equbsCompleted: hostMetrics?.equbsCompleted ?? 0,
      turnsParticipated: hostMetrics?.turnsParticipated ?? 0,
    });
    const host: HostReputationSummaryDto = {
      userId: candidate.createdByUserId,
      trustScore: hostMetrics?.trustScore ?? 50,
      trustLevel: hostMetrics?.trustLevel ?? 'New',
      summaryLabel: publicPresentation.displayLabel,
      level: publicPresentation.level,
      icon: publicPresentation.icon,
      displayLabel: publicPresentation.displayLabel,
      hostTitle: publicPresentation.hostTitle,
      equbsHosted: hostMetrics?.equbsHosted ?? 0,
      hostedEqubsCompleted: hostMetrics?.hostedEqubsCompleted ?? 0,
      turnsParticipated: hostMetrics?.turnsParticipated ?? 0,
      hostedCompletionRate:
        hostMetrics != null && hostMetrics.equbsHosted > 0
          ? Math.round(
              (hostMetrics.hostedEqubsCompleted / hostMetrics.equbsHosted) *
                100,
            )
          : null,
      cancelledGroupsCount: hostMetrics?.cancelledGroupsCount ?? 0,
      hostDisputesCount: hostMetrics?.hostDisputesCount ?? 0,
    };
    const trustSummary: GroupTrustSummaryDto = {
      groupId: candidate.id,
      hostScore: candidate.discoverMetrics!.hostTrustScore,
      averageMemberScore: candidate.discoverMetrics!.avgMemberScore,
      verifiedMembersPercent: candidate.discoverMetrics!.verifiedMembersPercent,
      groupTrustLevel: candidate.discoverMetrics!.groupTrustLevel,
      host,
    };

    return {
      equbId: candidate.id,
      id: candidate.id,
      name: candidate.name,
      description: candidate.description,
      currency: candidate.currency,
      contributionAmount: candidate.rules.contributionAmount,
      frequency: candidate.rules.frequency,
      payoutMode: candidate.rules.payoutMode,
      memberCount: candidate.discoverMetrics!.joinedCount,
      alreadyStarted: false,
      hostName:
        candidate.createdByUser.fullName ??
        candidate.createdByUser.phone ??
        null,
      hostTier: candidate.hostTier,
      hostReputationAtCreation: candidate.hostReputationAtCreation,
      hostReputationLevel:
        candidate.hostReputationAtCreation != null
          ? this.reputationService.deriveTrustLevel(
              candidate.hostReputationAtCreation,
            )
          : null,
      allowedPublicEqubLimits: null,
      host,
      trustSummary,
      durationDays: this.resolveDurationDays(candidate.rules),
      joinedCount: candidate.discoverMetrics!.joinedCount,
      maxMembers: candidate.rules.roundSize,
      fillPercent: candidate.discoverMetrics!.fillPercent,
      groupTrustLevel: candidate.discoverMetrics!.groupTrustLevel,
      discoverHost: {
        id: candidate.createdByUserId,
        name:
          candidate.createdByUser.fullName ??
          candidate.createdByUser.phone ??
          null,
        trustScore: candidate.discoverMetrics!.hostTrustScore,
        trustLevel: candidate.discoverMetrics!.hostTrustLevel,
        level: publicPresentation.level,
        icon: publicPresentation.icon,
        displayLabel: publicPresentation.displayLabel,
        hostTitle: publicPresentation.hostTitle,
      },
      reasonLabels,
    };
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

    if (rules.frequency === GroupRuleFrequency.CUSTOM_INTERVAL) {
      return rules.customIntervalDays ?? 0;
    }

    if (rules.frequency === GroupRuleFrequency.WEEKLY) {
      return 7;
    }

    return 30;
  }
}
