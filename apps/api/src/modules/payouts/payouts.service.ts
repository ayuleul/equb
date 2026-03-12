import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import {
  AuctionStatus,
  ContributionStatus,
  CycleState,
  CycleStatus,
  LedgerEntryType,
  NotificationType,
  PayoutStatus,
  Prisma,
} from '@prisma/client';

import { AuditService } from '../../common/audit/audit.service';
import { RoundEligibilityService } from '../../common/cycles/round-eligibility.service';
import { WinnerSelectionService } from '../../common/cycles/winner-selection.service';
import { PARTICIPATING_MEMBER_STATUSES } from '../../common/membership/member-status.util';
import { PrismaService } from '../../common/prisma/prisma.service';
import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import { isPayoutProofKeyScopedTo } from '../contributions/utils/proof-key.util';
import { GroupCycleResponseDto } from '../groups/entities/groups.entities';
import { GroupsService } from '../groups/groups.service';
import { NotificationsService } from '../notifications/notifications.service';
import { ReputationService } from '../reputation/reputation.service';
import { RealtimeService } from '../realtime/realtime.service';
import { CloseCycleDto } from './dto/close-cycle.dto';
import { ConfirmPayoutDto } from './dto/confirm-payout.dto';
import { CreatePayoutDto } from './dto/create-payout.dto';
import { DisbursePayoutDto } from './dto/disburse-payout.dto';
import { SelectWinnerDto } from './dto/select-winner.dto';
import {
  CloseCycleResponseDto,
  PayoutResponseDto,
} from './entities/payouts.entities';
import { calculateStrictPayoutEligibility } from './utils/strict-payout.util';

type PayoutWithUser = Prisma.PayoutGetPayload<{
  include: {
    toUser: {
      select: {
        id: true;
        fullName: true;
        phone: true;
      };
    };
  };
}>;

type OptionalLedgerEntryDelegate = {
  create(args: Prisma.LedgerEntryCreateArgs): Promise<unknown>;
};

type TxCompatibility = Prisma.TransactionClient & {
  ledgerEntry?: OptionalLedgerEntryDelegate;
};

@Injectable()
export class PayoutsService {
  private readonly logger = new Logger(PayoutsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly auditService: AuditService,
    private readonly notificationsService: NotificationsService,
    private readonly groupsService: GroupsService,
    private readonly roundEligibilityService: RoundEligibilityService,
    private readonly winnerSelectionService: WinnerSelectionService,
    private readonly reputationService: ReputationService,
    private readonly realtimeService: RealtimeService,
  ) {}

