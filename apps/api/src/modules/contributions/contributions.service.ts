import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  ContributionStatus,
  CycleState,
  CycleStatus,
  GroupPaymentMethod,
  LedgerEntryType,
  MemberRole,
  NotificationType,
  Prisma,
} from '@prisma/client';

import { AuditService } from '../../common/audit/audit.service';
import { isParticipatingMemberStatus } from '../../common/membership/member-status.util';
import { PrismaService } from '../../common/prisma/prisma.service';
import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import { NotificationsService } from '../notifications/notifications.service';
import { RejectContributionDto } from './dto/reject-contribution.dto';
import { SubmitContributionDto } from './dto/submit-contribution.dto';
import {
  ContributionListResponseDto,
  ContributionResponseDto,
} from './entities/contributions.entities';
import { isContributionProofKeyScopedTo } from './utils/proof-key.util';

type ContributionWithUser = Prisma.ContributionGetPayload<{
  include: {
    user: {
      select: {
        id: true;
        fullName: true;
        phone: true;
      };
    };
  };
}>;

type OptionalContributionReceiptDelegate = {
  upsert(args: Prisma.ContributionReceiptUpsertArgs): Promise<unknown>;
};

type OptionalLedgerEntryDelegate = {
  create(args: Prisma.LedgerEntryCreateArgs): Promise<unknown>;
};

type TxCompatibility = Prisma.TransactionClient & {
  contributionReceipt?: OptionalContributionReceiptDelegate;
  ledgerEntry?: OptionalLedgerEntryDelegate;
};

