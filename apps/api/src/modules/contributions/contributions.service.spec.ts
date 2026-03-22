import {
  ContributionStatus,
  CycleState,
  CycleStatus,
  GroupPaymentMethod,
  GroupRuleFineType,
} from '@prisma/client';

import type { PrismaService } from '../../common/prisma/prisma.service';
import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import { ContributionsService } from './contributions.service';

describe('ContributionsService.evaluateCycleCollection', () => {
  const currentUser: AuthenticatedUser = {
    id: 'user-admin',
    phone: '+251911111111',
  };

  function createService(
    winnerSelectionTiming: 'BEFORE_COLLECTION' | 'AFTER_COLLECTION',
  ) {
    const updatedStates: CycleState[] = [];

    const txMock = {
      equbCycle: {
        findUnique: jest
          .fn()
          .mockImplementation(
            ({ include, select }: { include?: unknown; select?: unknown }) => {
              if (include) {
                return Promise.resolve({
                  id: 'cycle-1',
                  groupId: 'group-1',
                  dueAt: new Date('3026-03-01T00:00:00.000Z'),
                  status: CycleStatus.OPEN,
                  state: CycleState.COLLECTING,
                  group: {
                    id: 'group-1',
                    name: 'Group',
                    rules: {
                      graceDays: 0,
                      fineType: GroupRuleFineType.NONE,
                      fineAmount: 0,
                    },
                  },
                  contributions: [
                    {
                      id: 'contribution-1',
                      userId: 'user-admin',
                      amount: 500,
                      status: ContributionStatus.VERIFIED,
                    },
                    {
                      id: 'contribution-2',
                      userId: 'user-member',
                      amount: 500,
                      status: ContributionStatus.VERIFIED,
                    },
                  ],
                });
              }

              if (select) {
                return Promise.resolve({
                  id: 'cycle-1',
                  status: CycleStatus.OPEN,
                  state: CycleState.COLLECTING,
                  selectedWinnerUserId:
                    winnerSelectionTiming === 'BEFORE_COLLECTION'
                      ? 'user-member'
                      : null,
                  group: {
                    rules: {
                      winnerSelectionTiming,
                    },
                  },
                  contributions: [
                    { status: ContributionStatus.VERIFIED },
                    { status: ContributionStatus.VERIFIED },
                  ],
                });
              }

              return Promise.resolve(null);
            },
          ),
        update: jest.fn(({ data }: { data: { state: CycleState } }) => {
          updatedStates.push(data.state);
          return Promise.resolve({});
        }),
      },
      contribution: {
        count: jest.fn().mockResolvedValue(2),
        findMany: jest.fn().mockResolvedValue([
          {
            id: 'contribution-1',
            groupId: 'group-1',
            cycleId: 'cycle-1',
            userId: 'user-admin',
            amount: 500,
            status: ContributionStatus.VERIFIED,
            paymentMethod: null,
            proofFileKey: null,
            paymentRef: null,
            note: null,
            submittedAt: null,
            confirmedByUserId: null,
            confirmedAt: new Date('2026-03-01T00:00:00.000Z'),
            rejectedByUserId: null,
            rejectedAt: null,
            lateMarkedAt: null,
            user: {
              id: 'user-admin',
              fullName: 'Admin',
              phone: '+251911111111',
            },
          },
          {
            id: 'contribution-2',
            groupId: 'group-1',
            cycleId: 'cycle-1',
            userId: 'user-member',
            amount: 500,
            status: ContributionStatus.VERIFIED,
            paymentMethod: null,
            proofFileKey: null,
            paymentRef: null,
            note: null,
            submittedAt: null,
            confirmedByUserId: null,
            confirmedAt: new Date('2026-03-01T00:00:00.000Z'),
            rejectedByUserId: null,
            rejectedAt: null,
            lateMarkedAt: null,
            user: {
              id: 'user-member',
              fullName: 'Member',
              phone: '+251922222222',
            },
          },
        ]),
        update: jest.fn(),
      },
      ledgerEntry: {
        findFirst: jest.fn().mockResolvedValue(null),
        create: jest.fn(),
      },
      equbMember: {
        findMany: jest.fn().mockResolvedValue([]),
      },
    };

    const prismaMock = {
      $transaction: jest.fn((callback: (tx: typeof txMock) => unknown) =>
        callback(txMock),
      ),
    } as unknown as PrismaService;

    const service = new ContributionsService(
      prismaMock,
      { log: jest.fn() } as never,
      {
        notifyUser: jest.fn(),
        notifyGroupAdmins: jest.fn(),
      } as never,
      {
        applyEvent: jest.fn(),
      } as never,
      { emitTurnEvent: jest.fn() } as never,
    );

    return { service, updatedStates };
  }

  it('moves completed collection to READY_FOR_PAYOUT when winner was already selected', async () => {
    const { service, updatedStates } = createService('BEFORE_COLLECTION');

    await service.evaluateCycleCollection(currentUser, 'cycle-1');

    expect(updatedStates).toContain(CycleState.READY_FOR_PAYOUT);
  });

  it('moves completed collection to READY_FOR_WINNER_SELECTION when winner is still pending', async () => {
    const { service, updatedStates } = createService('AFTER_COLLECTION');

    await service.evaluateCycleCollection(currentUser, 'cycle-1');

    expect(updatedStates).toContain(CycleState.READY_FOR_WINNER_SELECTION);
  });
});

