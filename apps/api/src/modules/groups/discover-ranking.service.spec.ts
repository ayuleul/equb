import { DiscoverRankingService } from './discover-ranking.service';

describe('DiscoverRankingService', () => {
  const service = new DiscoverRankingService();

  const baseMetrics = {
    equbId: 'group-1',
    hostTrustScore: 82,
    hostTrustLevel: 'Trusted',
    avgMemberScore: 74,
    groupTrustLevel: 'High',
    joinedCount: 8,
    maxMembers: 10,
    fillPercent: 80,
    pendingRequestCount: 3,
    waitlistCount: 0,
    joinVelocity24h: 2,
    joinVelocity7d: 4,
    hostCompletionRate: 91,
    freshnessScore: 88,
    createdAt: new Date('2026-03-10T00:00:00.000Z'),
    lastActivityAt: new Date('2026-03-12T00:00:00.000Z'),
    hostCancelledGroupsCount: 0,
    hostDisputesCount: 0,
    contributionAmount: 1200,
    durationDays: 30,
    hostTier: 'standard',
  } as const;

  it('calculates deterministic discover scores', () => {
    expect(service.buildDiscoverScore(baseMetrics)).toBe(75);
  });

  it('applies stale and low-trust demotions', () => {
    expect(
      service.buildDiscoverScore({
        ...baseMetrics,
        hostTrustScore: 32,
        groupTrustLevel: 'Low',
        fillPercent: 18,
        freshnessScore: 22,
        createdAt: new Date('2026-01-01T00:00:00.000Z'),
        hostCancelledGroupsCount: 2,
        hostDisputesCount: 1,
      }),
    ).toBeLessThan(30);
  });

  it('keeps cold start recommendations deterministic without fake personalization', () => {
    const breakdown = service.buildScoreBreakdown(
      {
        ...baseMetrics,
        hostTier: 'starter',
        contributionAmount: 800,
        maxMembers: 8,
        durationDays: 7,
      },
      null,
    );

    expect(breakdown.matchScore).toBeNull();
    expect(breakdown.reasonLabels).toContain('Good for new members');
    expect(breakdown.finalRecommendedScore).toBeGreaterThanOrEqual(
      breakdown.discoverScore,
    );
  });

  it('applies personalization boost when user history exists', () => {
    const breakdown = service.buildScoreBreakdown(baseMetrics, {
      averageContribution: 1100,
      averageDurationDays: 30,
      averageGroupSize: 10,
      historyCount: 4,
    });

    expect(breakdown.matchScore).toBeGreaterThanOrEqual(90);
    expect(breakdown.finalRecommendedScore).toBeGreaterThanOrEqual(
      breakdown.discoverScore,
    );
    expect(breakdown.reasonLabels).toContain('Recommended for you');
    expect(breakdown.reasonLabels).toContain('Matches your usual contribution');
  });

  it('generates deterministic reason labels without exposing raw scores', () => {
    const breakdown = service.buildScoreBreakdown(baseMetrics, {
      averageContribution: 1200,
      averageDurationDays: 30,
      averageGroupSize: 10,
      historyCount: 2,
    });

    expect(breakdown.reasonLabels).toEqual([
      'Recommended for you',
      'Matches your usual contribution',
      'Trusted host',
    ]);
  });
});