@Injectable()
export class ContributionsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly auditService: AuditService,
    private readonly notificationsService: NotificationsService,
  ) {}

  async submitContribution(
    currentUser: AuthenticatedUser,
    cycleId: string,
    dto: SubmitContributionDto,
  ): Promise<ContributionResponseDto> {
    const cycle = await this.prisma.equbCycle.findUnique({
      where: { id: cycleId },
      include: {
        group: {
          select: {
            id: true,
            contributionAmount: true,
            rules: {
              select: {
                paymentMethods: true,
              },
            },
          },
        },
      },
    });

    if (!cycle) {
      throw new NotFoundException('Cycle not found');
    }

    if (
      cycle.status !== CycleStatus.OPEN ||
      cycle.state === CycleState.CLOSED
    ) {
      throw new BadRequestException(
        'Contributions can only be submitted for open cycles',
      );
    }

    const method = dto.method ?? GroupPaymentMethod.CASH_ACK;

    if (
      cycle.group.rules &&
      !cycle.group.rules.paymentMethods.includes(method)
    ) {
      throw new BadRequestException(
        `Payment method ${method} is not allowed by group rules`,
      );
    }

    const membership = await this.prisma.equbMember.findUnique({
      where: {
        groupId_userId: {
          groupId: cycle.groupId,
          userId: currentUser.id,
        },
      },
      select: {
        status: true,
      },
    });

    if (!membership || !isParticipatingMemberStatus(membership.status)) {
      throw new ForbiddenException(
        'Only joined group members can submit contributions',
      );
    }

    const receiptFileKey =
      (dto.receiptFileKey ?? dto.proofFileKey)?.trim() || undefined;
    if (
      receiptFileKey &&
      !isContributionProofKeyScopedTo(
        receiptFileKey,
        cycle.groupId,
        cycle.id,
        currentUser.id,
      )
    ) {
      throw new BadRequestException(
        'receiptFileKey does not match allowed scope',
      );
    }

    const normalizedReference =
      (dto.reference ?? dto.paymentRef)?.trim() || undefined;
    const normalizedNote = dto.note?.trim() || undefined;
    const submittedAt = new Date();

    const contribution = await this.prisma.$transaction(
      async (tx): Promise<ContributionWithUser> => {
        const txCompat = tx as TxCompatibility;
        let existing = await tx.contribution.findUnique({
          where: {
            cycleId_userId: {
              cycleId,
              userId: currentUser.id,
            },
          },
        });

        if (!existing) {
          existing = await tx.contribution.create({
            data: {
              groupId: cycle.groupId,
              cycleId,
              userId: currentUser.id,
              amount: dto.amount ?? cycle.group.contributionAmount,
              status: ContributionStatus.PENDING,
            },
          });
        }

        if (
          existing.status === ContributionStatus.VERIFIED ||
          existing.status === ContributionStatus.CONFIRMED
        ) {
          throw new BadRequestException(
            'Verified contribution cannot be modified',
          );
        }

        const amount =
          dto.amount ?? existing.amount ?? cycle.group.contributionAmount;

        const updated = await tx.contribution.update({
          where: {
            id: existing.id,
          },
          data: {
            amount,
            status: ContributionStatus.PAID_SUBMITTED,
            paymentMethod: method,
            proofFileKey: receiptFileKey ?? null,
            paymentRef: normalizedReference ?? null,
            note: normalizedNote ?? null,
            submittedAt,
            confirmedAt: null,
            confirmedByUserId: null,
            rejectedAt: null,
            rejectedByUserId: null,
            rejectReason: null,
          },
          include: {
            user: {
              select: {
                id: true,
                fullName: true,
                phone: true,
              },
            },
          },
        });

        await txCompat.contributionReceipt?.upsert({
          where: {
            contributionId: updated.id,
          },
          create: {
            groupId: updated.groupId,
            cycleId: updated.cycleId,
            contributionId: updated.id,
            userId: updated.userId,
            method,
            reference: normalizedReference ?? null,
            receiptFileKey: receiptFileKey ?? null,
            note: normalizedNote ?? null,
          },
          update: {
            method,
            reference: normalizedReference ?? null,
            receiptFileKey: receiptFileKey ?? null,
            note: normalizedNote ?? null,
          },
        });

        await txCompat.ledgerEntry?.create({
          data: {
            groupId: updated.groupId,
            cycleId: updated.cycleId,
            contributionId: updated.id,
            userId: updated.userId,
            type: LedgerEntryType.MEMBER_PAYMENT,
            amount: updated.amount,
            method,
            reference: normalizedReference ?? null,
            receiptFileKey: receiptFileKey ?? null,
            note: normalizedNote ?? null,
          },
        });

        await tx.equbCycle.update({
          where: { id: updated.cycleId },
          data: {
            state: CycleState.COLLECTING,
          },
        });

        await this.syncCycleContributionCounts(tx, cycleId);

        return updated;
      },
    );

    await this.auditService.log(
      'CONTRIBUTION_SUBMITTED',
      currentUser.id,
      {
        contributionId: contribution.id,
        cycleId,
        amount: contribution.amount,
        method,
      },
      cycle.groupId,
    );

    await this.notificationsService.notifyGroupAdmins(
      cycle.groupId,
      {
        type: NotificationType.CONTRIBUTION_SUBMITTED,
        title: 'Contribution submitted',
        body: `${currentUser.phone} submitted a contribution payment.`,
        data: {
          contributionId: contribution.id,
          cycleId,
          groupId: cycle.groupId,
        },
      },
      {
        excludeUserId: currentUser.id,
      },
    );

    return this.toContributionResponse(contribution, true);
  }

  async verifyContribution(
    currentUser: AuthenticatedUser,
    contributionId: string,
    note?: string,
  ): Promise<ContributionResponseDto> {
    const contribution = await this.prisma.$transaction(
      async (tx): Promise<ContributionWithUser> => {
        const txCompat = tx as TxCompatibility;
        const existing = await tx.contribution.findUnique({
          where: {
            id: contributionId,
          },
          include: {
            user: {
              select: {
                id: true,
                fullName: true,
                phone: true,
              },
            },
          },
        });

        if (!existing) {
          throw new NotFoundException('Contribution not found');
        }

        if (
          existing.status !== ContributionStatus.PAID_SUBMITTED &&
          existing.status !== ContributionStatus.SUBMITTED
        ) {
          throw new BadRequestException(
            'Only paid-submitted contributions can be verified',
          );
        }

        const normalizedNote = note?.trim();

        const updated = await tx.contribution.update({
          where: { id: contributionId },
          data: {
            status: ContributionStatus.VERIFIED,
            note: normalizedNote ?? existing.note,
            confirmedAt: new Date(),
            confirmedByUserId: currentUser.id,
            rejectedAt: null,
            rejectedByUserId: null,
            rejectReason: null,
          },
          include: {
            user: {
              select: {
                id: true,
                fullName: true,
                phone: true,
              },
            },
          },
        });

        await txCompat.ledgerEntry?.create({
          data: {
            groupId: updated.groupId,
            cycleId: updated.cycleId,
            contributionId: updated.id,
            userId: updated.userId,
            type: LedgerEntryType.CONTRIBUTION_VERIFIED,
            amount: updated.amount,
            method: updated.paymentMethod,
            reference: updated.paymentRef,
            receiptFileKey: updated.proofFileKey,
            note: normalizedNote ?? null,
            confirmedAt: new Date(),
            confirmedByUserId: currentUser.id,
          },
        });

        const pendingOrRejectedCount = await tx.contribution.count({
          where: {
            cycleId: updated.cycleId,
            status: {
              in: [ContributionStatus.PENDING, ContributionStatus.REJECTED],
            },
          },
        });

        await tx.equbCycle.update({
          where: { id: updated.cycleId },
          data: {
            state:
              pendingOrRejectedCount === 0
                ? CycleState.READY_FOR_PAYOUT
                : CycleState.COLLECTING,
          },
        });

        await this.syncCycleContributionCounts(tx, updated.cycleId);

        return updated;
      },
    );

    await this.auditService.log(
      'CONTRIBUTION_CONFIRMED',
      currentUser.id,
      {
        contributionId: contribution.id,
      },
      contribution.groupId,
    );

    await this.notificationsService.notifyUser(contribution.user.id, {
      type: NotificationType.CONTRIBUTION_CONFIRMED,
      title: 'Contribution verified',
      body: 'Your contribution has been verified.',
      groupId: contribution.groupId,
      data: {
        contributionId: contribution.id,
        cycleId: contribution.cycleId,
        groupId: contribution.groupId,
      },
    });

    return this.toContributionResponse(contribution, true);
  }

  async rejectContribution(
    currentUser: AuthenticatedUser,
    contributionId: string,
    dto: RejectContributionDto,
  ): Promise<ContributionResponseDto> {
    const contribution = await this.prisma.$transaction(
      async (tx): Promise<ContributionWithUser> => {
        const existing = await tx.contribution.findUnique({
          where: {
            id: contributionId,
          },
          include: {
            user: {
              select: {
                id: true,
                fullName: true,
                phone: true,
              },
            },
          },
        });

        if (!existing) {
          throw new NotFoundException('Contribution not found');
        }

        if (
          existing.status !== ContributionStatus.PAID_SUBMITTED &&
          existing.status !== ContributionStatus.SUBMITTED
        ) {
          throw new BadRequestException(
            'Only paid-submitted contributions can be rejected',
          );
        }

        const updated = await tx.contribution.update({
          where: { id: contributionId },
          data: {
            status: ContributionStatus.REJECTED,
            rejectedAt: new Date(),
            rejectedByUserId: currentUser.id,
            rejectReason: dto.reason,
            confirmedAt: null,
            confirmedByUserId: null,
          },
          include: {
            user: {
              select: {
                id: true,
                fullName: true,
                phone: true,
              },
            },
          },
        });

        await tx.equbCycle.update({
          where: { id: updated.cycleId },
          data: {
            state: CycleState.COLLECTING,
          },
        });

        await this.syncCycleContributionCounts(tx, existing.cycleId);

        return updated;
      },
    );

    await this.auditService.log(
      'CONTRIBUTION_REJECTED',
      currentUser.id,
      {
        contributionId: contribution.id,
        reason: dto.reason,
      },
      contribution.groupId,
    );

    await this.notificationsService.notifyUser(contribution.user.id, {
      type: NotificationType.CONTRIBUTION_REJECTED,
      title: 'Contribution rejected',
      body: 'Your contribution was rejected. Please review and resubmit.',
      groupId: contribution.groupId,
      data: {
        contributionId: contribution.id,
        cycleId: contribution.cycleId,
        groupId: contribution.groupId,
        reason: dto.reason,
      },
    });

    return this.toContributionResponse(contribution, true);
  }

  async listCycleContributions(
    currentUser: AuthenticatedUser,
    groupId: string,
    cycleId: string,
  ): Promise<ContributionListResponseDto> {
    const cycle = await this.prisma.equbCycle.findUnique({
      where: { id: cycleId },
      select: {
        id: true,
        groupId: true,
      },
    });

    if (!cycle || cycle.groupId !== groupId) {
      throw new NotFoundException('Cycle not found in group');
    }

    const requesterMembership = await this.prisma.equbMember.findUnique({
      where: {
        groupId_userId: {
          groupId,
          userId: currentUser.id,
        },
      },
      select: {
        status: true,
        role: true,
      },
    });

    if (
      !requesterMembership ||
      !isParticipatingMemberStatus(requesterMembership.status)
    ) {
      throw new ForbiddenException('Joined group membership is required');
    }

    const isAdminViewer = requesterMembership.role === MemberRole.ADMIN;

    const contributions = await this.prisma.contribution.findMany({
      where: {
        groupId,
        cycleId,
      },
      include: {
        user: {
          select: {
            id: true,
            fullName: true,
            phone: true,
          },
        },
      },
      orderBy: {
        createdAt: 'asc',
      },
    });

    const summary = {
      total: contributions.length,
      pending: 0,
      submitted: 0,
      confirmed: 0,
      rejected: 0,
      paidSubmitted: 0,
      verified: 0,
    };

    for (const contribution of contributions) {
      if (contribution.status === ContributionStatus.PENDING) {
        summary.pending += 1;
      }
      if (
        contribution.status === ContributionStatus.PAID_SUBMITTED ||
        contribution.status === ContributionStatus.SUBMITTED
      ) {
        summary.submitted += 1;
        summary.paidSubmitted += 1;
      }
      if (
        contribution.status === ContributionStatus.VERIFIED ||
        contribution.status === ContributionStatus.CONFIRMED
      ) {
        summary.confirmed += 1;
        summary.verified += 1;
      }
      if (contribution.status === ContributionStatus.REJECTED) {
        summary.rejected += 1;
      }
    }

    return {
      items: contributions.map((contribution) =>
        this.toContributionResponse(contribution, isAdminViewer),
      ),
      summary,
    };
  }

  private async syncCycleContributionCounts(
    tx: Prisma.TransactionClient,
    cycleId: string,
  ): Promise<void> {
    const [submittedCount, confirmedCount] = await Promise.all([
      tx.contribution.count({
        where: {
          cycleId,
          status: {
            in: [
              ContributionStatus.PAID_SUBMITTED,
              ContributionStatus.SUBMITTED,
            ],
          },
        },
      }),
      tx.contribution.count({
        where: {
          cycleId,
          status: {
            in: [ContributionStatus.VERIFIED, ContributionStatus.CONFIRMED],
          },
        },
      }),
    ]);

    await tx.equbCycle.update({
      where: { id: cycleId },
      data: {
        contributionsSubmittedCount: submittedCount,
        contributionsConfirmedCount: confirmedCount,
      },
    });
  }

  private toContributionResponse(
    contribution: ContributionWithUser,
    includePhone: boolean,
  ): ContributionResponseDto {
    return {
      id: contribution.id,
      groupId: contribution.groupId,
      cycleId: contribution.cycleId,
      userId: contribution.userId,
      amount: contribution.amount,
      status: contribution.status,
      paymentMethod: contribution.paymentMethod,
      proofFileKey: contribution.proofFileKey,
      paymentRef: contribution.paymentRef,
      note: contribution.note,
      submittedAt: contribution.submittedAt,
      confirmedAt: contribution.confirmedAt,
      rejectedAt: contribution.rejectedAt,
      rejectReason: contribution.rejectReason,
      createdAt: contribution.createdAt,
      user: {
        id: contribution.user.id,
        fullName: contribution.user.fullName,
        phone: includePhone ? contribution.user.phone : null,
      },
    };
  }
}
