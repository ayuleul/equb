import { Injectable } from '@nestjs/common';

import {
  DISCOVER_HIGH_VALUE_CONTRIBUTION_AMOUNT,
  DISCOVER_LIMITS,
  DISCOVER_MATCH_WEIGHTS,
  DISCOVER_REASON_LABELS,
  DISCOVER_RECOMMENDED_BLEND,
  DISCOVER_SCORE_WEIGHTS,
  DISCOVER_SECTION_KEYS,
} from './discover.constants';

export type DiscoverMetricsSnapshot = {
  equbId: string;
  hostTrustScore: number;
  hostTrustLevel: string;
  avgMemberScore: number;
  groupTrustLevel: string;
  joinedCount: number;
  maxMembers: number;
  fillPercent: number;
  pendingRequestCount: number;
  waitlistCount: number;
  joinVelocity24h: number;
  joinVelocity7d: number;
  hostCompletionRate: number;
  freshnessScore: number;
  createdAt: Date;
  lastActivityAt: Date;
  hostCancelledGroupsCount: number;
  hostDisputesCount: number;
  contributionAmount: number;
  durationDays: number;
  hostTier: string | null;
};

export type DiscoverUserPreferenceProfile = {
  averageContribution: number;
  averageDurationDays: number;
  averageGroupSize: number;
  historyCount: number;
} | null;

export type DiscoverScoreBreakdown = {
  discoverScore: number;
  finalRecommendedScore: number;
  matchScore: number | null;
  contributionFit: number | null;
  durationFit: number | null;
  groupSizeFit: number | null;
  reasonLabels: string[];
  sectionScores: Record<string, number>;
};

@Injectable()
export class DiscoverRankingService {
  buildFreshnessScore(
    createdAt: Date,
    lastActivityAt: Date | null,
    now: Date,
  ): number {
    const reference = lastActivityAt ?? createdAt;
    const ageHours = Math.max(
      0,
      (now.getTime() - reference.getTime()) / (60 * 60 * 1000),
    );

    if (ageHours <= 24) {
      return 100;
    }
    if (ageHours <= 72) {
      return 90;
    }
    if (ageHours <= 7 * 24) {
      return 75;
    }
    if (ageHours <= 14 * 24) {
      return 60;
    }
    if (ageHours <= 30 * 24) {
      return 40;
    }

    return 20;
  }

  buildJoinVelocityScore(
    joinVelocity24h: number,
    joinVelocity7d: number,
    maxMembers: number,
  ): number {
    const denominator = Math.max(maxMembers, 1);
    const velocity24 = Math.min(
      100,
      Math.round((joinVelocity24h / denominator) * 100),
    );
    const velocity7 = Math.min(
      100,
      Math.round((joinVelocity7d / denominator) * 100),
    );

    return this.clampScore(Math.round(velocity24 * 0.65 + velocity7 * 0.35));
  }

  buildDiscoverScore(metrics: DiscoverMetricsSnapshot): number {
    const joinVelocityScore = this.buildJoinVelocityScore(
      metrics.joinVelocity24h,
      metrics.joinVelocity7d,
      metrics.maxMembers,
    );
    const weightedScore =
      DISCOVER_SCORE_WEIGHTS.hostTrust * metrics.hostTrustScore +
      DISCOVER_SCORE_WEIGHTS.averageMember * metrics.avgMemberScore +
      DISCOVER_SCORE_WEIGHTS.fillPercent * metrics.fillPercent +
      DISCOVER_SCORE_WEIGHTS.freshness * metrics.freshnessScore +
      DISCOVER_SCORE_WEIGHTS.joinVelocity * joinVelocityScore;

    return this.applyPenalties(metrics, Math.round(weightedScore));
  }

