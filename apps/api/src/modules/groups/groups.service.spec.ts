import {
  ContributionStatus,
  CycleState,
  CycleStatus,
  GroupRuleFrequency,
  GroupRulePayoutMode,
  GroupStatus,
  MemberStatus,
  PayoutMode,
  StartPolicy,
  WinnerSelectionTiming,
} from '@prisma/client';

import { DateService } from '../../common/date/date.service';
import type { PrismaService } from '../../common/prisma/prisma.service';
import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import { WinnerSelectionService } from '../../common/cycles/winner-selection.service';
import { GroupsService } from './groups.service';

describe('GroupsService.startCycle', () => {
  const currentUser: AuthenticatedUser = {
    id: 'user-admin',
    phone: '+251911111111',
  };

  function createService(winnerSelectionTiming: WinnerSelectionTiming) {
    const txMock = {
      equbGroup: {
        findUnique: jest.fn().mockResolvedValue({
          id: 'group-1',
          status: GroupStatus.ACTIVE,
          contributionAmount: 500,
          frequency: GroupRuleFrequency.MONTHLY,
          startDate: new Date('2026-03-01T00:00:00.000Z'),
          timezone: 'Africa/Addis_Ababa',
          rules: {
            contributionAmount: 500,
            requiresMemberVerification: false,
            frequency: GroupRuleFrequency.MONTHLY,
            customIntervalDays: null,
            roundSize: 2,
            startPolicy: StartPolicy.WHEN_FULL,
            startAt: null,
            minToStart: null,
            payoutMode: GroupRulePayoutMode.LOTTERY,
            winnerSelectionTiming,
          },
        }),
      },
      equbCycle: {
        findFirst: jest
          .fn()
          .mockResolvedValueOnce(null)
          .mockResolvedValueOnce(null),
        create: jest.fn().mockResolvedValue({
          id: 'cycle-1',
          dueDate: new Date('2026-03-01T00:00:00.000Z'),
        }),
        update: jest.fn().mockResolvedValue({}),
      },
      equbMember: {
        findMany: jest.fn().mockResolvedValue([
          {
            userId: 'user-admin',
            payoutPosition: 1,
            createdAt: new Date('2026-03-01T00:00:00.000Z'),
          },
          {
            userId: 'user-member',
            payoutPosition: 2,
            createdAt: new Date('2026-03-01T00:00:00.000Z'),
          },
        ]),
      },
      equbRound: {
        findFirst: jest.fn().mockResolvedValue(null),
        create: jest.fn().mockResolvedValue({ id: 'round-1' }),
      },
      contribution: {
        createMany: jest.fn().mockResolvedValue({ count: 2 }),
      },
    };

    const prismaMock = {
      $transaction: jest.fn((callback: (tx: typeof txMock) => unknown) =>
        callback(txMock),
      ),
    } as unknown as PrismaService;

    const winnerSelectionService = {
      selectWinner: jest.fn().mockResolvedValue({
        cycleId: 'cycle-1',
        groupId: 'group-1',
        winnerUserId: 'user-member',
        payoutMode: GroupRulePayoutMode.LOTTERY,
        selectionMetadata: null,
      }),
    } as unknown as WinnerSelectionService;

    const service = new GroupsService(
      prismaMock,
      { log: jest.fn() } as never,
      {} as never,
      new DateService(),
      { notifyGroupAdmins: jest.fn() } as never,
      winnerSelectionService,
    );

    jest.spyOn(service, 'getCycleById').mockResolvedValue({
      id: 'cycle-1',
      groupId: 'group-1',
      roundId: 'round-1',
      cycleNo: 1,
      dueDate: new Date('2026-03-01T00:00:00.000Z'),
      dueAt: new Date('2026-03-01T00:00:00.000Z'),
      state: CycleState.COLLECTING,
      scheduledPayoutUserId: 'user-admin',
      finalPayoutUserId: 'user-member',
      selectedWinnerUserId:
        winnerSelectionTiming === WinnerSelectionTiming.BEFORE_COLLECTION
          ? 'user-member'
          : null,
      winnerSelectedAt: null,
      selectionMethod: null,
      selectionMetadata: null,
      payoutUserId: 'user-member',
      auctionStatus: 'NONE' as never,
      winningBidAmount: null,
      winningBidUserId: null,
      payoutSentAt: null,
      payoutSentByUserId: null,
      payoutReceivedConfirmedAt: null,
      payoutReceivedConfirmedByUserId: null,
      status: CycleStatus.OPEN,
      createdByUserId: currentUser.id,
      createdAt: new Date('2026-03-01T00:00:00.000Z'),
      scheduledPayoutUser: {
        id: 'user-admin',
        fullName: 'Admin',
        phone: '+251911111111',
      },
      finalPayoutUser: {
        id: 'user-member',
        fullName: 'Member',
        phone: '+251922222222',
      },
      selectedWinnerUser: null,
      winningBidUser: null,
      payoutUser: {
        id: 'user-member',
        fullName: 'Member',
        phone: '+251922222222',
      },
    });

    return {
      service,
      txMock,
      winnerSelectionService,
    };
  }

  it('selects winner immediately when timing is BEFORE_COLLECTION', async () => {
    const { service, txMock, winnerSelectionService } = createService(
      WinnerSelectionTiming.BEFORE_COLLECTION,
    );

    await service.startCycle(currentUser, 'group-1');

    expect(winnerSelectionService.selectWinner).toHaveBeenCalledWith(txMock, {
      cycleId: 'cycle-1',
      actorUserId: currentUser.id,
    });
    expect(txMock.equbCycle.update).toHaveBeenCalledWith({
      where: { id: 'cycle-1' },
      data: {
        state: CycleState.COLLECTING,
      },
    });
  });

  it('does not select winner at start when timing is AFTER_COLLECTION', async () => {
    const { service, txMock, winnerSelectionService } = createService(
      WinnerSelectionTiming.AFTER_COLLECTION,
    );

    await service.startCycle(currentUser, 'group-1');

    expect(winnerSelectionService.selectWinner).not.toHaveBeenCalled();
    expect(txMock.equbCycle.update).toHaveBeenCalledWith({
      where: { id: 'cycle-1' },
      data: {
        state: CycleState.COLLECTING,
      },
    });
  });
});