  async selectWinner(
    currentUser: AuthenticatedUser,
    cycleId: string,
    dto: SelectWinnerDto,
  ): Promise<GroupCycleResponseDto> {
    const selection = await this.prisma.$transaction(async (tx) => {
      const cycle = await tx.equbCycle.findUnique({
        where: { id: cycleId },
        select: {
          id: true,
          groupId: true,
          status: true,
          state: true,
          selectedWinnerUserId: true,
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

      if (cycle.state !== CycleState.READY_FOR_WINNER_SELECTION) {
        throw new BadRequestException(
          'Cycle must be READY_FOR_WINNER_SELECTION before selecting winner',
        );
      }

      if (cycle.selectedWinnerUserId) {
        throw new ConflictException(
          'Winner has already been selected for this cycle',
        );
      }

      const selectionLock = await tx.equbCycle.updateMany({
        where: {
          id: cycle.id,
          status: CycleStatus.OPEN,
          state: CycleState.READY_FOR_WINNER_SELECTION,
          selectedWinnerUserId: null,
        },
        data: {
          state: CycleState.SETUP,
        },
      });

      if (selectionLock.count !== 1) {
        throw new ConflictException(
          'Winner selection is already in progress or completed for this cycle',
        );
      }

      const result = await this.winnerSelectionService.selectWinner(tx, {
        cycleId: cycle.id,
        actorUserId: currentUser.id,
        requestedWinnerUserId: dto.userId,
      });

      await tx.equbCycle.update({
        where: { id: cycle.id },
        data: {
          state: CycleState.READY_FOR_PAYOUT,
        },
      });

      return result;
    });

    await this.auditService.log(
      'WINNER_SELECTED',
      currentUser.id,
      {
        cycleId: selection.cycleId,
        winnerUserId: selection.winnerUserId,
        selectionMethod: selection.payoutMode,
        selectionMetadata: selection.selectionMetadata,
      },
      selection.groupId,
    );

    await this.notificationsService.notifyUser(selection.winnerUserId, {
      type: NotificationType.LOTTERY_WINNER,
      title: 'Winner selected',
      body: 'You were selected for this turn payout.',
      groupId: selection.groupId,
      eventId: `SELECT_${selection.cycleId}_WINNER`,
      data: {
        groupId: selection.groupId,
        cycleId: selection.cycleId,
        selectionMethod: selection.payoutMode,
        route: `/groups/${selection.groupId}/cycles/${selection.cycleId}/payout`,
      },
    });

    await this.notificationsService.notifyGroupMembers(
      selection.groupId,
      {
        type: NotificationType.LOTTERY_ANNOUNCEMENT,
        title: 'Winner announced',
        body: 'A turn winner has been selected.',
        groupId: selection.groupId,
        eventId: `SELECT_${selection.cycleId}_ANNOUNCEMENT`,
        data: {
          groupId: selection.groupId,
          cycleId: selection.cycleId,
          winnerUserId: selection.winnerUserId,
          selectionMethod: selection.payoutMode,
          route: `/groups/${selection.groupId}/cycles/${selection.cycleId}/payout`,
        },
      },
      { excludeUserId: selection.winnerUserId },
    );
    this.emitTurnRealtimeEvent(
      'winner.selected',
      selection.groupId,
      selection.cycleId,
      selection.winnerUserId,
    );
    this.emitTurnRealtimeEvent(
      'turn.updated',
      selection.groupId,
      selection.cycleId,
      selection.cycleId,
    );

    return this.groupsService.getCycleById(
      selection.groupId,
      selection.cycleId,
    );
  }

  async disbursePayout(
    currentUser: AuthenticatedUser,
    cycleId: string,
    dto: DisbursePayoutDto,
  ): Promise<PayoutResponseDto> {
    const result = await this.prisma.$transaction(async (tx) => {
      const txCompat = tx as TxCompatibility;
      const cycle = await tx.equbCycle.findUnique({
        where: { id: cycleId },
        include: {
          group: {
            select: {
              contributionAmount: true,
            },
          },
          payout: {
            include: {
              toUser: {
                select: {
                  id: true,
                  fullName: true,
                  phone: true,
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
          'Payout can only be sent for an open cycle',
        );
      }

      if (cycle.state !== CycleState.READY_FOR_PAYOUT) {
        throw new BadRequestException(
          'Cycle must be READY_FOR_PAYOUT before payout send',
        );
      }

      if (!cycle.selectedWinnerUserId) {
        throw new BadRequestException(
          'Winner must be selected before payout send',
        );
      }

      if (cycle.payoutSentAt != null) {
        throw new ConflictException(
          'Payout has already been sent for this cycle',
        );
      }

      const completedWinnerUserIds =
        await this.roundEligibilityService.listCompletedWinnerUserIds(
          tx,
          cycle.roundId,
        );
      if (completedWinnerUserIds.includes(cycle.selectedWinnerUserId)) {
        throw new ConflictException(
          'Selected winner has already received payout in this Equb round',
        );
      }

      if (
        dto.proofFileKey &&
        !isPayoutProofKeyScopedTo(dto.proofFileKey, cycle.groupId, cycle.id)
      ) {
        throw new BadRequestException(
          'proofFileKey does not match payout scope',
        );
      }

      const verifiedContribution = await tx.contribution.aggregate({
        where: {
          cycleId: cycle.id,
          status: {
            in: [ContributionStatus.VERIFIED, ContributionStatus.CONFIRMED],
          },
        },
        _sum: {
          amount: true,
        },
      });

      const verifiedAmount = verifiedContribution._sum.amount ?? 0;
      const targetAmount =
        verifiedAmount > 0 ? verifiedAmount : cycle.group.contributionAmount;
      const now = new Date();

      const payout = cycle.payout
        ? await tx.payout.update({
            where: { id: cycle.payout.id },
            data: {
              toUserId: cycle.selectedWinnerUserId,
              amount: targetAmount,
              status: PayoutStatus.PENDING,
              proofFileKey: dto.proofFileKey ?? cycle.payout.proofFileKey,
              paymentRef: dto.paymentRef ?? cycle.payout.paymentRef,
              note: dto.note ?? cycle.payout.note,
              metadata: {
                ...(typeof cycle.payout.metadata === 'object' &&
                cycle.payout.metadata !== null
                  ? cycle.payout.metadata
                  : {}),
                selectedWinnerUserId: cycle.selectedWinnerUserId,
                selectionMethod: cycle.selectionMethod,
                selectionMetadata: cycle.selectionMetadata,
                payoutSentAt: now.toISOString(),
              },
              createdByUserId: currentUser.id,
              confirmedByUserId: null,
              confirmedAt: null,
            },
            include: {
              toUser: {
                select: {
                  id: true,
                  fullName: true,
                  phone: true,
                },
              },
            },
          })
        : await tx.payout.create({
            data: {
              groupId: cycle.groupId,
              cycleId: cycle.id,
              toUserId: cycle.selectedWinnerUserId,
              amount: targetAmount,
              status: PayoutStatus.PENDING,
              proofFileKey: dto.proofFileKey ?? null,
              paymentRef: dto.paymentRef ?? null,
              note: dto.note ?? null,
              metadata: {
                scheduledPayoutUserId: cycle.scheduledPayoutUserId,
                finalPayoutUserId: cycle.finalPayoutUserId,
                selectedWinnerUserId: cycle.selectedWinnerUserId,
                selectionMethod: cycle.selectionMethod,
                selectionMetadata: cycle.selectionMetadata,
                winningBidAmount: cycle.winningBidAmount,
                winningBidUserId: cycle.winningBidUserId,
                payoutSentAt: now.toISOString(),
              },
              createdByUserId: currentUser.id,
            },
            include: {
              toUser: {
                select: {
                  id: true,
                  fullName: true,
                  phone: true,
                },
              },
            },
          });

      await tx.equbCycle.update({
        where: { id: cycle.id },
        data: {
          finalPayoutUserId: cycle.selectedWinnerUserId,
          payoutSentAt: now,
          payoutSentByUserId: currentUser.id,
          state: CycleState.PAYOUT_SENT,
        },
      });

      const existingLedger = await tx.ledgerEntry.findFirst({
        where: {
          payoutId: payout.id,
          type: LedgerEntryType.PAYOUT_DISBURSED,
        },
        select: { id: true },
      });

      if (!existingLedger) {
        await txCompat.ledgerEntry?.create({
          data: {
            groupId: payout.groupId,
            cycleId: payout.cycleId,
            payoutId: payout.id,
            userId: payout.toUserId,
            type: LedgerEntryType.PAYOUT_DISBURSED,
            amount: payout.amount,
            note: payout.note,
            reference: payout.paymentRef,
            receiptFileKey: payout.proofFileKey,
            confirmedAt: now,
            confirmedByUserId: currentUser.id,
          },
        });
      }

      await this.reputationService.applyEvent(tx, {
        userId: payout.toUserId,
        eventType: 'PAYOUT_RECEIVED',
        metricChanges: {
          payoutsReceived: 1,
        },
        idempotencyKey: `reputation:payout-received:${payout.cycleId}:${payout.toUserId}`,
        relatedGroupId: payout.groupId,
        relatedCycleId: payout.cycleId,
        metadata: {
          payoutId: payout.id,
          amount: payout.amount,
        },
      });

      return payout;
    });

    await this.auditService.log(
      'PAYOUT_SENT',
      currentUser.id,
      {
        payoutId: result.id,
        cycleId: result.cycleId,
        toUserId: result.toUserId,
        amount: result.amount,
      },
      result.groupId,
    );

    await this.notificationsService.notifyUser(result.toUserId, {
      type: NotificationType.PAYOUT_SENT,
      title: 'Payout sent',
      body: 'Your payout has been sent. Confirm receipt to complete the turn.',
      groupId: result.groupId,
      eventId: `PAYOUT_SENT_${result.cycleId}`,
      data: {
        payoutId: result.id,
        cycleId: result.cycleId,
        toUserId: result.toUserId,
        route: `/groups/${result.groupId}/cycles/${result.cycleId}/payout`,
      },
    });

    this.emitTurnRealtimeEvent(
      'payout.updated',
      result.groupId,
      result.cycleId,
      result.id,
    );
    this.emitTurnRealtimeEvent(
      'turn.updated',
      result.groupId,
      result.cycleId,
      result.cycleId,
    );

    return this.toPayoutResponse(result);
  }

  async createPayout(
    currentUser: AuthenticatedUser,
    cycleId: string,
    dto: CreatePayoutDto,
  ): Promise<PayoutResponseDto> {
    return this.disbursePayout(currentUser, cycleId, {
      proofFileKey: dto.proofFileKey,
      paymentRef: dto.paymentRef,
      note: dto.note,
    });
  }

  async confirmPayout(
    currentUser: AuthenticatedUser,
    payoutId: string,
    _dto: ConfirmPayoutDto,
  ): Promise<PayoutResponseDto> {
    const payout = await this.prisma.payout.findUnique({
      where: { id: payoutId },
      select: { cycleId: true },
    });

    if (!payout) {
      throw new NotFoundException('Payout not found');
    }

    return this.confirmPayoutReceived(currentUser, payout.cycleId);
  }

  async confirmPayoutReceived(
    currentUser: AuthenticatedUser,
    cycleId: string,
  ): Promise<PayoutResponseDto> {
    const payout = await this.prisma.$transaction(
      async (tx): Promise<PayoutWithUser> => {
        const cycle = await tx.equbCycle.findUnique({
          where: { id: cycleId },
          include: {
            payout: {
              include: {
                toUser: {
                  select: {
                    id: true,
                    fullName: true,
                    phone: true,
                  },
                },
              },
            },
            group: {
              select: {
                strictPayout: true,
              },
            },
          },
        });

        if (!cycle) {
          throw new NotFoundException('Cycle not found');
        }

        if (cycle.status !== CycleStatus.OPEN) {
          throw new BadRequestException(
            'Payout receipt can only be confirmed for an open cycle',
          );
        }

        if (cycle.state !== CycleState.PAYOUT_SENT) {
          throw new BadRequestException(
            'Cycle must be PAYOUT_SENT before receipt confirmation',
          );
        }

        if (!cycle.selectedWinnerUserId || !cycle.payout) {
          throw new BadRequestException(
            'Payout must be sent before receipt confirmation',
          );
        }

        if (cycle.selectedWinnerUserId !== currentUser.id) {
          throw new ForbiddenException(
            'Only the selected winner can confirm payout receipt',
          );
        }

        const activeMemberIds = (
          await tx.equbMember.findMany({
            where: {
              groupId: cycle.groupId,
              status: {
                in: PARTICIPATING_MEMBER_STATUSES,
              },
            },
            select: { userId: true },
          })
        ).map((member) => member.userId);

        const confirmedContributionUserIds = (
          await tx.contribution.findMany({
            where: {
              cycleId: cycle.id,
              status: {
                in: [ContributionStatus.VERIFIED, ContributionStatus.CONFIRMED],
              },
            },
            select: { userId: true },
          })
        ).map((contribution) => contribution.userId);

        const strictEligibility = calculateStrictPayoutEligibility(
          activeMemberIds,
          confirmedContributionUserIds,
        );

        if (cycle.group.strictPayout && !strictEligibility.eligible) {
          throw new BadRequestException(
            `Strict payout check failed. Missing confirmed contributions for ${strictEligibility.missingMemberIds.length} active member(s).`,
          );
        }

        const now = new Date();
        const confirmedPayout = await tx.payout.update({
          where: { id: cycle.payout.id },
          data: {
            status: PayoutStatus.CONFIRMED,
            confirmedByUserId: currentUser.id,
            confirmedAt: now,
          },
          include: {
            toUser: {
              select: {
                id: true,
                fullName: true,
                phone: true,
              },
            },
          },
        });

        await tx.equbCycle.update({
          where: { id: cycle.id },
          data: {
            payoutReceivedConfirmedAt: now,
            payoutReceivedConfirmedByUserId: currentUser.id,
            state: CycleState.COMPLETED,
            status: CycleStatus.CLOSED,
            closedAt: now,
            closedByUserId: currentUser.id,
          },
        });

        const roundParticipantUserIds =
          await this.roundEligibilityService.getRoundParticipantUserIds(tx, {
            roundId: cycle.roundId,
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
          await this.roundEligibilityService.closeRoundIfOpen(tx, {
            roundId: cycle.roundId,
            closedAt: now,
          });
        }

        await this.reputationService.applyEvent(tx, {
          userId: currentUser.id,
          eventType: 'PAYOUT_CONFIRMED',
          metricChanges: {
            payoutsConfirmed: 1,
          },
          idempotencyKey: `reputation:payout-confirmed:${confirmedPayout.cycleId}:${currentUser.id}`,
          relatedGroupId: confirmedPayout.groupId,
          relatedCycleId: confirmedPayout.cycleId,
          metadata: {
            payoutId: confirmedPayout.id,
          },
        });

        for (const participantUserId of roundParticipantUserIds) {
          await this.reputationService.applyEvent(tx, {
            userId: participantUserId,
            eventType: 'TURN_PARTICIPATED',
            metricChanges: {
              turnsParticipated: 1,
            },
            idempotencyKey: `reputation:turn-participated:${cycle.id}:${participantUserId}`,
            relatedGroupId: cycle.groupId,
            relatedCycleId: cycle.id,
            metadata: {
              roundId: cycle.roundId,
            },
          });
        }

        for (const missingUserId of strictEligibility.missingMemberIds) {
          await this.reputationService.applyEvent(tx, {
            userId: missingUserId,
            eventType: 'CONTRIBUTION_MISSED',
            metricChanges: {
              missedPayments: 1,
            },
            idempotencyKey: `reputation:contribution-missed:${cycle.id}:${missingUserId}`,
            relatedGroupId: cycle.groupId,
            relatedCycleId: cycle.id,
            metadata: {
              reason: 'payout_confirmed_without_verified_contribution',
            },
          });
        }

        if (remainingEligibleWinnerUserIds.length === 0) {
          for (const participantUserId of roundParticipantUserIds) {
            await this.reputationService.applyEvent(tx, {
              userId: participantUserId,
              eventType: 'ROUND_COMPLETED',
              metricChanges: {
                equbsCompleted: 1,
              },
              idempotencyKey: `reputation:round-completed:${cycle.roundId}:${participantUserId}`,
              relatedGroupId: cycle.groupId,
              relatedCycleId: cycle.id,
              metadata: {
                roundId: cycle.roundId,
              },
            });
          }

          const groupHost = await tx.equbGroup.findUnique({
            where: { id: cycle.groupId },
            select: {
              createdByUserId: true,
            },
          });
          if (groupHost) {
            await this.reputationService.applyEvent(tx, {
              userId: groupHost.createdByUserId,
              eventType: 'HOSTED_ROUND_COMPLETED',
              metricChanges: {
                hostedEqubsCompleted: 1,
              },
              idempotencyKey: `reputation:hosted-round-completed:${cycle.roundId}:${groupHost.createdByUserId}`,
              relatedGroupId: cycle.groupId,
              relatedCycleId: cycle.id,
              metadata: {
                roundId: cycle.roundId,
              },
            });
          }
        }

        await this.auditService.log(
          'PAYOUT_RECEIPT_CONFIRMED',
          currentUser.id,
          {
            payoutId: confirmedPayout.id,
            strictPayout: cycle.group.strictPayout,
            requiredActiveMemberCount:
              strictEligibility.requiredMemberIds.length,
            confirmedContributionCount:
              strictEligibility.confirmedMemberIds.length,
            missingContributionCount: strictEligibility.missingMemberIds.length,
            missingMemberIds: strictEligibility.missingMemberIds,
          },
          confirmedPayout.groupId,
        );

        return confirmedPayout;
      },
    );

    await this.notificationsService.notifyGroupMembers(payout.groupId, {
      type: NotificationType.TURN_COMPLETED,
      title: 'Turn completed',
      body: 'The recipient confirmed payout receipt and the turn is complete.',
      groupId: payout.groupId,
      eventId: `TURN_COMPLETED_${payout.cycleId}`,
      data: {
        payoutId: payout.id,
        cycleId: payout.cycleId,
        toUserId: payout.toUserId,
        route: `/groups/${payout.groupId}/cycles/${payout.cycleId}/payout`,
      },
    });

    this.emitTurnRealtimeEvent(
      'payout.updated',
      payout.groupId,
      payout.cycleId,
      payout.id,
    );
    this.emitTurnRealtimeEvent(
      'turn.completed',
      payout.groupId,
      payout.cycleId,
      payout.cycleId,
    );

    return this.toPayoutResponse(payout);
  }

  async closeCycle(
    currentUser: AuthenticatedUser,
    cycleId: string,
    dto: CloseCycleDto,
  ): Promise<CloseCycleResponseDto> {
    const closedCycle = await this.prisma.$transaction(async (tx) => {
      const cycle = await tx.equbCycle.findUnique({
        where: {
          id: cycleId,
        },
        include: {
          payout: true,
        },
      });

      if (!cycle) {
        throw new NotFoundException('Cycle not found');
      }

      if (cycle.state !== CycleState.COMPLETED) {
        throw new BadRequestException(
          'Cycle can only be closed after payout receipt is confirmed',
        );
      }

      if (cycle.status === CycleStatus.OPEN) {
        await tx.equbCycle.update({
          where: {
            id: cycleId,
          },
          data: {
            status: CycleStatus.CLOSED,
            closedAt: cycle.closedAt ?? new Date(),
            closedByUserId: cycle.closedByUserId ?? currentUser.id,
          },
        });
      }

      return cycle;
    });

    let nextCycle: GroupCycleResponseDto | null = null;
    if (dto.autoNext === true) {
      try {
        nextCycle = await this.groupsService.startCycle(
          currentUser,
          closedCycle.groupId,
        );
      } catch (error) {
        this.logger.warn(
          `Cycle closed but auto-next failed for groupId=${closedCycle.groupId}: ${
            error instanceof Error ? error.message : 'unknown error'
          }`,
        );
      }
    }

    return {
      success: true,
      nextCycleId: nextCycle?.id ?? null,
      nextCycle,
    };
  }

  async getCyclePayout(cycleId: string): Promise<PayoutResponseDto | null> {
    const cycle = await this.prisma.equbCycle.findUnique({
      where: {
        id: cycleId,
      },
      include: {
        payout: {
          include: {
            toUser: {
              select: {
                id: true,
                fullName: true,
                phone: true,
              },
            },
          },
        },
      },
    });

    if (!cycle) {
      throw new NotFoundException('Cycle not found');
    }

    if (!cycle.payout) {
      return null;
    }

    return this.toPayoutResponse(cycle.payout);
  }

  private toPayoutResponse(payout: PayoutWithUser): PayoutResponseDto {
    return {
      id: payout.id,
      groupId: payout.groupId,
      cycleId: payout.cycleId,
      toUserId: payout.toUserId,
      amount: payout.amount,
      status: payout.status,
      proofFileKey: payout.proofFileKey,
      paymentRef: payout.paymentRef,
      note: payout.note,
      createdByUserId: payout.createdByUserId,
      createdAt: payout.createdAt,
      confirmedByUserId: payout.confirmedByUserId,
      confirmedAt: payout.confirmedAt,
      toUser: payout.toUser,
    };
  }

  private emitTurnRealtimeEvent(
    eventType: string,
    groupId: string,
    turnId: string,
    entityId: string,
  ): void {
    this.realtimeService.emitTurnEvent(groupId, turnId, {
      eventType,
      groupId,
      turnId,
      entityId,
      timestamp: new Date().toISOString(),
    });
  }
}
