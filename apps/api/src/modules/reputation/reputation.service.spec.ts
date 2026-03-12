import { MemberStatus } from '@prisma/client';

import { ReputationService } from './reputation.service';

describe('ReputationService', () => {
  const createService = () => {
    const prisma = {
      user: {
        findUnique: jest.fn(),
      },
      userReputationMetrics: {
        upsert: jest.fn(),
        findMany: jest.fn(),
        update: jest.fn(),
      },
      reputationHistory: {
        findUnique: jest.fn(),
        create: jest.fn(),
        findMany: jest.fn(),
        count: jest.fn(),
      },
      equbGroup: {
        findUnique: jest.fn(),
      },
    };

    return {
      prisma,
      service: new ReputationService(
        prisma as never,
        { get: jest.fn() } as never,
      ),
    };
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('calculates normalized component-driven scores', () => {
    const { service } = createService();

    const score = service.calculateTrustScore(
      {
        onTimePayments: 8,
        latePayments: 1,
        missedPayments: 1,
        equbsJoined: 5,
        equbsCompleted: 4,
        equbsLeftEarly: 1,
        removalsCount: 0,
        disputesCount: 0,
        hostedEqubsCompleted: 1,
        turnsParticipated: 6,
        lastEqubActivityAt: new Date('2026-03-01T00:00:00.000Z'),
      },
      new Date('2026-03-12T00:00:00.000Z'),
    );

    expect(score).toBe(58);
  });

  it('uses diminishing returns for experience', () => {
    const { service } = createService();

    const lower = service.calculateTrustScore(
      {
        onTimePayments: 10,
        latePayments: 0,
        missedPayments: 0,
        equbsJoined: 2,
        equbsCompleted: 2,
        equbsLeftEarly: 0,
        removalsCount: 0,
        disputesCount: 0,
        hostedEqubsCompleted: 0,
        turnsParticipated: 4,
        lastEqubActivityAt: new Date('2026-03-01T00:00:00.000Z'),
      },
      new Date('2026-03-12T00:00:00.000Z'),
    );
    const higher = service.calculateTrustScore(
      {
        onTimePayments: 10,
        latePayments: 0,
        missedPayments: 0,
        equbsJoined: 20,
        equbsCompleted: 20,
        equbsLeftEarly: 0,
        removalsCount: 0,
        disputesCount: 0,
        hostedEqubsCompleted: 0,
        turnsParticipated: 40,
        lastEqubActivityAt: new Date('2026-03-01T00:00:00.000Z'),
      },
      new Date('2026-03-12T00:00:00.000Z'),
    );

    expect(higher).toBeGreaterThan(lower);
    expect(higher - lower).toBeLessThan(25);
  });

  it('applies activity decay after inactive months', () => {
    const { service } = createService();

    const active = service.calculateTrustScore(
      {
        onTimePayments: 12,
        latePayments: 0,
        missedPayments: 0,
        equbsJoined: 5,
        equbsCompleted: 5,
        equbsLeftEarly: 0,
        removalsCount: 0,
        disputesCount: 0,
        hostedEqubsCompleted: 1,
        turnsParticipated: 10,
        lastEqubActivityAt: new Date('2026-03-01T00:00:00.000Z'),
      },
      new Date('2026-03-12T00:00:00.000Z'),
    );
    const inactive = service.calculateTrustScore(
      {
        onTimePayments: 12,
        latePayments: 0,
        missedPayments: 0,
        equbsJoined: 5,
        equbsCompleted: 5,
        equbsLeftEarly: 0,
        removalsCount: 0,
        disputesCount: 0,
        hostedEqubsCompleted: 1,
        turnsParticipated: 10,
        lastEqubActivityAt: new Date('2025-03-01T00:00:00.000Z'),
      },
      new Date('2026-03-12T00:00:00.000Z'),
    );

    expect(inactive).toBeLessThan(active);
  });

  it('keeps new users near baseline through the confidence factor', () => {
    const { service } = createService();

    const newUserScore = service.calculateTrustScore(
      {
        onTimePayments: 1,
        latePayments: 0,
        missedPayments: 0,
        equbsJoined: 1,
        equbsCompleted: 1,
        equbsLeftEarly: 0,
        removalsCount: 0,
        disputesCount: 0,
        hostedEqubsCompleted: 0,
        turnsParticipated: 1,
        lastEqubActivityAt: new Date('2026-03-10T00:00:00.000Z'),
      },
      new Date('2026-03-12T00:00:00.000Z'),
    );

    expect(newUserScore).toBeGreaterThanOrEqual(50);
    expect(newUserScore).toBeLessThanOrEqual(55);
  });

  it('clamps scores and maps all trust levels including Elite', () => {
    const { service } = createService();

    const clampedLow = service.calculateTrustScore(
      {
        onTimePayments: 0,
        latePayments: 0,
        missedPayments: 20,
        equbsJoined: 10,
        equbsCompleted: 0,
        equbsLeftEarly: 10,
        removalsCount: 10,
        disputesCount: 5,
        hostedEqubsCompleted: 0,
        turnsParticipated: 0,
        lastEqubActivityAt: new Date('2024-01-01T00:00:00.000Z'),
      },
      new Date('2026-03-12T00:00:00.000Z'),
    );
    const clampedHigh = service.calculateTrustScore(
      {
        onTimePayments: 50,
        latePayments: 0,
        missedPayments: 0,
        equbsJoined: 20,
        equbsCompleted: 20,
        equbsLeftEarly: 0,
        removalsCount: 0,
        disputesCount: 0,
        hostedEqubsCompleted: 15,
        turnsParticipated: 80,
        lastEqubActivityAt: new Date('2026-03-10T00:00:00.000Z'),
      },
      new Date('2026-03-12T00:00:00.000Z'),
    );

    expect(clampedLow).toBeGreaterThanOrEqual(0);
    expect(clampedHigh).toBeLessThanOrEqual(100);
    expect(service.deriveTrustLevel(35)).toBe('Risky');
    expect(service.deriveTrustLevel(50)).toBe('New');
    expect(service.deriveTrustLevel(70)).toBe('Reliable');
    expect(service.deriveTrustLevel(80)).toBe('Trusted');
    expect(service.deriveTrustLevel(95)).toBe('Elite');
  });

  it('applies reputation events idempotently', async () => {
    const { service } = createService();
    const tx = {
      reputationHistory: {
        findUnique: jest
          .fn()
          .mockResolvedValueOnce(null)
          .mockResolvedValueOnce({ id: 'history-1' }),
        create: jest.fn(),
      },
      userReputationMetrics: {
        upsert: jest.fn().mockResolvedValue({
          userId: 'user-1',
          trustScore: 50,
          trustLevel: 'New',
          paymentScore: 50,
          completionScore: 50,
          behaviorScore: 100,
          experienceScore: 0,
          baseScore: 55,
          activityFactor: 1,
          adjustedScore: 55,
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
          updatedAt: new Date('2026-03-01T00:00:00.000Z'),
        }),
        update: jest.fn(),
      },
    };

    await service.applyEvent(tx as never, {
      userId: 'user-1',
      eventType: 'MEMBER_JOINED',
      metricChanges: { equbsJoined: 1 },
      idempotencyKey: 'join-1',
      activityAt: new Date('2026-03-12T00:00:00.000Z'),
    });
    await service.applyEvent(tx as never, {
      userId: 'user-1',
      eventType: 'MEMBER_JOINED',
      metricChanges: { equbsJoined: 1 },
      idempotencyKey: 'join-1',
      activityAt: new Date('2026-03-12T00:00:00.000Z'),
    });

    expect(tx.userReputationMetrics.update).toHaveBeenCalledTimes(1);
    expect(tx.reputationHistory.create).toHaveBeenCalledTimes(1);
  });

  it('aggregates group trust summaries from stored trust scores', async () => {
    const { prisma, service } = createService();
    prisma.equbGroup.findUnique.mockResolvedValue({
      id: 'group-1',
      createdByUserId: 'host-1',
      rules: {
        requiresMemberVerification: true,
      },
      createdByUser: {
        id: 'host-1',
        reputationMetrics: {
          userId: 'host-1',
          trustScore: 91,
          trustLevel: 'Elite',
          paymentScore: 100,
          completionScore: 100,
          behaviorScore: 100,
          experienceScore: 80,
          baseScore: 98,
          activityFactor: 1,
          adjustedScore: 98,
          confidenceFactor: 0.9,
          equbsJoined: 0,
          equbsCompleted: 1,
          equbsLeftEarly: 0,
          equbsHosted: 3,
          hostedEqubsCompleted: 2,
          onTimePayments: 0,
          latePayments: 0,
          missedPayments: 0,
          turnsParticipated: 5,
          payoutsReceived: 0,
          payoutsConfirmed: 0,
          removalsCount: 0,
          disputesCount: 0,
          cancelledGroupsCount: 0,
          hostDisputesCount: 0,
          lastEqubActivityAt: new Date(),
          updatedAt: new Date(),
        },
      },
      members: [
        {
          status: MemberStatus.VERIFIED,
          userId: 'user-1',
          user: {
            reputationMetrics: {
              userId: 'user-1',
              trustScore: 84,
              trustLevel: 'Trusted',
              paymentScore: 0,
              completionScore: 0,
              behaviorScore: 0,
              experienceScore: 0,
              baseScore: 0,
              activityFactor: 1,
              adjustedScore: 0,
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
              lastEqubActivityAt: new Date(),
              updatedAt: new Date(),
            },
          },
        },
        {
          status: MemberStatus.VERIFIED,
          userId: 'user-2',
          user: {
            reputationMetrics: {
              userId: 'user-2',
              trustScore: 82,
              trustLevel: 'Trusted',
              paymentScore: 0,
              completionScore: 0,
              behaviorScore: 0,
              experienceScore: 0,
              baseScore: 0,
              activityFactor: 1,
              adjustedScore: 0,
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
              lastEqubActivityAt: new Date(),
              updatedAt: new Date(),
            },
          },
        },
      ],
    });

    const summary = await service.getGroupTrustSummary('group-1');

    expect(summary.hostScore).toBe(91);
    expect(summary.averageMemberScore).toBe(83);
    expect(summary.verifiedMembersPercent).toBe(100);
    expect(summary.groupTrustLevel).toBe('High');
  });
});
