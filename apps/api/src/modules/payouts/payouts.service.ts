import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  ContributionStatus,
  CycleState,
  CycleStatus,
  LedgerEntryType,
  NotificationType,
  Prisma,
  PayoutStatus,
} from '@prisma/client';

import { AuditService } from '../../common/audit/audit.service';
import { PARTICIPATING_MEMBER_STATUSES } from '../../common/membership/member-status.util';
import { PrismaService } from '../../common/prisma/prisma.service';
import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import { isPayoutProofKeyScopedTo } from '../contributions/utils/proof-key.util';
import { NotificationsService } from '../notifications/notifications.service';
import { ConfirmPayoutDto } from './dto/confirm-payout.dto';
import { CreatePayoutDto } from './dto/create-payout.dto';
import { PayoutResponseDto } from './entities/payouts.entities';
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
  constructor(
    private readonly prisma: PrismaService,
    private readonly auditService: AuditService,
    private readonly notificationsService: NotificationsService,
  ) {}

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
  ): Promise<{ success: true }> {
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
      },
      closedCycle.groupId,
    );

    return { success: true };
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
}
