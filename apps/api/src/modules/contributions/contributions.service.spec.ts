import {
  ContributionStatus,
  CycleState,
  CycleStatus,
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
                      strictCollection: true,
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
                      strictCollection: true,
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
