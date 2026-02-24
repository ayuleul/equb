import {
  BadRequestException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import {
  AuctionStatus,
  ContributionStatus,
  CycleState,
  CycleStatus,
  GroupRulePayoutMode,
  LedgerEntryType,
  MemberStatus,
  NotificationType,
  PayoutStatus,
  Prisma,
} from '@prisma/client';
import { randomInt } from 'crypto';

import { AuditService } from '../../common/audit/audit.service';
import {
  PARTICIPATING_MEMBER_STATUSES,
  VERIFIED_MEMBER_STATUSES,
} from '../../common/membership/member-status.util';
import { PrismaService } from '../../common/prisma/prisma.service';
import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import { isPayoutProofKeyScopedTo } from '../contributions/utils/proof-key.util';
import { GroupCycleResponseDto } from '../groups/entities/groups.entities';
import { GroupsService } from '../groups/groups.service';
import { NotificationsService } from '../notifications/notifications.service';
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
          cycleNo: true,
          createdAt: true,
          scheduledPayoutUserId: true,
          finalPayoutUserId: true,
          selectedWinnerUserId: true,
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

      if (cycle.state !== CycleState.READY_FOR_PAYOUT) {
        throw new BadRequestException(
          'Cycle must be READY_FOR_PAYOUT before selecting winner',
        );
      }

      if (!cycle.group.rules) {
        throw new BadRequestException(
          'Group rules are required before winner selection',
        );
      }

      const payoutMode = cycle.group.rules.payoutMode;

      if (
        cycle.selectedWinnerUserId &&
        cycle.selectionMethod === payoutMode
      ) {
        return {
          cycleId: cycle.id,
          groupId: cycle.groupId,
          winnerUserId: cycle.selectedWinnerUserId,
          payoutMode,
          selectionMetadata: cycle.selectionMetadata,
          changed: false,
        };
      }

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

      if (eligibleUserIds.length < 2) {
        throw new BadRequestException(
          cycle.group.rules.requiresMemberVerification
            ? 'At least 2 verified members are required for winner selection'
            : 'At least 2 joined members are required for winner selection',
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
          const winnerIndex = randomInt(eligibleUserIds.length);
          winnerUserId = eligibleUserIds[winnerIndex];
          selectionMetadata = {
            mode: GroupRulePayoutMode.LOTTERY,
            winnerIndex,
            poolSize: eligibleUserIds.length,
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
            where: { cycleId: cycle.id },
            orderBy: [{ amount: 'desc' }, { createdAt: 'asc' }],
            select: {
              id: true,
              userId: true,
              amount: true,
              createdAt: true,
            },
          });

          winnerUserId = topBid?.userId ?? cycle.scheduledPayoutUserId;
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
            fallbackWinnerUserId: topBid ? null : cycle.scheduledPayoutUserId,
            selectedAt: selectedAt.toISOString(),
          };
          break;
        }
        case GroupRulePayoutMode.ROTATION: {
          if (eligibleUserIds.length === 0) {
            throw new BadRequestException('No eligible members for rotation');
          }

          const priorRotationSelections = await tx.equbCycle.findMany({
            where: {
              groupId: cycle.groupId,
              id: { not: cycle.id },
              selectionMethod: GroupRulePayoutMode.ROTATION,
              selectedWinnerUserId: {
                in: eligibleUserIds,
              },
            },
            select: {
              selectedWinnerUserId: true,
            },
          });

          const rotationIndex =
            priorRotationSelections.length % eligibleUserIds.length;
          winnerUserId = eligibleUserIds[rotationIndex];
          selectionMetadata = {
            mode: GroupRulePayoutMode.ROTATION,
            rotationIndex,
            eligibleCount: eligibleUserIds.length,
            selectedAt: selectedAt.toISOString(),
          };
          break;
        }
        case GroupRulePayoutMode.DECISION: {
          const requestedWinnerUserId = dto.userId?.trim();
          if (!requestedWinnerUserId) {
            throw new BadRequestException(
              'userId is required for DECISION payout mode',
            );
          }

          if (!eligibleUserIds.includes(requestedWinnerUserId)) {
            throw new BadRequestException(
              'Selected user is not eligible for payout winner selection',
            );
          }

          winnerUserId = requestedWinnerUserId;
          selectionMetadata = {
            mode: GroupRulePayoutMode.DECISION,
            decidedByUserId: currentUser.id,
            selectedAt: selectedAt.toISOString(),
          };
          break;
        }
        default: {
          throw new BadRequestException('Unsupported payout mode');
        }
      }

      const updatedCycle = await tx.equbCycle.update({
        where: { id: cycle.id },
        data: {
          finalPayoutUserId: winnerUserId,
          selectedWinnerUserId: winnerUserId,
          selectionMethod: payoutMode,
          selectionMetadata,
          winningBidAmount,
          winningBidUserId,
          auctionStatus,
        },
        select: {
          id: true,
          groupId: true,
          selectedWinnerUserId: true,
          selectionMethod: true,
          selectionMetadata: true,
        },
      });

      return {
        cycleId: updatedCycle.id,
        groupId: updatedCycle.groupId,
        winnerUserId: updatedCycle.selectedWinnerUserId!,
        payoutMode: updatedCycle.selectionMethod!,
        selectionMetadata: updatedCycle.selectionMetadata,
        changed: true,
      };
    });

    if (selection.changed) {
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
        title: 'Payout winner selected',
        body: 'You are selected as this cycle payout winner.',
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
          title: 'Payout winner announced',
          body: 'A payout winner has been selected for this cycle.',
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
    }

    return this.groupsService.getCycleById(selection.groupId, selection.cycleId);
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
          'Payout can only be disbursed for an open cycle',
        );
      }

      if (
        cycle.state !== CycleState.READY_FOR_PAYOUT &&
        cycle.state !== CycleState.DISBURSED
      ) {
        throw new BadRequestException(
          'Cycle must be READY_FOR_PAYOUT before payout disbursement',
        );
      }

      if (!cycle.selectedWinnerUserId) {
        throw new BadRequestException(
          'Winner must be selected before payout disbursement',
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

      let payout: PayoutWithUser;
      let newlyDisbursed = false;

      if (cycle.payout) {
        if (cycle.payout.status === PayoutStatus.CONFIRMED) {
          payout = cycle.payout;
        } else {
          payout = await tx.payout.update({
            where: {
              id: cycle.payout.id,
            },
            data: {
              toUserId: cycle.selectedWinnerUserId,
              amount: targetAmount,
              status: PayoutStatus.CONFIRMED,
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
              },
              confirmedByUserId: currentUser.id,
              confirmedAt: new Date(),
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
          newlyDisbursed = true;
        }
      } else {
        payout = await tx.payout.create({
          data: {
            groupId: cycle.groupId,
            cycleId: cycle.id,
            toUserId: cycle.selectedWinnerUserId,
            amount: targetAmount,
            status: PayoutStatus.CONFIRMED,
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
            },
            createdByUserId: currentUser.id,
            confirmedByUserId: currentUser.id,
            confirmedAt: new Date(),
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
        newlyDisbursed = true;
      }

      await tx.equbCycle.update({
        where: { id: cycle.id },
        data: {
          finalPayoutUserId: cycle.selectedWinnerUserId,
          state: CycleState.DISBURSED,
        },
      });

      if (newlyDisbursed) {
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
              confirmedAt: payout.confirmedAt,
              confirmedByUserId: currentUser.id,
            },
          });
        }
      }

      return {
        payout,
        newlyDisbursed,
      };
    });

    if (result.newlyDisbursed) {
      await this.auditService.log(
        'PAYOUT_DISBURSED',
        currentUser.id,
        {
          payoutId: result.payout.id,
          cycleId: result.payout.cycleId,
          toUserId: result.payout.toUserId,
          amount: result.payout.amount,
        },
        result.payout.groupId,
      );

      await this.notificationsService.notifyGroupMembers(result.payout.groupId, {
        type: NotificationType.PAYOUT_CONFIRMED,
        title: 'Payout disbursed',
        body: 'Payout has been disbursed for this cycle.',
        groupId: result.payout.groupId,
        eventId: `PAYOUT_DISBURSED_${result.payout.cycleId}`,
        data: {
          payoutId: result.payout.id,
          cycleId: result.payout.cycleId,
          toUserId: result.payout.toUserId,
          route: `/groups/${result.payout.groupId}/cycles/${result.payout.cycleId}/payout`,
        },
      });
    }

    return this.toPayoutResponse(result.payout);
  }

  async createPayout(
    currentUser: AuthenticatedUser,
    cycleId: string,
    dto: CreatePayoutDto,
  ): Promise<PayoutResponseDto> {
    const payout = await this.prisma.$transaction(async (tx) => {
      const cycle = await tx.equbCycle.findUnique({
        where: { id: cycleId },
        include: {
          group: {
            select: {
              contributionAmount: true,
              rules: {
                select: {
                  strictCollection: true,
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
          'Payout can only be created for open cycle',
        );
      }

      if (
        cycle.state !== CycleState.READY_FOR_PAYOUT &&
        cycle.state !== CycleState.DISBURSED
      ) {
        const strictCollection = cycle.group.rules?.strictCollection ?? false;

        if (!strictCollection) {
          await tx.equbCycle.update({
            where: { id: cycle.id },
            data: { state: CycleState.READY_FOR_PAYOUT },
          });
        } else {
          const unresolvedWhere: Prisma.ContributionWhereInput = {
            cycleId: cycle.id,
            status: {
              in: [
                ContributionStatus.PENDING,
                ContributionStatus.REJECTED,
                ContributionStatus.LATE,
                ContributionStatus.PAID_SUBMITTED,
                ContributionStatus.SUBMITTED,
              ],
            },
          };

          const contributionDelegate = tx.contribution as {
            count?: (args: Prisma.ContributionCountArgs) => Promise<number>;
            findMany: (
              args: Prisma.ContributionFindManyArgs,
            ) => Promise<Array<{ id: string }>>;
          };

          const unresolvedCount =
            contributionDelegate.count != null
              ? await contributionDelegate.count({ where: unresolvedWhere })
              : (
                  await contributionDelegate.findMany({
                    where: unresolvedWhere,
                    select: { id: true },
                  })
                ).length;

          if (unresolvedCount === 0) {
            await tx.equbCycle.update({
              where: { id: cycle.id },
              data: { state: CycleState.READY_FOR_PAYOUT },
            });
          } else {
            throw new BadRequestException(
              'Cycle must be READY_FOR_PAYOUT before creating payout',
            );
          }
        }
      }

      if (
        dto.proofFileKey &&
        !isPayoutProofKeyScopedTo(dto.proofFileKey, cycle.groupId, cycle.id)
      ) {
        throw new BadRequestException(
          'proofFileKey does not match payout scope',
        );
      }

      return tx.payout.create({
        data: {
          groupId: cycle.groupId,
          cycleId: cycle.id,
          toUserId: cycle.finalPayoutUserId,
          amount: dto.amount ?? cycle.group.contributionAmount,
          status: PayoutStatus.PENDING,
          proofFileKey: dto.proofFileKey ?? null,
          paymentRef: dto.paymentRef ?? null,
          note: dto.note ?? null,
          metadata: {
            scheduledPayoutUserId: cycle.scheduledPayoutUserId,
            finalPayoutUserId: cycle.finalPayoutUserId,
            winningBidAmount: cycle.winningBidAmount,
            winningBidUserId: cycle.winningBidUserId,
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
    });

    await this.auditService.log(
      'PAYOUT_CREATED',
      currentUser.id,
      {
        payoutId: payout.id,
        cycleId,
        toUserId: payout.toUserId,
        amount: payout.amount,
      },
      payout.groupId,
    );

    return this.toPayoutResponse(payout);
  }

  async confirmPayout(
    currentUser: AuthenticatedUser,
    payoutId: string,
    dto: ConfirmPayoutDto,
  ): Promise<PayoutResponseDto> {
    const payout = await this.prisma.$transaction(
      async (tx): Promise<PayoutWithUser> => {
        const txCompat = tx as TxCompatibility;
        const existing = await tx.payout.findUnique({
          where: { id: payoutId },
          include: {
            toUser: {
              select: {
                id: true,
                fullName: true,
                phone: true,
              },
            },
            cycle: {
              select: {
                id: true,
                groupId: true,
                status: true,
              },
            },
            group: {
              select: {
                strictPayout: true,
              },
            },
          },
        });

        if (!existing) {
          throw new NotFoundException('Payout not found');
        }

        if (existing.status !== PayoutStatus.PENDING) {
          throw new BadRequestException('Only pending payout can be confirmed');
        }

        if (existing.cycle.status !== CycleStatus.OPEN) {
          throw new BadRequestException('Cycle must be open to confirm payout');
        }

        if (
          dto.proofFileKey &&
          !isPayoutProofKeyScopedTo(
            dto.proofFileKey,
            existing.groupId,
            existing.cycleId,
          )
        ) {
          throw new BadRequestException(
            'proofFileKey does not match payout scope',
          );
        }

        const activeMemberIds = (
          await tx.equbMember.findMany({
            where: {
              groupId: existing.groupId,
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
              cycleId: existing.cycleId,
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

        if (existing.group.strictPayout && !strictEligibility.eligible) {
          throw new BadRequestException(
            `Strict payout check failed. Missing confirmed contributions for ${strictEligibility.missingMemberIds.length} active member(s).`,
          );
        }

        const confirmedPayout = await tx.payout.update({
          where: { id: payoutId },
          data: {
            status: PayoutStatus.CONFIRMED,
            proofFileKey: dto.proofFileKey ?? existing.proofFileKey,
            paymentRef: dto.paymentRef ?? existing.paymentRef,
            note: dto.note ?? existing.note,
            confirmedByUserId: currentUser.id,
            confirmedAt: new Date(),
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
          where: { id: existing.cycleId },
          data: {
            state: CycleState.DISBURSED,
          },
        });

        await txCompat.ledgerEntry?.create({
          data: {
            groupId: confirmedPayout.groupId,
            cycleId: confirmedPayout.cycleId,
            payoutId: confirmedPayout.id,
            userId: confirmedPayout.toUserId,
            type: LedgerEntryType.PAYOUT_DISBURSED,
            amount: confirmedPayout.amount,
            note: confirmedPayout.note,
            reference: confirmedPayout.paymentRef,
            receiptFileKey: confirmedPayout.proofFileKey,
            confirmedAt: confirmedPayout.confirmedAt,
            confirmedByUserId: currentUser.id,
          },
        });

        await this.auditService.log(
          'PAYOUT_CONFIRMED',
          currentUser.id,
          {
            payoutId: confirmedPayout.id,
            strictPayout: existing.group.strictPayout,
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
      type: NotificationType.PAYOUT_CONFIRMED,
      title: 'Payout confirmed',
      body: 'A payout was confirmed for the current cycle.',
      groupId: payout.groupId,
      data: {
        payoutId: payout.id,
        cycleId: payout.cycleId,
        toUserId: payout.toUserId,
      },
    });

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

      if (cycle.status !== CycleStatus.OPEN) {
        throw new BadRequestException('Cycle is already closed');
      }

      if (!cycle.payout || cycle.payout.status !== PayoutStatus.CONFIRMED) {
        throw new BadRequestException(
          'Cycle can only be closed after payout is confirmed',
        );
      }

      await tx.equbCycle.update({
        where: {
          id: cycleId,
        },
        data: {
          status: CycleStatus.CLOSED,
          state: CycleState.CLOSED,
          closedAt: new Date(),
          closedByUserId: currentUser.id,
        },
      });

      return cycle;
    });

    await this.auditService.log(
      'CYCLE_CLOSED',
      currentUser.id,
      {
        cycleId,
        payoutId: closedCycle.payout?.id,
        autoNext: dto.autoNext ?? false,
      },
      closedCycle.groupId,
    );

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

  private resolveEligibleStatuses(
    requiresMemberVerification: boolean,
  ): MemberStatus[] {
    return requiresMemberVerification
      ? VERIFIED_MEMBER_STATUSES
      : PARTICIPATING_MEMBER_STATUSES;
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
}