describe('ContributionsService.verifyContribution realtime emissions', () => {
  const currentUser: AuthenticatedUser = {
    id: 'user-admin',
    phone: '+251911111111',
  };

  it('emits contribution and turn realtime events after verification', async () => {
    const contributionRecord = {
      id: 'contribution-1',
      groupId: 'group-1',
      cycleId: 'cycle-1',
      userId: 'user-member',
      amount: 500,
      status: ContributionStatus.VERIFIED,
      paymentMethod: null,
      proofFileKey: null,
      paymentRef: null,
      note: null,
      submittedAt: null,
      confirmedAt: new Date('2026-03-09T00:00:00.000Z'),
      confirmedByUserId: currentUser.id,
      rejectedAt: null,
      rejectedByUserId: null,
      rejectReason: null,
      lateMarkedAt: null,
      createdAt: new Date('2026-03-09T00:00:00.000Z'),
      user: {
        id: 'user-member',
        fullName: 'Member',
        phone: '+251922222222',
      },
    };
    const txMock = {
      contribution: {
        findUnique: jest.fn().mockResolvedValue({
          ...contributionRecord,
          status: ContributionStatus.PAID_SUBMITTED,
        }),
        update: jest.fn().mockResolvedValue(contributionRecord),
        count: jest.fn().mockResolvedValue(2),
        findMany: jest.fn().mockResolvedValue([
          { id: 'contribution-1', status: ContributionStatus.VERIFIED },
          { id: 'contribution-2', status: ContributionStatus.VERIFIED },
        ]),
      },
      ledgerEntry: {
        create: jest.fn().mockResolvedValue({}),
      },
      equbCycle: {
        findUnique: jest.fn().mockResolvedValue({
          id: 'cycle-1',
          dueAt: new Date('3026-03-12T00:00:00.000Z'),
          status: CycleStatus.OPEN,
          state: CycleState.COLLECTING,
          selectedWinnerUserId: null,
          group: {
            rules: {
              graceDays: 0,
              winnerSelectionTiming: 'AFTER_COLLECTION',
            },
          },
          contributions: [
            { status: ContributionStatus.VERIFIED },
            { status: ContributionStatus.VERIFIED },
          ],
        }),
        update: jest.fn().mockResolvedValue({}),
      },
      contributionReceipt: {
        upsert: jest.fn(),
      },
    };
    const prismaMock = {
      $transaction: jest.fn(async (callback: (tx: typeof txMock) => unknown) =>
        callback(txMock),
      ),
    } as unknown as PrismaService;
    const realtimeService = {
      emitTurnEvent: jest.fn(),
    };
    const reputationService = {
      applyEvent: jest.fn(),
    };
    const service = new ContributionsService(
      prismaMock,
      { log: jest.fn() } as never,
      {
        notifyUser: jest.fn(),
        notifyGroupAdmins: jest.fn(),
      } as never,
      reputationService as never,
      realtimeService as never,
    );

    await service.verifyContribution(currentUser, 'contribution-1');

    expect(realtimeService.emitTurnEvent).toHaveBeenNthCalledWith(
      1,
      'group-1',
      'cycle-1',
      expect.objectContaining({
        eventType: 'contribution.updated',
        entityId: 'contribution-1',
      }),
    );
    expect(realtimeService.emitTurnEvent).toHaveBeenNthCalledWith(
      2,
      'group-1',
      'cycle-1',
      expect.objectContaining({
        eventType: 'turn.updated',
        entityId: 'cycle-1',
      }),
    );
    expect(reputationService.applyEvent).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({
        eventType: 'ON_TIME_PAYMENT_VERIFIED',
        userId: 'user-member',
      }),
    );
  });

  it('marks pending contributions as paid only through CASH_ACK manual flow', async () => {
    const contributionRecord = {
      id: 'contribution-1',
      groupId: 'group-1',
      cycleId: 'cycle-1',
      userId: 'user-member',
      amount: 500,
      status: ContributionStatus.VERIFIED,
      paymentMethod: GroupPaymentMethod.CASH_ACK,
      proofFileKey: null,
      paymentRef: null,
      note: 'Marked paid manually by admin.',
      submittedAt: new Date('2026-03-09T00:00:00.000Z'),
      confirmedAt: new Date('2026-03-09T00:00:00.000Z'),
      confirmedByUserId: currentUser.id,
      rejectedAt: null,
      rejectedByUserId: null,
      rejectReason: null,
      lateMarkedAt: null,
      createdAt: new Date('2026-03-09T00:00:00.000Z'),
      user: {
        id: 'user-member',
        fullName: 'Member',
        phone: '+251922222222',
      },
    };
    const txMock = {
      contribution: {
        findUnique: jest.fn().mockResolvedValue({
          ...contributionRecord,
          status: ContributionStatus.PENDING,
          paymentMethod: null,
          confirmedAt: null,
          confirmedByUserId: null,
          submittedAt: null,
          note: null,
        }),
        update: jest.fn().mockResolvedValue(contributionRecord),
        count: jest.fn().mockResolvedValue(2),
        findMany: jest.fn().mockResolvedValue([
          { id: 'contribution-1', status: ContributionStatus.VERIFIED },
          { id: 'contribution-2', status: ContributionStatus.VERIFIED },
        ]),
      },
      ledgerEntry: {
        create: jest.fn().mockResolvedValue({}),
      },
      contributionReceipt: {
        upsert: jest.fn().mockResolvedValue({}),
      },
      equbCycle: {
        findUnique: jest.fn().mockResolvedValue({
          id: 'cycle-1',
          dueAt: new Date('3026-03-12T00:00:00.000Z'),
          status: CycleStatus.OPEN,
          state: CycleState.COLLECTING,
          selectedWinnerUserId: null,
          group: {
            rules: {
              graceDays: 0,
              paymentMethods: [GroupPaymentMethod.CASH_ACK],
              winnerSelectionTiming: 'AFTER_COLLECTION',
            },
          },
          contributions: [
            { status: ContributionStatus.VERIFIED },
            { status: ContributionStatus.VERIFIED },
          ],
        }),
        update: jest.fn().mockResolvedValue({}),
      },
    };
    const prismaMock = {
      $transaction: jest.fn(async (callback: (tx: typeof txMock) => unknown) =>
        callback(txMock),
      ),
    } as unknown as PrismaService;
    const realtimeService = {
      emitTurnEvent: jest.fn(),
    };
    const reputationService = {
      applyEvent: jest.fn(),
    };
    const service = new ContributionsService(
      prismaMock,
      { log: jest.fn() } as never,
      {
        notifyUser: jest.fn(),
        notifyGroupAdmins: jest.fn(),
      } as never,
      reputationService as never,
      realtimeService as never,
    );

    await service.markContributionPaid(currentUser, 'contribution-1');

    expect(txMock.contribution.update).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          status: ContributionStatus.VERIFIED,
          paymentMethod: GroupPaymentMethod.CASH_ACK,
        }),
      }),
    );
    expect(realtimeService.emitTurnEvent).toHaveBeenCalled();
    expect(reputationService.applyEvent).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({
        eventType: 'ON_TIME_PAYMENT_VERIFIED',
        userId: 'user-member',
      }),
    );
  });
});
