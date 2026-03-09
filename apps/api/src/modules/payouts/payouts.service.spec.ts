import {
  CycleState,
  CycleStatus,
  GroupRulePayoutMode,
  PayoutStatus,
} from '@prisma/client';

import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import type { PrismaService } from '../../common/prisma/prisma.service';
import { PayoutsService } from './payouts.service';

describe('PayoutsService realtime emissions', () => {
  const currentUser: AuthenticatedUser = {
    id: 'admin-1',
    phone: '+251911111111',
  };

  it('emits winner-selected realtime events after selecting a winner', async () => {
    const prismaMock = {
      $transaction: jest.fn(
        async (callback: (tx: Record<string, unknown>) => unknown) =>
          callback({
            equbCycle: {
              findUnique: jest.fn().mockResolvedValue({
                id: 'cycle-1',
                groupId: 'group-1',
                status: CycleStatus.OPEN,
                state: CycleState.READY_FOR_WINNER_SELECTION,
                selectedWinnerUserId: null,
              }),
              updateMany: jest.fn().mockResolvedValue({ count: 1 }),
              update: jest.fn().mockResolvedValue({}),
            },
          }),
      ),
    } as unknown as PrismaService;
    const realtimeService = {
      emitTurnEvent: jest.fn(),
    };
    const service = new PayoutsService(
      prismaMock,
      { log: jest.fn() } as never,
      {
        notifyUser: jest.fn(),
        notifyGroupMembers: jest.fn(),
      } as never,
      {
        getCycleById: jest.fn().mockResolvedValue({ id: 'cycle-1' }),
      } as never,
      {} as never,
      {
        selectWinner: jest.fn().mockResolvedValue({
          cycleId: 'cycle-1',
          groupId: 'group-1',
          winnerUserId: 'member-1',
          payoutMode: GroupRulePayoutMode.LOTTERY,
          selectionMetadata: null,
        }),
      } as never,
      realtimeService as never,
    );

    await service.selectWinner(currentUser, 'cycle-1', {});

    expect(realtimeService.emitTurnEvent).toHaveBeenNthCalledWith(
      1,
      'group-1',
      'cycle-1',
      expect.objectContaining({
        eventType: 'winner.selected',
        entityId: 'member-1',
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
  });

  it('emits payout realtime events after payout send', async () => {
    const payoutRecord = {
      id: 'payout-1',
      groupId: 'group-1',
      cycleId: 'cycle-1',
      toUserId: 'member-1',
      amount: 1000,
      status: PayoutStatus.PENDING,
      proofFileKey: null,
      paymentRef: null,
      note: null,
      createdByUserId: currentUser.id,
      createdAt: new Date('2026-03-09T00:00:00.000Z'),
      confirmedByUserId: null,
      confirmedAt: null,
      toUser: {
        id: 'member-1',
        fullName: 'Member',
        phone: '+251922222222',
      },
    };
    const txMock = {
      equbCycle: {
        findUnique: jest.fn().mockResolvedValue({
          id: 'cycle-1',
          groupId: 'group-1',
          roundId: 'round-1',
          selectedWinnerUserId: 'member-1',
          scheduledPayoutUserId: 'member-1',
          finalPayoutUserId: 'member-1',
          selectionMethod: GroupRulePayoutMode.LOTTERY,
          selectionMetadata: null,
          winningBidAmount: null,
          winningBidUserId: null,
          payoutSentAt: null,
          status: CycleStatus.OPEN,
          state: CycleState.READY_FOR_PAYOUT,
          group: {
            contributionAmount: 1000,
          },
          payout: null,
        }),
        update: jest.fn().mockResolvedValue({}),
      },
      contribution: {
        aggregate: jest.fn().mockResolvedValue({
          _sum: { amount: 1000 },
        }),
      },
      payout: {
        create: jest.fn().mockResolvedValue(payoutRecord),
      },
      ledgerEntry: {
        findFirst: jest.fn().mockResolvedValue(null),
        create: jest.fn().mockResolvedValue({}),
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
    const service = new PayoutsService(
      prismaMock,
      { log: jest.fn() } as never,
      {
        notifyUser: jest.fn(),
      } as never,
      {} as never,
      {
        listCompletedWinnerUserIds: jest.fn().mockResolvedValue([]),
      } as never,
      {} as never,
      realtimeService as never,
    );

    await service.disbursePayout(currentUser, 'cycle-1', {});

    expect(realtimeService.emitTurnEvent).toHaveBeenNthCalledWith(
      1,
      'group-1',
      'cycle-1',
      expect.objectContaining({
        eventType: 'payout.updated',
        entityId: 'payout-1',
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
  });
});