  buildScoreBreakdown(
    metrics: DiscoverMetricsSnapshot,
    profile: DiscoverUserPreferenceProfile,
  ): DiscoverScoreBreakdown {
    const discoverScore = this.buildDiscoverScore(metrics);
    const contributionFit = profile
      ? this.buildFitScore(
          metrics.contributionAmount,
          profile.averageContribution,
        )
      : null;
    const durationFit = profile
      ? this.buildFitScore(metrics.durationDays, profile.averageDurationDays)
      : null;
    const groupSizeFit = profile
      ? this.buildFitScore(metrics.maxMembers, profile.averageGroupSize)
      : null;
    const matchScore =
      contributionFit == null || durationFit == null || groupSizeFit == null
        ? null
        : this.clampScore(
            Math.round(
              DISCOVER_MATCH_WEIGHTS.contribution * contributionFit +
                DISCOVER_MATCH_WEIGHTS.duration * durationFit +
                DISCOVER_MATCH_WEIGHTS.groupSize * groupSizeFit,
            ),
          );

    const finalRecommendedScore =
      matchScore == null
        ? this.buildColdStartScore(metrics, discoverScore)
        : this.clampScore(
            Math.round(
              DISCOVER_RECOMMENDED_BLEND.discoverScore * discoverScore +
                DISCOVER_RECOMMENDED_BLEND.matchScore * matchScore,
            ),
          );

    const sectionScores = {
      [DISCOVER_SECTION_KEYS.recommended]: finalRecommendedScore,
      [DISCOVER_SECTION_KEYS.fillingFast]: this.clampScore(
        Math.round(
          metrics.fillPercent * 0.6 +
            this.buildJoinVelocityScore(
              metrics.joinVelocity24h,
              metrics.joinVelocity7d,
              metrics.maxMembers,
            ) *
              0.25 +
            metrics.hostTrustScore * 0.15,
        ),
      ),
      [DISCOVER_SECTION_KEYS.trustedHosts]: this.clampScore(
        Math.round(metrics.hostTrustScore * 0.75 + discoverScore * 0.25),
      ),
      [DISCOVER_SECTION_KEYS.newEqubs]: this.clampScore(
        Math.round(metrics.freshnessScore * 0.6 + discoverScore * 0.4),
      ),
      [DISCOVER_SECTION_KEYS.starterEqubs]: this.clampScore(
        Math.round(
          this.buildStarterScore(metrics) * 0.55 + discoverScore * 0.45,
        ),
      ),
    };

    return {
      discoverScore,
      finalRecommendedScore,
      matchScore,
      contributionFit,
      durationFit,
      groupSizeFit,
      reasonLabels: this.buildReasonLabels(
        metrics,
        matchScore,
        contributionFit,
      ),
      sectionScores,
    };
  }

  isTrustedHost(metrics: DiscoverMetricsSnapshot): boolean {
    return metrics.hostTrustScore >= 75;
  }

  isFillingFast(metrics: DiscoverMetricsSnapshot): boolean {
    return (
      metrics.fillPercent >= 60 ||
      this.buildJoinVelocityScore(
        metrics.joinVelocity24h,
        metrics.joinVelocity7d,
        metrics.maxMembers,
      ) >= 45
    );
  }

  isNewEqub(metrics: DiscoverMetricsSnapshot): boolean {
    const ageDays =
      (Date.now() - metrics.createdAt.getTime()) / (24 * 60 * 60 * 1000);
    return (
      metrics.freshnessScore >= 85 ||
      ageDays <= DISCOVER_LIMITS.newEqubWindowDays
    );
  }

  isStarterEqub(metrics: DiscoverMetricsSnapshot): boolean {
    return this.buildStarterScore(metrics) >= 60;
  }

  private buildColdStartScore(
    metrics: DiscoverMetricsSnapshot,
    discoverScore: number,
  ): number {
    return this.clampScore(
      Math.round(
        discoverScore * 0.65 +
          this.buildStarterScore(metrics) * 0.2 +
          metrics.hostTrustScore * 0.15,
      ),
    );
  }

