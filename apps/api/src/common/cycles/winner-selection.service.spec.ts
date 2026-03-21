import { ConflictException } from '@nestjs/common';
import {
  AuctionStatus,
  CycleState,
  CycleStatus,
  GroupRulePayoutMode,
} from '@prisma/client';
import { RoundEligibilityService } from './round-eligibility.service';
import { WinnerSelectionService } from './winner-selection.service';

describe('WinnerSelectionService', () => {
  const roundEligibilityService = {
    getRoundParticipantUserIds: jest.fn(),
    listCompletedWinnerUserIds: jest.fn(),
    computeRemainingEligibleWinnerUserIds: jest.fn(),
  } as unknown as RoundEligibilityService;

  const service = new WinnerSelectionService(roundEligibilityService);

  const baseCycle = {
    id: 'cycle-1',
    groupId: 'group-1',
    roundId: 'round-1',
    status: CycleStatus.OPEN,
    cycleNo: 2,
    createdAt: new Date('2026-03-07T00:00:00.000Z'),
    scheduledPayoutUserId: 'user-1',
    finalPayoutUserId: 'user-1',
    selectedWinnerUserId: null,
    winnerSelectedAt: null,
    selectionMethod: null,
    selectionMetadata: null,
    auctionStatus: AuctionStatus.NONE,
    winningBidAmount: null,
    winningBidUserId: null,
    state: CycleState.SETUP,
    group: {
      rules: {
        payoutMode: GroupRulePayoutMode.LOTTERY,
      },
    },
  };

  const txMock = {
    equbCycle: {
      findUnique: jest.fn(),
      updateMany: jest.fn(),
    },
    equbMember: {
      findMany: jest.fn(),
    },
    cycleBid: {
      findFirst: jest.fn(),
    },
    cycleAuction: {
      updateMany: jest.fn(),
    },
  };

  beforeEach(() => {
    jest.clearAllMocks();
    txMock.equbCycle.findUnique.mockResolvedValue(baseCycle);
    txMock.equbCycle.updateMany.mockResolvedValue({ count: 1 });
    txMock.equbMember.findMany.mockResolvedValue([
      { userId: 'user-1', payoutPosition: 1, createdAt: new Date() },
      { userId: 'user-2', payoutPosition: 2, createdAt: new Date() },
    ]);
    (
      roundEligibilityService.getRoundParticipantUserIds as jest.Mock
    ).mockResolvedValue(['user-1', 'user-2']);
    (
      roundEligibilityService.listCompletedWinnerUserIds as jest.Mock
    ).mockResolvedValue([]);
    (
      roundEligibilityService.computeRemainingEligibleWinnerUserIds as jest.Mock
    ).mockReturnValue(['user-1', 'user-2']);
  });

  it('allows the final remaining member to be selected', async () => {
    (
      roundEligibilityService.listCompletedWinnerUserIds as jest.Mock
    ).mockResolvedValue(['user-1']);
    (
      roundEligibilityService.computeRemainingEligibleWinnerUserIds as jest.Mock
    ).mockReturnValue(['user-2']);

    txMock.equbCycle.findUnique.mockResolvedValue({
      ...baseCycle,
      group: {
        rules: {
          payoutMode: GroupRulePayoutMode.ROTATION,
        },
      },
    });

    const result = await service.selectWinner(txMock as never, {
      cycleId: 'cycle-1',
      actorUserId: 'admin-1',
    });

    expect(result.winnerUserId).toBe('user-2');
    expect(txMock.equbCycle.updateMany).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          selectedWinnerUserId: 'user-2',
          finalPayoutUserId: 'user-2',
        }),
      }),
    );
  });

  it('rejects a draw when every participant already received payout', async () => {
    (
      roundEligibilityService.listCompletedWinnerUserIds as jest.Mock
    ).mockResolvedValue(['user-1', 'user-2']);
    (
      roundEligibilityService.computeRemainingEligibleWinnerUserIds as jest.Mock
    ).mockReturnValue([]);

    await expect(
      service.selectWinner(txMock as never, {
        cycleId: 'cycle-1',
        actorUserId: 'admin-1',
      }),
    ).rejects.toThrow(ConflictException);
  });

  it('rejects a manual winner who already received payout in the round', async () => {
    txMock.equbCycle.findUnique.mockResolvedValue({
      ...baseCycle,
      group: {
        rules: {
          payoutMode: GroupRulePayoutMode.DECISION,
        },
      },
    });
    (
      roundEligibilityService.listCompletedWinnerUserIds as jest.Mock
    ).mockResolvedValue(['user-1']);
    (
      roundEligibilityService.computeRemainingEligibleWinnerUserIds as jest.Mock
    ).mockReturnValue(['user-2']);

    await expect(
      service.selectWinner(txMock as never, {
        cycleId: 'cycle-1',
        actorUserId: 'admin-1',
        requestedWinnerUserId: 'user-1',
      }),
    ).rejects.toThrow('Selected user is not eligible for payout winner selection');
  });
});
