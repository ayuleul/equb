import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { MemberStatus, Prisma } from '@prisma/client';

import { PrismaService } from '../../common/prisma/prisma.service';
import { ListReputationHistoryDto } from './dto/list-reputation-history.dto';
import {
  GroupTrustSummaryDto,
  HostReputationSummaryDto,
  MemberReliabilitySummaryDto,
  ReputationBadgeDto,
  ReputationEligibilityResponseDto,
  ReputationHistoryResponseDto,
  ReputationProfileResponseDto,
} from './entities/reputation.entities';
import {
  HOST_TIER,
  REPUTATION_ACTIVITY_DECAY_PER_MONTH,
  REPUTATION_ACTIVITY_FACTOR_FLOOR,
  REPUTATION_BASELINE_SCORE,
  REPUTATION_BASE_SCORE_DEFAULT,
  REPUTATION_COMPONENT_WEIGHTS,
  REPUTATION_CONFIDENCE_DENOMINATOR,
  REPUTATION_MIN_PAYMENT_SAMPLE,
  REPUTATION_MONTH_IN_MS,
  REPUTATION_SCORE_MAX,
  REPUTATION_SCORE_MIN,
  REPUTATION_THRESHOLDS,
  type HostTier,
  ReputationEventType,
  TRUST_LEVEL_RANGES,
} from './reputation.constants';

type ReputationMetricKey =
  | 'equbsJoined'
  | 'equbsCompleted'
  | 'equbsLeftEarly'
  | 'equbsHosted'
  | 'hostedEqubsCompleted'
  | 'onTimePayments'
  | 'latePayments'
  | 'missedPayments'
  | 'turnsParticipated'
  | 'payoutsReceived'
  | 'payoutsConfirmed'
  | 'removalsCount'
  | 'disputesCount'
  | 'cancelledGroupsCount'
  | 'hostDisputesCount';

type ReputationMetricsDelta = Partial<Record<ReputationMetricKey, number>>;

type ReputationTx = Prisma.TransactionClient;

type ReputationMetricsRecord = {
  userId: string;
  trustScore: number;
  trustLevel: string;
  paymentScore: number;
  completionScore: number;
  behaviorScore: number;
  experienceScore: number;
  baseScore: number;
  activityFactor: number;
  adjustedScore: number;
  confidenceFactor: number;
  equbsJoined: number;
  equbsCompleted: number;
  equbsLeftEarly: number;
  equbsHosted: number;
  hostedEqubsCompleted: number;
  onTimePayments: number;
  latePayments: number;
  missedPayments: number;
  turnsParticipated: number;
  payoutsReceived: number;
  payoutsConfirmed: number;
  removalsCount: number;
  disputesCount: number;
  cancelledGroupsCount: number;
  hostDisputesCount: number;
  lastEqubActivityAt: Date | null;
  updatedAt: Date;
};

type ReputationSnapshot = {
  paymentScore: number;
  completionScore: number;
  behaviorScore: number;
  experienceScore: number;
  baseScore: number;
  activityFactor: number;
  adjustedScore: number;
  confidenceFactor: number;
  trustScore: number;
  trustLevel: string;
};

export type PublicHostingConstraintInput = {
  maxMembers?: number | null;
  contributionAmount?: number | null;
  durationDays?: number | null;
  activePublicEqubCount?: number | null;
};

export type PublicHostingEligibility = {
  trustScore: number;
  trustLevel: string;
  hostTier: HostTier | null;
  allowedPublicEqubLimits: ReputationEligibilityResponseDto['allowedPublicEqubLimits'];
};

export type ApplyReputationEventInput = {
  userId: string;
  eventType: ReputationEventType;
  metricChanges: ReputationMetricsDelta;
  idempotencyKey: string;
  relatedGroupId?: string | null;
  relatedCycleId?: string | null;
  metadata?: Record<string, unknown> | null;
  activityAt?: Date;
};