  private buildStarterScore(metrics: DiscoverMetricsSnapshot): number {
    let score = 0;

    if (metrics.hostTrustScore >= 60) {
      score += 35;
    }
    if (metrics.groupTrustLevel === 'High') {
      score += 20;
    } else if (metrics.groupTrustLevel === 'Medium') {
      score += 12;
    }
    if (
      metrics.contributionAmount <= DISCOVER_LIMITS.starterContributionCeiling
    ) {
      score += 20;
    }
    if (metrics.maxMembers <= DISCOVER_LIMITS.starterSizeCeiling) {
      score += 15;
    }
    if (metrics.durationDays <= DISCOVER_LIMITS.starterDurationCeilingDays) {
      score += 10;
    }

    return this.clampScore(score);
  }

  private buildReasonLabels(
    metrics: DiscoverMetricsSnapshot,
    matchScore: number | null,
    contributionFit: number | null,
  ): string[] {
    const labels: string[] = [];

    if (matchScore != null && matchScore >= 70) {
      labels.push(DISCOVER_REASON_LABELS.recommended);
    }
    if (contributionFit != null && contributionFit >= 78) {
      labels.push(DISCOVER_REASON_LABELS.matchesContribution);
    }
    if (metrics.hostTrustScore >= 75) {
      labels.push(DISCOVER_REASON_LABELS.trustedHost);
    }
    if (this.isStarterEqub(metrics)) {
      labels.push(DISCOVER_REASON_LABELS.goodForNewMembers);
    }
    if (metrics.groupTrustLevel === 'High') {
      labels.push(DISCOVER_REASON_LABELS.highTrustGroup);
    }
    if (metrics.fillPercent >= 85) {
      labels.push(DISCOVER_REASON_LABELS.almostFull);
    } else if (this.isFillingFast(metrics)) {
      labels.push(DISCOVER_REASON_LABELS.fillingFast);
    }
    if (this.isNewEqub(metrics)) {
      labels.push(DISCOVER_REASON_LABELS.newEqub);
    }
    return [...new Set(labels)].slice(0, 3);
  }

  private buildFitScore(value: number, baseline: number): number {
    if (baseline <= 0) {
      return 50;
    }

    const deltaRatio = Math.abs(value - baseline) / baseline;
    return this.clampScore(Math.round(100 - Math.min(deltaRatio, 1) * 100));
  }

  private applyPenalties(
    metrics: DiscoverMetricsSnapshot,
    baseScore: number,
  ): number {
    let score = baseScore;

    if (metrics.hostTrustScore < 40) {
      score -= DISCOVER_LIMITS.lowHostTrustPenalty;
    }
    if (metrics.groupTrustLevel === 'Low') {
      score -= DISCOVER_LIMITS.lowGroupTrustPenalty;
    }

    const ageDays =
      (Date.now() - metrics.createdAt.getTime()) / (24 * 60 * 60 * 1000);
    if (
      ageDays >= DISCOVER_LIMITS.staleAgeDays &&
      metrics.fillPercent < DISCOVER_LIMITS.staleLowFillPercent
    ) {
      score -= DISCOVER_LIMITS.stalePenalty;
    }

    score -= Math.min(
      DISCOVER_LIMITS.hostCancellationPenaltyCap,
      metrics.hostCancelledGroupsCount *
        DISCOVER_LIMITS.hostCancellationPenaltyPerEvent,
    );
    score -= Math.min(
      DISCOVER_LIMITS.hostDisputePenaltyCap,
      metrics.hostDisputesCount * DISCOVER_LIMITS.hostDisputePenaltyPerEvent,
    );

    if (
      metrics.contributionAmount >= DISCOVER_HIGH_VALUE_CONTRIBUTION_AMOUNT &&
      metrics.hostTrustScore < 60
    ) {
      score -= 8;
    }

    return this.clampScore(score);
  }

  private clampScore(value: number): number {
    return Math.max(0, Math.min(100, value));
  }
}
