import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  AuctionStatus,
  CycleState,
  CycleStatus,
  GroupRulePayoutMode,
  MemberStatus,
  Prisma,
} from '@prisma/client';
import { randomInt } from 'crypto';

import {
  PARTICIPATING_MEMBER_STATUSES,
  VERIFIED_MEMBER_STATUSES,
} from '../membership/member-status.util';
import { RoundEligibilityService } from './round-eligibility.service';

type WinnerSelectionTx = Prisma.TransactionClient;

export type WinnerSelectionResult = {
  cycleId: string;
  groupId: string;
  winnerUserId: string;
  payoutMode: GroupRulePayoutMode;
  selectionMetadata: Prisma.JsonValue | null;
};

@Injectable()
export class WinnerSelectionService {
  constructor(
    private readonly roundEligibilityService: RoundEligibilityService,
  ) {}

  async selectWinner(
    tx: WinnerSelectionTx,
    args: {
      cycleId: string;
      actorUserId: string;
      requestedWinnerUserId?: string | null;
    },
  ): Promise<WinnerSelectionResult> {
    const cycle = await tx.equbCycle.findUnique({
      where: { id: args.cycleId },
      select: {
        id: true,
        groupId: true,
        roundId: true,
        status: true,
        cycleNo: true,
        createdAt: true,
        scheduledPayoutUserId: true,
        finalPayoutUserId: true,
        selectedWinnerUserId: true,
        winnerSelectedAt: true,
        selectionMethod: true,
        selectionMetadata: true,
        auctionStatus: true,
        winningBidAmount: true,
        winningBidUserId: true,
        group: {
          select: {
            rules: {
              select: {
                payoutMode: true,
                requiresMemberVerification: true,
              },
            },
          },
        },
      },
    });

    if (!cycle) {
      throw new NotFoundException('Cycle not found');
    }

    if (cycle.status !== CycleStatus.OPEN) {
      throw new BadRequestException(
        'Winner can only be selected for an open cycle',
      );
    }

    if (!cycle.group.rules) {
      throw new BadRequestException(
        'Group rules are required before winner selection',
      );
    }

    if (cycle.selectedWinnerUserId) {
      throw new ConflictException(
        'Winner has already been selected for this cycle',
      );
    }

    const payoutMode = cycle.group.rules.payoutMode;
    const eligibleStatuses = this.resolveEligibleStatuses(
      cycle.group.rules.requiresMemberVerification,
    );
    const eligibleMembers = await tx.equbMember.findMany({
      where: {
        groupId: cycle.groupId,
        status: {
          in: eligibleStatuses,
        },
      },
      select: {
        userId: true,
        payoutPosition: true,
        createdAt: true,
      },
      orderBy: [{ payoutPosition: 'asc' }, { createdAt: 'asc' }],
    });

    const eligibleUserIds = [
      ...new Set(eligibleMembers.map((member) => member.userId)),
    ];
    const roundParticipantUserIds =
      await this.roundEligibilityService.getRoundParticipantUserIds(tx, {
        roundId: cycle.roundId,
        fallbackUserIds: eligibleUserIds,
      });
    const completedWinnerUserIds =
      await this.roundEligibilityService.listCompletedWinnerUserIds(
        tx,
        cycle.roundId,
      );
    const remainingEligibleWinnerUserIds =
      this.roundEligibilityService.computeRemainingEligibleWinnerUserIds(
        roundParticipantUserIds,
        completedWinnerUserIds,
      );

    if (remainingEligibleWinnerUserIds.length === 0) {
      throw new ConflictException(
        'All eligible members have already received payout in this Equb round',
      );
    }

    const selectedAt = new Date();
    let winnerUserId: string;
    let selectionMetadata: Prisma.InputJsonValue;
    let winningBidAmount: number | null = null;
    let winningBidUserId: string | null = null;
    let auctionStatus = cycle.auctionStatus;

    switch (payoutMode) {
      case GroupRulePayoutMode.LOTTERY: {
        const winnerIndex = randomInt(remainingEligibleWinnerUserIds.length);
        winnerUserId = remainingEligibleWinnerUserIds[winnerIndex];
        selectionMetadata = {
          mode: GroupRulePayoutMode.LOTTERY,
          winnerIndex,
          poolSize: remainingEligibleWinnerUserIds.length,
          completedWinnerCount: completedWinnerUserIds.length,
          selectedAt: selectedAt.toISOString(),
        };
        break;
      }
      case GroupRulePayoutMode.AUCTION: {
        if (
          cycle.auctionStatus === AuctionStatus.NONE &&
          cycle.winningBidUserId == null
        ) {
          throw new BadRequestException(
            'Auction must be opened before selecting auction winner',
          );
        }

        const topBid = await tx.cycleBid.findFirst({
          where: {
            cycleId: cycle.id,
            userId: {
              in: remainingEligibleWinnerUserIds,
            },
          },
          orderBy: [{ amount: 'desc' }, { createdAt: 'asc' }],
          select: {
            id: true,
            userId: true,
            amount: true,
            createdAt: true,
          },
        });

        winnerUserId = topBid?.userId ?? remainingEligibleWinnerUserIds[0];
        winningBidAmount = topBid?.amount ?? null;
        winningBidUserId = topBid?.userId ?? null;
        auctionStatus = AuctionStatus.CLOSED;

        if (cycle.auctionStatus === AuctionStatus.OPEN) {
          await tx.cycleAuction.updateMany({
            where: {
              cycleId: cycle.id,
              status: AuctionStatus.OPEN,
            },
            data: {
              status: AuctionStatus.CLOSED,
              closedAt: selectedAt,
            },
          });
        }

        selectionMetadata = {
          mode: GroupRulePayoutMode.AUCTION,
          winningBidId: topBid?.id ?? null,
          winningBidAmount,
          winningBidUserId,
          fallbackWinnerUserId: topBid ? null : remainingEligibleWinnerUserIds[0],
          eligibleBidderCount: remainingEligibleWinnerUserIds.length,
          selectedAt: selectedAt.toISOString(),
        };
        break;
      }
      case GroupRulePayoutMode.ROTATION: {
        winnerUserId = remainingEligibleWinnerUserIds[0];
        selectionMetadata = {
          mode: GroupRulePayoutMode.ROTATION,
          rotationIndex: roundParticipantUserIds.indexOf(winnerUserId),
          eligibleCount: remainingEligibleWinnerUserIds.length,
          completedWinnerCount: completedWinnerUserIds.length,
          selectedAt: selectedAt.toISOString(),
        };
        break;
      }
      case GroupRulePayoutMode.DECISION: {
        const requestedWinnerUserId = args.requestedWinnerUserId?.trim();
        if (!requestedWinnerUserId) {
          throw new BadRequestException(
            'userId is required for DECISION payout mode',
          );
        }

        if (!remainingEligibleWinnerUserIds.includes(requestedWinnerUserId)) {
          throw new BadRequestException(
            'Selected user is not eligible for payout winner selection',
          );
        }

        winnerUserId = requestedWinnerUserId;
        selectionMetadata = {
          mode: GroupRulePayoutMode.DECISION,
          decidedByUserId: args.actorUserId,
          selectedAt: selectedAt.toISOString(),
        };
        break;
      }
      default: {
        throw new BadRequestException('Unsupported payout mode');
      }
    }

    try {
      const updateResult = await tx.equbCycle.updateMany({
        where: {
          id: cycle.id,
          selectedWinnerUserId: null,
          status: CycleStatus.OPEN,
          state: {
            in: [CycleState.SETUP, CycleState.READY_FOR_WINNER_SELECTION],
          },
        },
        data: {
          finalPayoutUserId: winnerUserId,
          selectedWinnerUserId: winnerUserId,
          winnerSelectedAt: selectedAt,
          selectionMethod: payoutMode,
          selectionMetadata,
          winningBidAmount,
          winningBidUserId,
          auctionStatus,
        },
      });

      if (updateResult.count !== 1) {
        throw new ConflictException(
          'Winner has already been selected for this cycle',
        );
      }
    } catch (error) {
      if (
        error instanceof Prisma.PrismaClientKnownRequestError &&
        error.code === 'P2002'
      ) {
        throw new ConflictException(
          'Selected user has already received payout in this Equb round',
        );
      }
      throw error;
    }

    return {
      cycleId: cycle.id,
      groupId: cycle.groupId,
      winnerUserId,
      payoutMode,
      selectionMetadata: selectionMetadata as Prisma.JsonValue,
    };
  }

  private resolveEligibleStatuses(
    requiresMemberVerification: boolean,
  ): MemberStatus[] {
    return requiresMemberVerification
      ? VERIFIED_MEMBER_STATUSES
      : PARTICIPATING_MEMBER_STATUSES;
  }
}
