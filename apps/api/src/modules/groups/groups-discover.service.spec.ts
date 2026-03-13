import { GroupRuleFrequency, JoinRequestStatus } from '@prisma/client';

import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import { GroupsDiscoverService } from './groups-discover.service';

describe('GroupsDiscoverService', () => {
  const currentUser: AuthenticatedUser = {
    id: 'user-1',
    phone: '+251911111111',
  };

  const prisma = {
    equbGroup: {
      findMany: jest.fn(),
    },
    equbMember: {
      findMany: jest.fn(),
    },
    equbDiscoverMetrics: {
      findMany: jest.fn(),
    },
  };
  const discoverMetricsService = {
    ensureMetricsForGroups: jest.fn(),
    refreshMetricsForGroups: jest.fn(),
  };
  const discoverRankingService = {
    buildScoreBreakdown: jest.fn(),
    isFillingFast: jest.fn(),
    isTrustedHost: jest.fn(),
    isNewEqub: jest.fn(),
    isStarterEqub: jest.fn(),
  };
  const reputationService = {
    getEligibility: jest.fn(),
    deriveTrustLevel: jest.fn((score: number) =>
      score >= 75 ? 'Trusted' : 'New',
    ),
  };

  const service = new GroupsDiscoverService(
    prisma as never,
    discoverMetricsService as never,
    discoverRankingService as never,
    reputationService as never,
  );

  beforeEach(() => {
    jest.clearAllMocks();
    prisma.equbMember.findMany.mockResolvedValue([]);
    prisma.equbGroup.findMany
      .mockResolvedValueOnce([{ id: 'group-1' }, { id: 'group-2' }])
      .mockResolvedValueOnce([
        {
          id: 'group-1',
          name: 'Trusted Circle',
          description: 'Fast moving group',
          currency: 'ETB',
          contributionAmount: 1000,
          createdAt: new Date('2026-03-12T00:00:00.000Z'),
          hostTier: 'starter',
          hostReputationAtCreation: 82,
          createdByUserId: 'host-1',
          createdByUser: {
            fullName: 'Samuel',
            phone: '+251900000001',
            reputationMetrics: {
              trustScore: 82,
              trustLevel: 'Trusted',
              equbsHosted: 4,
              hostedEqubsCompleted: 3,
              turnsParticipated: 12,
              cancelledGroupsCount: 0,
              hostDisputesCount: 0,
            },
          },
          rules: {
            contributionAmount: 1000,
            frequency: GroupRuleFrequency.MONTHLY,
            customIntervalDays: null,
            payoutMode: 'LOTTERY',
            roundSize: 10,
            startPolicy: 'WHEN_FULL',
            startAt: null,
            minToStart: null,
            winnerSelectionTiming: 'BEFORE_COLLECTION',
          },
          discoverMetrics: {
            hostTrustScore: 82,
            hostTrustLevel: 'Trusted',
            avgMemberScore: 70,
            groupTrustLevel: 'High',
            verifiedMembersPercent: 90,
            joinedCount: 8,
            maxMembers: 10,
            fillPercent: 80,
            pendingRequestCount: 2,
            waitlistCount: 0,
            joinVelocity24h: 2,
            joinVelocity7d: 4,
            hostCompletionRate: 75,
            freshnessScore: 88,
            discoverScore: 79,
            createdAt: new Date('2026-03-12T00:00:00.000Z'),
            lastActivityAt: new Date('2026-03-13T00:00:00.000Z'),
          },
        },
      ]);
    prisma.equbDiscoverMetrics.findMany.mockResolvedValue([
      { equbId: 'group-1' },
      { equbId: 'group-2' },
    ]);
    discoverMetricsService.ensureMetricsForGroups.mockResolvedValue(undefined);
    reputationService.getEligibility.mockResolvedValue({
      canJoinHighValuePublicGroup: true,
    });
    discoverRankingService.buildScoreBreakdown.mockReturnValue({
      discoverScore: 79,
      finalRecommendedScore: 83,
      matchScore: null,
      contributionFit: null,
      durationFit: null,
      groupSizeFit: null,
      reasonLabels: ['Trusted host', 'Filling fast'],
      sectionScores: {
        recommended_for_you: 83,
        filling_fast: 85,
        trusted_hosts: 87,
        new_equbs: 81,
        starter_equbs: 80,
      },
    });
    discoverRankingService.isFillingFast.mockReturnValue(true);
    discoverRankingService.isTrustedHost.mockReturnValue(true);
    discoverRankingService.isNewEqub.mockReturnValue(true);
    discoverRankingService.isStarterEqub.mockReturnValue(true);
  });

  it('builds candidate selection with member/request/full-safe exclusions', async () => {
    await service.listDiscoverSections(currentUser, {});

    expect(prisma.equbGroup.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({
          visibility: 'PUBLIC',
          status: 'ACTIVE',
          createdByUserId: { not: currentUser.id },
          cycles: { none: {} },
          members: {
            none: {
              userId: currentUser.id,
              status: { in: expect.any(Array) },
            },
          },
          joinRequests: {
            none: {
              userId: currentUser.id,
              status: {
                in: [JoinRequestStatus.REQUESTED, JoinRequestStatus.APPROVED],
              },
            },
          },
        }),
      }),
    );
  });

  it('returns ranked sections with card-ready items', async () => {
    const response = await service.listDiscoverSections(currentUser, {
      sectionLimit: 3,
    });

    expect(response.sections.map((section) => section.key)).toEqual([
      'recommended_for_you',
      'filling_fast',
      'trusted_hosts',
      'new_equbs',
      'starter_equbs',
    ]);
    expect(response.sections[0].items[0]).toMatchObject({
      equbId: 'group-1',
      name: 'Trusted Circle',
      joinedCount: 8,
      maxMembers: 10,
      fillPercent: 80,
      groupTrustLevel: 'High',
      reasonLabels: ['Trusted host', 'Filling fast'],
    });
  });

  it('ensures metrics before trust-level filtered discovery', async () => {
    await service.listDiscoverSections(currentUser, {
      trustLevel: 'Trusted',
    });

    expect(discoverMetricsService.ensureMetricsForGroups).toHaveBeenCalledWith([
      'group-1',
      'group-2',
    ]);
    expect(prisma.equbDiscoverMetrics.findMany).toHaveBeenCalled();
  });
});