@Injectable()
export class ReputationService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly configService: ConfigService,
  ) {}

  async ensureUserMetrics(userId: string): Promise<void> {
    await this.prisma.userReputationMetrics.upsert({
      where: { userId },
      update: {},
      create: this.buildDefaultMetricsCreateInput(userId),
    });
  }

  async applyEvent(
    tx: ReputationTx,
    input: ApplyReputationEventInput,
  ): Promise<void> {
    const existingHistory = await tx.reputationHistory.findUnique({
      where: { idempotencyKey: input.idempotencyKey },
      select: { id: true },
    });
    if (existingHistory) {
      return;
    }

    const activityAt = input.activityAt ?? new Date();
    const current = await this.ensureUserMetricsTx(tx, input.userId);
    const nextMetrics = this.applyMetricDelta(current, input.metricChanges);
    const snapshot = this.calculateSnapshot(nextMetrics, activityAt);
    const scoreDelta = snapshot.trustScore - current.trustScore;

    await tx.userReputationMetrics.update({
      where: { userId: input.userId },
      data: {
        ...this.toMetricIncrementData(input.metricChanges),
        paymentScore: snapshot.paymentScore,
        completionScore: snapshot.completionScore,
        behaviorScore: snapshot.behaviorScore,
        experienceScore: snapshot.experienceScore,
        baseScore: snapshot.baseScore,
        activityFactor: snapshot.activityFactor,
        adjustedScore: snapshot.adjustedScore,
        confidenceFactor: snapshot.confidenceFactor,
        trustScore: snapshot.trustScore,
        trustLevel: snapshot.trustLevel,
        lastEqubActivityAt: activityAt,
      },
    });

    await tx.reputationHistory.create({
      data: {
        userId: input.userId,
        eventType: input.eventType,
        scoreDelta,
        metricChanges: input.metricChanges,
        relatedGroupId: input.relatedGroupId ?? null,
        relatedCycleId: input.relatedCycleId ?? null,
        idempotencyKey: input.idempotencyKey,
        metadata: input.metadata
          ? (input.metadata as Prisma.InputJsonValue)
          : Prisma.JsonNull,
      },
    });
  }

  calculateTrustScore(
    metrics: Pick<
      ReputationMetricsRecord,
      | 'onTimePayments'
      | 'latePayments'
      | 'missedPayments'
      | 'equbsJoined'
      | 'equbsCompleted'
      | 'equbsLeftEarly'
      | 'removalsCount'
      | 'disputesCount'
      | 'hostedEqubsCompleted'
      | 'turnsParticipated'
      | 'lastEqubActivityAt'
    >,
    referenceAt = new Date(),
  ): number {
    return this.calculateSnapshot(
      {
        ...this.buildDefaultMetrics('user'),
        ...metrics,
      },
      referenceAt,
    ).trustScore;
  }

  deriveTrustLevel(score: number): string {
    if (score <= TRUST_LEVEL_RANGES.riskyMax) {
      return 'Risky';
    }
    if (score <= TRUST_LEVEL_RANGES.newMax) {
      return 'New';
    }
    if (score <= TRUST_LEVEL_RANGES.reliableMax) {
      return 'Reliable';
    }
    if (score <= TRUST_LEVEL_RANGES.trustedMax) {
      return 'Trusted';
    }
    return 'Elite';
  }

  deriveSummaryLabel(score: number): string {
    const level = this.deriveTrustLevel(score);
    if (level === 'New') {
      return 'New Member';
    }
    return level;
  }

  async getProfile(userId: string): Promise<ReputationProfileResponseDto> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        createdAt: true,
      },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const metrics = await this.ensureMaterializedMetrics(user.id);
    return this.toProfileResponse(user.id, user.createdAt, metrics);
  }

  async getHistory(
    userId: string,
    query: ListReputationHistoryDto,
  ): Promise<ReputationHistoryResponseDto> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true },
    });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const skip = (page - 1) * limit;

    const [items, total] = await Promise.all([
      this.prisma.reputationHistory.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
      }),
      this.prisma.reputationHistory.count({
        where: { userId },
      }),
    ]);

    return {
      items: items.map((item) => ({
        id: item.id,
        userId: item.userId,
        eventType: item.eventType,
        scoreDelta: item.scoreDelta,
        metricChanges: this.toMetricChangesRecord(item.metricChanges),
        relatedGroupId: item.relatedGroupId,
        relatedCycleId: item.relatedCycleId,
        metadata:
          item.metadata && typeof item.metadata === 'object'
            ? (item.metadata as Record<string, unknown>)
            : null,
        createdAt: item.createdAt,
      })),
      page,
      limit,
      total,
    };
  }

  async getEligibility(
    userId: string,
  ): Promise<ReputationEligibilityResponseDto> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true },
    });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    const metrics = await this.ensureMaterializedMetrics(userId);
    return this.toEligibility(metrics.trustScore);
  }

  async assertCanHostPublicGroup(userId: string): Promise<void> {
    const eligibility = await this.getPublicHostingEligibility(userId);
    if (!eligibility.hostTier) {
      throw new ForbiddenException(
        `A trust score of at least ${REPUTATION_THRESHOLDS.starterPublicHostMinScore} is required to create a public Equb.`,
      );
    }
  }

  async getPublicHostingEligibility(
    userId: string,
  ): Promise<PublicHostingEligibility> {
    const metrics = await this.ensureMaterializedMetrics(userId);
    const hosting = this.resolvePublicHostingEligibilityFromScore(
      metrics.trustScore,
    );

    return {
      trustScore: metrics.trustScore,
      trustLevel: metrics.trustLevel,
      hostTier: hosting.hostTier,
      allowedPublicEqubLimits: hosting.allowedPublicEqubLimits,
    };
  }

  async assertCanCreatePublicEqub(
    userId: string,
    constraints: PublicHostingConstraintInput,
  ): Promise<PublicHostingEligibility> {
    const eligibility = await this.getPublicHostingEligibility(userId);
    if (!eligibility.hostTier) {
      throw new ForbiddenException(
        `A trust score of at least ${REPUTATION_THRESHOLDS.starterPublicHostMinScore} is required to create a public Equb.`,
      );
    }

    const requestsHighValue =
      (constraints.contributionAmount ?? 0) >=
        REPUTATION_THRESHOLDS.highValueContributionAmount ||
      (constraints.maxMembers ?? 0) > REPUTATION_THRESHOLDS.highValueMemberCount;

    if (
      requestsHighValue &&
      eligibility.trustScore < REPUTATION_THRESHOLDS.highValuePublicHostMinScore
    ) {
      throw new ForbiddenException(
        `A trust score of at least ${REPUTATION_THRESHOLDS.highValuePublicHostMinScore} is required to create a high-value public Equb.`,
      );
    }

    if (eligibility.hostTier !== HOST_TIER.starter) {
      return eligibility;
    }

    const limits = eligibility.allowedPublicEqubLimits;
    if (
      limits.maxMembers != null &&
      constraints.maxMembers != null &&
      constraints.maxMembers > limits.maxMembers
    ) {
      throw new ForbiddenException(
        `Your trust score allows only starter public Equbs with up to ${limits.maxMembers} members.`,
      );
    }

    if (
      limits.maxContributionAmount != null &&
      constraints.contributionAmount != null &&
      constraints.contributionAmount > limits.maxContributionAmount
    ) {
      throw new ForbiddenException(
        `Your trust score allows only starter public Equbs with contribution amounts up to ${limits.maxContributionAmount}.`,
      );
    }

    if (
      limits.maxDurationDays != null &&
      constraints.durationDays != null &&
      constraints.durationDays > limits.maxDurationDays
    ) {
      throw new ForbiddenException(
        `Your trust score allows only starter public Equbs with durations up to ${limits.maxDurationDays} days.`,
      );
    }

    if (
      limits.maxActivePublicEqubs != null &&
      (constraints.activePublicEqubCount ?? 0) >= limits.maxActivePublicEqubs
    ) {
      throw new ForbiddenException(
        `Starter hosts may have only ${limits.maxActivePublicEqubs} active public Equb at a time.`,
      );
    }

    return eligibility;
  }

  async assertCanJoinHighValuePublicGroup(
    userId: string,
    contributionAmount: number,
  ): Promise<void> {
    if (contributionAmount < REPUTATION_THRESHOLDS.highValueContributionAmount) {
      return;
    }

    const eligibility = await this.getEligibility(userId);
    if (!eligibility.canJoinHighValuePublicGroup) {
      throw new ForbiddenException(
        `A trust score of at least ${REPUTATION_THRESHOLDS.highValuePublicJoinMinScore} is required to join high-value public Equbs.`,
      );
    }
  }

  async getHostSummary(userId: string): Promise<HostReputationSummaryDto> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        createdAt: true,
      },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const metrics = await this.ensureMaterializedMetrics(user.id);
    return this.toHostSummary(user.id, metrics);
  }

  async getReliabilitySummaries(
    userIds: string[],
  ): Promise<Map<string, MemberReliabilitySummaryDto>> {
    const uniqueUserIds = [...new Set(userIds)];
    if (uniqueUserIds.length === 0) {
      return new Map();
    }

    const metrics = (await this.prisma.userReputationMetrics.findMany({
      where: {
        userId: {
          in: uniqueUserIds,
        },
      },
    })) as ReputationMetricsRecord[];

    const metricsByUserId = new Map(metrics.map((item) => [item.userId, item]));

    return new Map(
      uniqueUserIds.map((userId) => {
        const metric =
          metricsByUserId.get(userId) ?? this.buildDefaultMetrics(userId);
        return [userId, this.toReliabilitySummary(userId, metric)];
      }),
    );
  }

  async getGroupTrustSummary(groupId: string): Promise<GroupTrustSummaryDto> {
    const group = await this.prisma.equbGroup.findUnique({
      where: { id: groupId },
      select: {
        id: true,
        createdByUserId: true,
        rules: {
          select: {
            requiresMemberVerification: true,
          },
        },
        createdByUser: {
          select: {
            id: true,
            reputationMetrics: true,
          },
        },
        members: {
          where: {
            status: {
              in: [MemberStatus.JOINED, MemberStatus.VERIFIED, MemberStatus.ACTIVE],
            },
          },
          select: {
            status: true,
            userId: true,
            user: {
              select: {
                reputationMetrics: true,
              },
            },
          },
        },
      },
    });

    if (!group) {
      throw new NotFoundException('Group not found');
    }

    return this.toGroupTrustSummary(group as {
      id: string;
      createdByUserId: string;
      rules: { requiresMemberVerification: boolean } | null;
      createdByUser: {
        id: string;
        reputationMetrics: ReputationMetricsRecord | null;
      };
      members: Array<{
        status: MemberStatus;
        userId: string;
        user: {
          reputationMetrics: ReputationMetricsRecord | null;
        };
      }>;
    });
  }

  toReliabilitySummary(
    userId: string,
    metrics: ReputationMetricsRecord,
  ): MemberReliabilitySummaryDto {
    return {
      userId,
      trustScore: metrics.trustScore,
      trustLevel: metrics.trustLevel,
      summaryLabel: this.deriveSummaryLabel(metrics.trustScore),
      equbsCompleted: metrics.equbsCompleted,
      equbsHosted: metrics.equbsHosted,
      onTimePaymentRate: this.calculateRate(
        metrics.onTimePayments,
        metrics.onTimePayments + metrics.latePayments + metrics.missedPayments,
      ),
    };
  }

  toHostSummary(
    userId: string,
    metrics: ReputationMetricsRecord,
  ): HostReputationSummaryDto {
    return {
      userId,
      trustScore: metrics.trustScore,
      trustLevel: metrics.trustLevel,
      summaryLabel: this.deriveSummaryLabel(metrics.trustScore),
      equbsHosted: metrics.equbsHosted,
      hostedEqubsCompleted: metrics.hostedEqubsCompleted,
      turnsParticipated: metrics.turnsParticipated,
      hostedCompletionRate: this.calculateRate(
        metrics.hostedEqubsCompleted,
        metrics.equbsHosted,
      ),
      cancelledGroupsCount: metrics.cancelledGroupsCount,
      hostDisputesCount: metrics.hostDisputesCount,
    };
  }

  async ensureMaterializedMetrics(
    userId: string,
  ): Promise<ReputationMetricsRecord> {
    const metrics = (await this.prisma.userReputationMetrics.upsert({
      where: { userId },
      update: {},
      create: this.buildDefaultMetricsCreateInput(userId),
    })) as ReputationMetricsRecord;

    if (!this.needsActivityRefresh(metrics, new Date())) {
      return metrics;
    }

    const snapshot = this.calculateSnapshot(metrics, new Date());
    return (await this.prisma.userReputationMetrics.update({
      where: { userId },
      data: {
        paymentScore: snapshot.paymentScore,
        completionScore: snapshot.completionScore,
        behaviorScore: snapshot.behaviorScore,
        experienceScore: snapshot.experienceScore,
        baseScore: snapshot.baseScore,
        activityFactor: snapshot.activityFactor,
        adjustedScore: snapshot.adjustedScore,
        confidenceFactor: snapshot.confidenceFactor,
        trustScore: snapshot.trustScore,
        trustLevel: snapshot.trustLevel,
      },
    })) as ReputationMetricsRecord;
  }

  private calculateSnapshot(
    metrics: Pick<
      ReputationMetricsRecord,
      | 'onTimePayments'
      | 'latePayments'
      | 'missedPayments'
      | 'equbsJoined'
      | 'equbsCompleted'
      | 'equbsLeftEarly'
      | 'hostedEqubsCompleted'
      | 'removalsCount'
      | 'disputesCount'
      | 'turnsParticipated'
      | 'lastEqubActivityAt'
    >,
    referenceAt: Date,
  ): ReputationSnapshot {
    const totalPayments =
      metrics.onTimePayments + metrics.latePayments + metrics.missedPayments;
    const weightedPaymentTotal =
      metrics.onTimePayments +
      metrics.latePayments * 2 +
      metrics.missedPayments * 4;

    const paymentScore =
      totalPayments < REPUTATION_MIN_PAYMENT_SAMPLE || weightedPaymentTotal <= 0
        ? REPUTATION_BASELINE_SCORE
        : this.roundTo(
            this.clampScore(
              (100 * metrics.onTimePayments) / weightedPaymentTotal,
            ),
          );

    const completionDenominator = metrics.equbsJoined + metrics.equbsLeftEarly;
    const completionScore =
      metrics.equbsJoined === 0 || completionDenominator <= 0
        ? REPUTATION_BASELINE_SCORE
        : this.roundTo(
            this.clampScore(
              (100 * metrics.equbsCompleted) / completionDenominator,
            ),
          );

    const behaviorScore = this.roundTo(
      this.clampScore(
        100 -
          (5 * metrics.removalsCount + 10 * metrics.disputesCount) +
          3 * metrics.hostedEqubsCompleted,
      ),
    );

    const experienceScore = this.roundTo(
      this.clampScore(
        Math.min(
          100,
          20 * Math.log(1 + metrics.equbsCompleted) +
            0.3 * metrics.turnsParticipated,
        ),
      ),
    );

    const baseScore = this.roundTo(
      paymentScore * REPUTATION_COMPONENT_WEIGHTS.payment +
        completionScore * REPUTATION_COMPONENT_WEIGHTS.completion +
        behaviorScore * REPUTATION_COMPONENT_WEIGHTS.behavior +
        experienceScore * REPUTATION_COMPONENT_WEIGHTS.experience,
    );

    const monthsInactive = this.calculateMonthsInactive(
      metrics.lastEqubActivityAt,
      referenceAt,
    );
    const activityFactor = this.roundTo(
      Math.max(
        REPUTATION_ACTIVITY_FACTOR_FLOOR,
        1 - REPUTATION_ACTIVITY_DECAY_PER_MONTH * monthsInactive,
      ),
      4,
    );
    const adjustedScore = this.roundTo(baseScore * activityFactor);
    const confidenceFactor = this.roundTo(
      totalPayments / (totalPayments + REPUTATION_CONFIDENCE_DENOMINATOR),
      4,
    );
    const trustScore = this.clampScore(
      Math.round(
        REPUTATION_BASELINE_SCORE * (1 - confidenceFactor) +
          adjustedScore * confidenceFactor,
      ),
    );

    return {
      paymentScore,
      completionScore,
      behaviorScore,
      experienceScore,
      baseScore,
      activityFactor,
      adjustedScore,
      confidenceFactor,
      trustScore,
      trustLevel: this.deriveTrustLevel(trustScore),
    };
  }

  private toProfileResponse(
    userId: string,
    userCreatedAt: Date,
    metrics: ReputationMetricsRecord,
  ): ReputationProfileResponseDto {
    return {
      userId,
      trustScore: metrics.trustScore,
      trustLevel: metrics.trustLevel,
      summaryLabel: this.deriveSummaryLabel(metrics.trustScore),
      equbsJoined: metrics.equbsJoined,
      equbsCompleted: metrics.equbsCompleted,
      equbsLeftEarly: metrics.equbsLeftEarly,
      equbsHosted: metrics.equbsHosted,
      hostedEqubsCompleted: metrics.hostedEqubsCompleted,
      onTimePayments: metrics.onTimePayments,
      latePayments: metrics.latePayments,
      missedPayments: metrics.missedPayments,
      turnsParticipated: metrics.turnsParticipated,
      payoutsReceived: metrics.payoutsReceived,
      payoutsConfirmed: metrics.payoutsConfirmed,
      removalsCount: metrics.removalsCount,
      disputesCount: metrics.disputesCount,
      cancelledGroupsCount: metrics.cancelledGroupsCount,
      hostDisputesCount: metrics.hostDisputesCount,
      components: {
        payment: metrics.paymentScore,
        completion: metrics.completionScore,
        behavior: metrics.behaviorScore,
        experience: metrics.experienceScore,
      },
      baseScore: metrics.baseScore,
      activityFactor: metrics.activityFactor,
      adjustedScore: metrics.adjustedScore,
      confidenceFactor: metrics.confidenceFactor,
      onTimePaymentRate: this.calculateRate(
        metrics.onTimePayments,
        metrics.onTimePayments + metrics.latePayments + metrics.missedPayments,
      ),
      hostedCompletionRate: this.calculateRate(
        metrics.hostedEqubsCompleted,
        metrics.equbsHosted,
      ),
      lastEqubActivityAt: metrics.lastEqubActivityAt,
      updatedAt: metrics.updatedAt,
      eligibility: this.toEligibility(metrics.trustScore),
      badges: this.computeBadges(userCreatedAt, metrics),
    };
  }

  private toEligibility(score: number): ReputationEligibilityResponseDto {
    const hosting = this.resolvePublicHostingEligibilityFromScore(score);
    return {
      canHostPublicGroup: hosting.hostTier != null,
      canJoinHighValuePublicGroup:
        score >= REPUTATION_THRESHOLDS.highValuePublicJoinMinScore,
      canAccessLending: score >= REPUTATION_THRESHOLDS.lendingEligibilityMinScore,
      canAccessMarketplace:
        score >= REPUTATION_THRESHOLDS.marketplaceEligibilityMinScore,
      hostTier: hosting.hostTier,
      hostReputationLevel: this.deriveTrustLevel(score),
      allowedPublicEqubLimits: hosting.allowedPublicEqubLimits,
    };
  }

  private resolvePublicHostingEligibilityFromScore(score: number): {
    hostTier: HostTier | null;
    allowedPublicEqubLimits: ReputationEligibilityResponseDto['allowedPublicEqubLimits'];
  } {
    if (score < REPUTATION_THRESHOLDS.starterPublicHostMinScore) {
      return {
        hostTier: null,
        allowedPublicEqubLimits: {
          maxMembers: null,
          maxContributionAmount: null,
          maxDurationDays: null,
          maxActivePublicEqubs: null,
        },
      };
    }

    if (score < REPUTATION_THRESHOLDS.publicHostMinScore) {
      return {
        hostTier: HOST_TIER.starter,
        allowedPublicEqubLimits: {
          maxMembers: this.getNumberConfig(
            'STARTER_PUBLIC_EQUB_MAX_MEMBERS',
            10,
          ),
          maxContributionAmount: this.getNumberConfig(
            'STARTER_PUBLIC_EQUB_MAX_CONTRIBUTION',
            1000,
          ),
          maxDurationDays: this.getNumberConfig(
            'STARTER_PUBLIC_EQUB_MAX_DURATION',
            30,
          ),
          maxActivePublicEqubs: this.getNumberConfig(
            'MAX_ACTIVE_PUBLIC_EQUBS_FOR_STARTER_HOST',
            1,
          ),
        },
      };
    }

    if (score < REPUTATION_THRESHOLDS.highValuePublicHostMinScore) {
      return {
        hostTier: HOST_TIER.standard,
        allowedPublicEqubLimits: {
          maxMembers: null,
          maxContributionAmount: null,
          maxDurationDays: null,
          maxActivePublicEqubs: null,
        },
      };
    }

    return {
      hostTier: HOST_TIER.highValue,
      allowedPublicEqubLimits: {
        maxMembers: null,
        maxContributionAmount: null,
        maxDurationDays: null,
        maxActivePublicEqubs: null,
      },
    };
  }

  private computeBadges(
    userCreatedAt: Date,
    metrics: ReputationMetricsRecord,
  ): ReputationBadgeDto[] {
    const badges: ReputationBadgeDto[] = [];

    if (metrics.equbsCompleted >= 3) {
      badges.push({
        code: 'COMPLETED_3_EQUBS',
        label: 'Completed 3 Equbs',
        description: 'Completed at least three Equb rounds.',
      });
    }

    if (
      metrics.equbsHosted >= 1 &&
      metrics.hostedEqubsCompleted >= 1 &&
      metrics.trustScore >= 75
    ) {
      badges.push({
        code: 'TRUSTED_HOST',
        label: 'Trusted Host',
        description: 'Hosted and completed Equbs with a trusted score band.',
      });
    }

    const paymentCount =
      metrics.onTimePayments + metrics.latePayments + metrics.missedPayments;
    if (paymentCount > 0 && metrics.onTimePayments === paymentCount) {
      badges.push({
        code: 'ON_TIME_PAYMENT_STREAK',
        label: '100% On-time Payments',
        description: 'All tracked contribution payments have been on time.',
      });
    }

    if (userCreatedAt <= REPUTATION_THRESHOLDS.earlyAdopterCutoff) {
      badges.push({
        code: 'EARLY_ADOPTER',
        label: 'Early Adopter',
        description: 'Joined the platform during the early-adopter window.',
      });
    }

    return badges;
  }

  private async ensureUserMetricsTx(
    tx: ReputationTx,
    userId: string,
  ): Promise<ReputationMetricsRecord> {
    return (await tx.userReputationMetrics.upsert({
      where: { userId },
      update: {},
      create: this.buildDefaultMetricsCreateInput(userId),
    })) as ReputationMetricsRecord;
  }

  private applyMetricDelta(
    metrics: ReputationMetricsRecord,
    changes: ReputationMetricsDelta,
  ): ReputationMetricsRecord {
    return {
      ...metrics,
      equbsJoined: this.applyNonNegativeDelta(
        metrics.equbsJoined,
        changes.equbsJoined,
      ),
      equbsCompleted: this.applyNonNegativeDelta(
        metrics.equbsCompleted,
        changes.equbsCompleted,
      ),
      equbsLeftEarly: this.applyNonNegativeDelta(
        metrics.equbsLeftEarly,
        changes.equbsLeftEarly,
      ),
      equbsHosted: this.applyNonNegativeDelta(
        metrics.equbsHosted,
        changes.equbsHosted,
      ),
      hostedEqubsCompleted: this.applyNonNegativeDelta(
        metrics.hostedEqubsCompleted,
        changes.hostedEqubsCompleted,
      ),
      onTimePayments: this.applyNonNegativeDelta(
        metrics.onTimePayments,
        changes.onTimePayments,
      ),
      latePayments: this.applyNonNegativeDelta(
        metrics.latePayments,
        changes.latePayments,
      ),
      missedPayments: this.applyNonNegativeDelta(
        metrics.missedPayments,
        changes.missedPayments,
      ),
      turnsParticipated: this.applyNonNegativeDelta(
        metrics.turnsParticipated,
        changes.turnsParticipated,
      ),
      payoutsReceived: this.applyNonNegativeDelta(
        metrics.payoutsReceived,
        changes.payoutsReceived,
      ),
      payoutsConfirmed: this.applyNonNegativeDelta(
        metrics.payoutsConfirmed,
        changes.payoutsConfirmed,
      ),
      removalsCount: this.applyNonNegativeDelta(
        metrics.removalsCount,
        changes.removalsCount,
      ),
      disputesCount: this.applyNonNegativeDelta(
        metrics.disputesCount,
        changes.disputesCount,
      ),
      cancelledGroupsCount: this.applyNonNegativeDelta(
        metrics.cancelledGroupsCount,
        changes.cancelledGroupsCount,
      ),
      hostDisputesCount: this.applyNonNegativeDelta(
        metrics.hostDisputesCount,
        changes.hostDisputesCount,
      ),
    };
  }

  private applyNonNegativeDelta(current: number, delta?: number): number {
    return Math.max(0, current + (delta ?? 0));
  }

  private toMetricIncrementData(
    changes: ReputationMetricsDelta,
  ): Prisma.UserReputationMetricsUncheckedUpdateInput {
    const data: Prisma.UserReputationMetricsUncheckedUpdateInput = {};
    for (const [key, value] of Object.entries(changes) as Array<
      [ReputationMetricKey, number | undefined]
    >) {
      if (value == null || value === 0) {
        continue;
      }
      data[key] = { increment: value } as never;
    }
    return data;
  }

  private calculateRate(numerator: number, denominator: number): number | null {
    if (denominator <= 0) {
      return null;
    }
    return Math.round((numerator / denominator) * 100);
  }

  private getNumberConfig(name: string, fallback: number): number {
    const value = this.configService.get<string | number>(name);
    if (value == null || value === '') {
      return fallback;
    }

    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : fallback;
  }

  private calculateMonthsInactive(
    lastEqubActivityAt: Date | null,
    referenceAt: Date,
  ): number {
    if (!lastEqubActivityAt) {
      return 0;
    }

    return Math.max(
      0,
      Math.floor(
        (referenceAt.getTime() - lastEqubActivityAt.getTime()) /
          REPUTATION_MONTH_IN_MS,
      ),
    );
  }

  private needsActivityRefresh(
    metrics: ReputationMetricsRecord,
    referenceAt: Date,
  ): boolean {
    if (!metrics.lastEqubActivityAt) {
      return false;
    }

    return (
      this.calculateMonthsInactive(metrics.lastEqubActivityAt, referenceAt) >
      this.calculateMonthsInactive(metrics.lastEqubActivityAt, metrics.updatedAt)
    );
  }

  private roundTo(value: number, precision = 2): number {
    const factor = 10 ** precision;
    return Math.round(value * factor) / factor;
  }

  private clampScore(value: number): number {
    return Math.max(REPUTATION_SCORE_MIN, Math.min(REPUTATION_SCORE_MAX, value));
  }

  private buildDefaultMetricsCreateInput(
    userId: string,
  ): Prisma.UserReputationMetricsUncheckedCreateInput {
    return {
      userId,
      trustScore: REPUTATION_BASELINE_SCORE,
      trustLevel: 'New',
      paymentScore: REPUTATION_BASELINE_SCORE,
      completionScore: REPUTATION_BASELINE_SCORE,
      behaviorScore: 100,
      experienceScore: 0,
      baseScore: REPUTATION_BASE_SCORE_DEFAULT,
      activityFactor: 1,
      adjustedScore: REPUTATION_BASE_SCORE_DEFAULT,
      confidenceFactor: 0,
    };
  }

  private buildDefaultMetrics(userId: string): ReputationMetricsRecord {
    return {
      userId,
      trustScore: REPUTATION_BASELINE_SCORE,
      trustLevel: 'New',
      paymentScore: REPUTATION_BASELINE_SCORE,
      completionScore: REPUTATION_BASELINE_SCORE,
      behaviorScore: 100,
      experienceScore: 0,
      baseScore: REPUTATION_BASE_SCORE_DEFAULT,
      activityFactor: 1,
      adjustedScore: REPUTATION_BASE_SCORE_DEFAULT,
      confidenceFactor: 0,
      equbsJoined: 0,
      equbsCompleted: 0,
      equbsLeftEarly: 0,
      equbsHosted: 0,
      hostedEqubsCompleted: 0,
      onTimePayments: 0,
      latePayments: 0,
      missedPayments: 0,
      turnsParticipated: 0,
      payoutsReceived: 0,
      payoutsConfirmed: 0,
      removalsCount: 0,
      disputesCount: 0,
      cancelledGroupsCount: 0,
      hostDisputesCount: 0,
      lastEqubActivityAt: null,
      updatedAt: new Date(0),
    };
  }

  private toGroupTrustSummary(group: {
    id: string;
    createdByUserId: string;
    rules: { requiresMemberVerification: boolean } | null;
    createdByUser: {
      id: string;
      reputationMetrics: ReputationMetricsRecord | null;
    };
    members: Array<{
      status: MemberStatus;
      userId: string;
      user: {
        reputationMetrics: ReputationMetricsRecord | null;
      };
    }>;
  }): GroupTrustSummaryDto {
    const hostMetrics =
      group.createdByUser.reputationMetrics ??
      this.buildDefaultMetrics(group.createdByUserId);
    const memberScores = group.members.map(
      (member) =>
        member.user.reputationMetrics?.trustScore ?? REPUTATION_BASELINE_SCORE,
    );
    const verifiedMembers = group.members.filter(
      (member) => member.status === MemberStatus.VERIFIED,
    ).length;
    const averageMemberScore =
      memberScores.length > 0
        ? Math.round(
            memberScores.reduce((sum, score) => sum + score, 0) /
              memberScores.length,
          )
        : null;
    const verifiedMembersPercent =
      group.members.length > 0
        ? Math.round((verifiedMembers / group.members.length) * 100)
        : null;

    let groupTrustLevel = 'Low';
    if (
      hostMetrics.trustScore >= 90 &&
      (averageMemberScore ?? 0) >= 80 &&
      (verifiedMembersPercent ?? 0) >= 75
    ) {
      groupTrustLevel = 'High';
    } else if (
      hostMetrics.trustScore >= 75 &&
      (averageMemberScore ?? 0) >= 65
    ) {
      groupTrustLevel = 'Medium';
    }

    return {
      groupId: group.id,
      hostScore: hostMetrics.trustScore,
      averageMemberScore,
      verifiedMembersPercent,
      groupTrustLevel,
      host: this.toHostSummary(group.createdByUserId, hostMetrics),
    };
  }

  private toMetricChangesRecord(value: Prisma.JsonValue): Record<string, number> {
    if (!value || typeof value !== 'object' || Array.isArray(value)) {
      return {};
    }

    const entries = Object.entries(value).filter(
      (entry): entry is [string, number] => typeof entry[1] === 'number',
    );
    return Object.fromEntries(entries);
  }
}
