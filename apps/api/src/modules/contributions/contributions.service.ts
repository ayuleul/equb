import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  ContributionStatus,
  DisputeStatus,
  CycleState,
  CycleStatus,
  GroupPaymentMethod,
  GroupRuleFineType,
  LedgerEntryType,
  MemberRole,
  NotificationType,
  Prisma,
} from '@prisma/client';

import { AuditService } from '../../common/audit/audit.service';
import { isParticipatingMemberStatus } from '../../common/membership/member-status.util';
import { PrismaService } from '../../common/prisma/prisma.service';
import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import { CreateContributionDisputeDto } from './dto/create-contribution-dispute.dto';
import { MediateDisputeDto } from './dto/mediate-dispute.dto';
import { NotificationsService } from '../notifications/notifications.service';
import { RejectContributionDto } from './dto/reject-contribution.dto';
import { ResolveDisputeDto } from './dto/resolve-dispute.dto';
import { SubmitContributionDto } from './dto/submit-contribution.dto';
import {
  ContributionDisputeResponseDto,
  ContributionListResponseDto,
  ContributionResponseDto,
  CycleEvaluationResponseDto,
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

type ContributionDisputeRecord = Prisma.ContributionDisputeGetPayload<{
  select: {
    id: true;
    groupId: true;
    cycleId: true;
    contributionId: true;
    reportedByUserId: true;
    status: true;
    reason: true;
    note: true;
    mediationNote: true;
    mediatedAt: true;
    mediatedByUserId: true;
    resolutionOutcome: true;
    resolutionNote: true;
    resolvedAt: true;
    resolvedByUserId: true;
    createdAt: true;
    updatedAt: true;
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
            lateMarkedAt: null,
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

        await this.syncCycleContributionCounts(tx, cycleId);
        await this.recomputeCycleCollectionState(tx, cycleId);

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
          existing.status !== ContributionStatus.SUBMITTED &&
          existing.status !== ContributionStatus.LATE
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

        await this.syncCycleContributionCounts(tx, updated.cycleId);
        await this.recomputeCycleCollectionState(tx, updated.cycleId);

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
          existing.status !== ContributionStatus.SUBMITTED &&
          existing.status !== ContributionStatus.LATE
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

        await this.syncCycleContributionCounts(tx, existing.cycleId);
        await this.recomputeCycleCollectionState(tx, existing.cycleId);

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

  async evaluateCycleCollection(
    currentUser: AuthenticatedUser,
    cycleId: string,
  ): Promise<CycleEvaluationResponseDto> {
    const evaluatedAt = new Date();

    const evaluation = await this.prisma.$transaction(async (tx) => {
      const cycle = await tx.equbCycle.findUnique({
        where: { id: cycleId },
        include: {
          group: {
            select: {
              id: true,
              name: true,
              rules: {
                select: {
                  graceDays: true,
                  fineType: true,
                  fineAmount: true,
                  strictCollection: true,
                },
              },
            },
          },
          contributions: {
            select: {
              id: true,
              userId: true,
              amount: true,
              status: true,
            },
          },
        },
      });

      if (!cycle) {
        throw new NotFoundException('Cycle not found');
      }

      if (cycle.status !== CycleStatus.OPEN) {
        throw new BadRequestException(
          'Only open cycles can be evaluated for collection',
        );
      }

      if (!cycle.group.rules) {
        throw new BadRequestException(
          'Group rules are not configured for this cycle',
        );
      }

      const graceDays = Math.max(cycle.group.rules.graceDays, 0);
      const graceDeadline = this.addDays(cycle.dueAt, graceDays);
      const isGracePast = evaluatedAt.getTime() > graceDeadline.getTime();

      let lateMarkedCount = 0;
      let fineLedgerEntriesCreated = 0;
      const notifiedMemberUserIds = new Set<string>();
      const notifiedGuarantorUserIds = new Set<string>();

      if (isGracePast) {
        for (const contribution of cycle.contributions) {
          if (this.isContributionVerified(contribution.status)) {
            continue;
          }

          if (contribution.status !== ContributionStatus.LATE) {
            await tx.contribution.update({
              where: { id: contribution.id },
              data: {
                status: ContributionStatus.LATE,
                lateMarkedAt: evaluatedAt,
              },
            });
            lateMarkedCount += 1;
          }

          notifiedMemberUserIds.add(contribution.userId);

          if (
            cycle.group.rules.fineType === GroupRuleFineType.FIXED_AMOUNT &&
            cycle.group.rules.fineAmount > 0
          ) {
            const existingFine = await tx.ledgerEntry.findFirst({
              where: {
                contributionId: contribution.id,
                type: LedgerEntryType.LATE_FINE,
              },
              select: { id: true },
            });

            if (!existingFine) {
              await tx.ledgerEntry.create({
                data: {
                  groupId: cycle.groupId,
                  cycleId: cycle.id,
                  contributionId: contribution.id,
                  userId: contribution.userId,
                  type: LedgerEntryType.LATE_FINE,
                  amount: cycle.group.rules.fineAmount,
                  note: `Late contribution fine after ${graceDays} grace day(s).`,
                },
              });
              fineLedgerEntriesCreated += 1;
            }
          }

          const member = await tx.equbMember.findUnique({
            where: {
              groupId_userId: {
                groupId: cycle.groupId,
                userId: contribution.userId,
              },
            },
            select: {
              guarantorUserId: true,
            },
          });

          if (member?.guarantorUserId) {
            notifiedGuarantorUserIds.add(member.guarantorUserId);
          }
        }
      }

      await this.syncCycleContributionCounts(tx, cycle.id);

      const state = await this.recomputeCycleCollectionState(tx, cycle.id);
      const refreshedContributions = await tx.contribution.findMany({
        where: { cycleId: cycle.id },
        select: {
          id: true,
          status: true,
        },
      });
      const overdueCount = refreshedContributions.filter(
        (item) => !this.isContributionVerified(item.status),
      ).length;

      return {
        cycleId: cycle.id,
        groupId: cycle.groupId,
        groupName: cycle.group.name,
        dueAt: cycle.dueAt,
        graceDays,
        graceDeadline,
        strictCollection: state.strictCollection,
        allVerified: state.allVerified,
        readyForPayout: state.readyForPayout,
        overdueCount,
        lateMarkedCount,
        fineLedgerEntriesCreated,
        notifiedMemberUserIds: [...notifiedMemberUserIds],
        notifiedGuarantorUserIds: [...notifiedGuarantorUserIds],
      };
    });

    await this.auditService.log(
      'CYCLE_COLLECTION_EVALUATED',
      currentUser.id,
      {
        cycleId: evaluation.cycleId,
        overdueCount: evaluation.overdueCount,
        lateMarkedCount: evaluation.lateMarkedCount,
        fineLedgerEntriesCreated: evaluation.fineLedgerEntriesCreated,
        strictCollection: evaluation.strictCollection,
        readyForPayout: evaluation.readyForPayout,
      },
      evaluation.groupId,
    );

    const graceDateKey = evaluation.graceDeadline.toISOString().slice(0, 10);
    const memberBody =
      evaluation.fineLedgerEntriesCreated > 0
        ? `Your contribution is late and a fine may apply. Please submit and verify payment for ${evaluation.groupName}.`
        : `Your contribution is late for ${evaluation.groupName}. Please submit and verify payment.`;

    await Promise.all(
      evaluation.notifiedMemberUserIds.map((userId) =>
        this.notificationsService.notifyUser(userId, {
          type: NotificationType.CONTRIBUTION_LATE,
          title: 'Contribution marked late',
          body: memberBody,
          groupId: evaluation.groupId,
          data: {
            groupId: evaluation.groupId,
            cycleId: evaluation.cycleId,
            graceDeadline: evaluation.graceDeadline.toISOString(),
          },
          dedupKey: `late-member:${userId}:${evaluation.cycleId}:${graceDateKey}`,
        }),
      ),
    );

    await Promise.all(
      evaluation.notifiedGuarantorUserIds.map((userId) =>
        this.notificationsService.notifyUser(userId, {
          type: NotificationType.CONTRIBUTION_LATE,
          title: 'Guarantor alert',
          body: `A guaranteed member is late on contribution for ${evaluation.groupName}.`,
          groupId: evaluation.groupId,
          data: {
            groupId: evaluation.groupId,
            cycleId: evaluation.cycleId,
            graceDeadline: evaluation.graceDeadline.toISOString(),
          },
          dedupKey: `late-guarantor:${userId}:${evaluation.cycleId}:${graceDateKey}`,
        }),
      ),
    );

    return {
      cycleId: evaluation.cycleId,
      dueAt: evaluation.dueAt,
      graceDays: evaluation.graceDays,
      graceDeadline: evaluation.graceDeadline,
      evaluatedAt,
      strictCollection: evaluation.strictCollection,
      allVerified: evaluation.allVerified,
      readyForPayout: evaluation.readyForPayout,
      overdueCount: evaluation.overdueCount,
      lateMarkedCount: evaluation.lateMarkedCount,
      fineLedgerEntriesCreated: evaluation.fineLedgerEntriesCreated,
      notifiedMembersCount: evaluation.notifiedMemberUserIds.length,
      notifiedGuarantorsCount: evaluation.notifiedGuarantorUserIds.length,
    };
  }

  async createContributionDispute(
    currentUser: AuthenticatedUser,
    contributionId: string,
    dto: CreateContributionDisputeDto,
  ): Promise<ContributionDisputeResponseDto> {
    const normalizedReason = dto.reason.trim();
    const normalizedNote = dto.note?.trim();

    const dispute = await this.prisma.$transaction(async (tx) => {
      const contribution = await tx.contribution.findUnique({
        where: { id: contributionId },
        select: {
          id: true,
          groupId: true,
          cycleId: true,
          userId: true,
        },
      });

      if (!contribution) {
        throw new NotFoundException('Contribution not found');
      }

      const membership = await tx.equbMember.findUnique({
        where: {
          groupId_userId: {
            groupId: contribution.groupId,
            userId: currentUser.id,
          },
        },
        select: {
          status: true,
          role: true,
        },
      });

      if (!membership || !isParticipatingMemberStatus(membership.status)) {
        throw new ForbiddenException('Joined group membership is required');
      }

      const canOpenDispute =
        currentUser.id === contribution.userId ||
        membership.role === MemberRole.ADMIN;
      if (!canOpenDispute) {
        throw new ForbiddenException(
          'Only the contributor or a group admin can open a dispute',
        );
      }

      const existingOpenDispute = await tx.contributionDispute.findFirst({
        where: {
          contributionId: contribution.id,
          status: {
            in: [DisputeStatus.OPEN, DisputeStatus.MEDIATING],
          },
        },
        select: { id: true },
      });

      if (existingOpenDispute) {
        throw new BadRequestException(
          'An open dispute already exists for this contribution',
        );
      }

      return tx.contributionDispute.create({
        data: {
          groupId: contribution.groupId,
          cycleId: contribution.cycleId,
          contributionId: contribution.id,
          reportedByUserId: currentUser.id,
          status: DisputeStatus.OPEN,
          reason: normalizedReason,
          note: normalizedNote ?? null,
        },
        select: {
          id: true,
          groupId: true,
          cycleId: true,
          contributionId: true,
          reportedByUserId: true,
          status: true,
          reason: true,
          note: true,
          mediationNote: true,
          mediatedAt: true,
          mediatedByUserId: true,
          resolutionOutcome: true,
          resolutionNote: true,
          resolvedAt: true,
          resolvedByUserId: true,
          createdAt: true,
          updatedAt: true,
        },
      });
    });

    await this.auditService.log(
      'DISPUTE_OPENED',
      currentUser.id,
      {
        disputeId: dispute.id,
        contributionId: dispute.contributionId,
        reason: dispute.reason,
      },
      dispute.groupId,
    );

    await this.notificationsService.notifyGroupAdmins(
      dispute.groupId,
      {
        type: NotificationType.DISPUTE_OPENED,
        title: 'Contribution dispute opened',
        body: 'A contribution dispute requires mediation.',
        data: {
          groupId: dispute.groupId,
          cycleId: dispute.cycleId,
          contributionId: dispute.contributionId,
          disputeId: dispute.id,
        },
      },
      { excludeUserId: currentUser.id },
    );

    const contributionOwner = await this.prisma.contribution.findUnique({
      where: { id: dispute.contributionId },
      select: { userId: true },
    });
    if (contributionOwner && contributionOwner.userId !== currentUser.id) {
      await this.notificationsService.notifyUser(contributionOwner.userId, {
        type: NotificationType.DISPUTE_OPENED,
        title: 'Dispute opened on contribution',
        body: 'A dispute has been opened for your contribution.',
        groupId: dispute.groupId,
        data: {
          groupId: dispute.groupId,
          cycleId: dispute.cycleId,
          contributionId: dispute.contributionId,
          disputeId: dispute.id,
        },
      });
    }

    return this.toContributionDisputeResponse(dispute);
  }

  async listContributionDisputes(
    currentUser: AuthenticatedUser,
    contributionId: string,
  ): Promise<ContributionDisputeResponseDto[]> {
    const contribution = await this.prisma.contribution.findUnique({
      where: { id: contributionId },
      select: {
        id: true,
        groupId: true,
      },
    });

    if (!contribution) {
      throw new NotFoundException('Contribution not found');
    }

    const membership = await this.prisma.equbMember.findUnique({
      where: {
        groupId_userId: {
          groupId: contribution.groupId,
          userId: currentUser.id,
        },
      },
      select: {
        status: true,
      },
    });

    if (!membership || !isParticipatingMemberStatus(membership.status)) {
      throw new ForbiddenException('Joined group membership is required');
    }

    const disputes = await this.prisma.contributionDispute.findMany({
      where: {
        contributionId: contribution.id,
      },
      select: {
        id: true,
        groupId: true,
        cycleId: true,
        contributionId: true,
        reportedByUserId: true,
        status: true,
        reason: true,
        note: true,
        mediationNote: true,
        mediatedAt: true,
        mediatedByUserId: true,
        resolutionOutcome: true,
        resolutionNote: true,
        resolvedAt: true,
        resolvedByUserId: true,
        createdAt: true,
        updatedAt: true,
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    return disputes.map((item) => this.toContributionDisputeResponse(item));
  }

  async mediateDispute(
    currentUser: AuthenticatedUser,
    disputeId: string,
    dto: MediateDisputeDto,
  ): Promise<ContributionDisputeResponseDto> {
    const normalizedNote = dto.note.trim();

    const dispute = await this.prisma.$transaction(async (tx) => {
      const existing = await tx.contributionDispute.findUnique({
        where: { id: disputeId },
        select: {
          id: true,
          groupId: true,
          cycleId: true,
          contributionId: true,
          reportedByUserId: true,
          status: true,
          reason: true,
          note: true,
          mediationNote: true,
          mediatedAt: true,
          mediatedByUserId: true,
          resolutionOutcome: true,
          resolutionNote: true,
          resolvedAt: true,
          resolvedByUserId: true,
          createdAt: true,
          updatedAt: true,
        },
      });

      if (!existing) {
        throw new NotFoundException('Dispute not found');
      }

      if (existing.status !== DisputeStatus.OPEN) {
        throw new BadRequestException(
          'Only open disputes can transition to mediating',
        );
      }

      return tx.contributionDispute.update({
        where: { id: disputeId },
        data: {
          status: DisputeStatus.MEDIATING,
          mediationNote: normalizedNote,
          mediatedAt: new Date(),
          mediatedByUserId: currentUser.id,
        },
        select: {
          id: true,
          groupId: true,
          cycleId: true,
          contributionId: true,
          reportedByUserId: true,
          status: true,
          reason: true,
          note: true,
          mediationNote: true,
          mediatedAt: true,
          mediatedByUserId: true,
          resolutionOutcome: true,
          resolutionNote: true,
          resolvedAt: true,
          resolvedByUserId: true,
          createdAt: true,
          updatedAt: true,
        },
      });
    });

    await this.auditService.log(
      'DISPUTE_MEDIATING',
      currentUser.id,
      {
        disputeId: dispute.id,
        contributionId: dispute.contributionId,
      },
      dispute.groupId,
    );

    await this.notificationsService.notifyUser(dispute.reportedByUserId, {
      type: NotificationType.DISPUTE_MEDIATING,
      title: 'Dispute mediation started',
      body: 'An admin has started mediation for your contribution dispute.',
      groupId: dispute.groupId,
      data: {
        groupId: dispute.groupId,
        cycleId: dispute.cycleId,
        contributionId: dispute.contributionId,
        disputeId: dispute.id,
      },
    });

    const contributionOwner = await this.prisma.contribution.findUnique({
      where: { id: dispute.contributionId },
      select: { userId: true },
    });
    if (
      contributionOwner &&
      contributionOwner.userId !== dispute.reportedByUserId
    ) {
      await this.notificationsService.notifyUser(contributionOwner.userId, {
        type: NotificationType.DISPUTE_MEDIATING,
        title: 'Dispute mediation started',
        body: 'An admin has started mediation for a dispute on your contribution.',
        groupId: dispute.groupId,
        data: {
          groupId: dispute.groupId,
          cycleId: dispute.cycleId,
          contributionId: dispute.contributionId,
          disputeId: dispute.id,
        },
      });
    }

    return this.toContributionDisputeResponse(dispute);
  }

  async resolveDispute(
    currentUser: AuthenticatedUser,
    disputeId: string,
    dto: ResolveDisputeDto,
  ): Promise<ContributionDisputeResponseDto> {
    const normalizedOutcome = dto.outcome.trim();
    const normalizedNote = dto.note?.trim();

    const dispute = await this.prisma.$transaction(async (tx) => {
      const existing = await tx.contributionDispute.findUnique({
        where: { id: disputeId },
        select: {
          id: true,
          groupId: true,
          cycleId: true,
          contributionId: true,
          reportedByUserId: true,
          status: true,
          reason: true,
          note: true,
          mediationNote: true,
          mediatedAt: true,
          mediatedByUserId: true,
          resolutionOutcome: true,
          resolutionNote: true,
          resolvedAt: true,
          resolvedByUserId: true,
          createdAt: true,
          updatedAt: true,
        },
      });

      if (!existing) {
        throw new NotFoundException('Dispute not found');
      }

      if (
        existing.status !== DisputeStatus.OPEN &&
        existing.status !== DisputeStatus.MEDIATING
      ) {
        throw new BadRequestException(
          'Only open or mediating disputes can be resolved',
        );
      }

      return tx.contributionDispute.update({
        where: { id: disputeId },
        data: {
          status: DisputeStatus.RESOLVED,
          resolutionOutcome: normalizedOutcome,
          resolutionNote: normalizedNote ?? null,
          resolvedAt: new Date(),
          resolvedByUserId: currentUser.id,
        },
        select: {
          id: true,
          groupId: true,
          cycleId: true,
          contributionId: true,
          reportedByUserId: true,
          status: true,
          reason: true,
          note: true,
          mediationNote: true,
          mediatedAt: true,
          mediatedByUserId: true,
          resolutionOutcome: true,
          resolutionNote: true,
          resolvedAt: true,
          resolvedByUserId: true,
          createdAt: true,
          updatedAt: true,
        },
      });
    });

    await this.auditService.log(
      'DISPUTE_RESOLVED',
      currentUser.id,
      {
        disputeId: dispute.id,
        contributionId: dispute.contributionId,
        outcome: dispute.resolutionOutcome,
      },
      dispute.groupId,
    );

    await this.notificationsService.notifyUser(dispute.reportedByUserId, {
      type: NotificationType.DISPUTE_RESOLVED,
      title: 'Dispute resolved',
      body: 'Your contribution dispute has been resolved by an admin.',
      groupId: dispute.groupId,
      data: {
        groupId: dispute.groupId,
        cycleId: dispute.cycleId,
        contributionId: dispute.contributionId,
        disputeId: dispute.id,
      },
    });

    const contributionOwner = await this.prisma.contribution.findUnique({
      where: { id: dispute.contributionId },
      select: { userId: true },
    });
    if (
      contributionOwner &&
      contributionOwner.userId !== dispute.reportedByUserId
    ) {
      await this.notificationsService.notifyUser(contributionOwner.userId, {
        type: NotificationType.DISPUTE_RESOLVED,
        title: 'Dispute resolved',
        body: 'A dispute on your contribution has been resolved by an admin.',
        groupId: dispute.groupId,
        data: {
          groupId: dispute.groupId,
          cycleId: dispute.cycleId,
          contributionId: dispute.contributionId,
          disputeId: dispute.id,
        },
      });
    }

    return this.toContributionDisputeResponse(dispute);
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
      late: 0,
    };

    for (const contribution of contributions) {
      if (contribution.status === ContributionStatus.PENDING) {
        summary.pending += 1;
      }
      if (contribution.status === ContributionStatus.LATE) {
        summary.late += 1;
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

  private async recomputeCycleCollectionState(
    tx: Prisma.TransactionClient,
    cycleId: string,
  ): Promise<{
    strictCollection: boolean;
    allVerified: boolean;
    readyForPayout: boolean;
  }> {
    const cycle = await tx.equbCycle.findUnique({
      where: { id: cycleId },
      select: {
        id: true,
        status: true,
        state: true,
        group: {
          select: {
            rules: {
              select: {
                strictCollection: true,
              },
            },
          },
        },
        contributions: {
          select: {
            status: true,
          },
        },
      },
    });

    if (!cycle) {
      throw new NotFoundException('Cycle not found');
    }

    const strictCollection = cycle.group.rules?.strictCollection ?? false;
    const allVerified =
      cycle.contributions.length > 0 &&
      cycle.contributions.every((item) =>
        this.isContributionVerified(item.status),
      );
    const anyVerified = cycle.contributions.some((item) =>
      this.isContributionVerified(item.status),
    );

    const readyForPayout = strictCollection ? allVerified : anyVerified;
    const targetState = readyForPayout
      ? CycleState.READY_FOR_PAYOUT
      : CycleState.COLLECTING;

    if (
      cycle.status === CycleStatus.OPEN &&
      cycle.state !== CycleState.DISBURSED &&
      cycle.state !== CycleState.CLOSED &&
      cycle.state !== targetState
    ) {
      await tx.equbCycle.update({
        where: { id: cycle.id },
        data: {
          state: targetState,
        },
      });
    }

    return {
      strictCollection,
      allVerified,
      readyForPayout,
    };
  }

  private isContributionVerified(status: ContributionStatus): boolean {
    return (
      status === ContributionStatus.VERIFIED ||
      status === ContributionStatus.CONFIRMED
    );
  }

  private addDays(value: Date, days: number): Date {
    const date = new Date(value);
    date.setDate(date.getDate() + days);
    return date;
  }

  private toContributionDisputeResponse(
    dispute: ContributionDisputeRecord,
  ): ContributionDisputeResponseDto {
    return {
      id: dispute.id,
      groupId: dispute.groupId,
      cycleId: dispute.cycleId,
      contributionId: dispute.contributionId,
      reportedByUserId: dispute.reportedByUserId,
      status: dispute.status,
      reason: dispute.reason,
      note: dispute.note,
      mediationNote: dispute.mediationNote,
      mediatedAt: dispute.mediatedAt,
      mediatedByUserId: dispute.mediatedByUserId,
      resolutionOutcome: dispute.resolutionOutcome,
      resolutionNote: dispute.resolutionNote,
      resolvedAt: dispute.resolvedAt,
      resolvedByUserId: dispute.resolvedByUserId,
      createdAt: dispute.createdAt,
      updatedAt: dispute.updatedAt,
    };
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
      lateMarkedAt: contribution.lateMarkedAt,
      createdAt: contribution.createdAt,
      user: {
        id: contribution.user.id,
        fullName: contribution.user.fullName,
        phone: includePhone ? contribution.user.phone : null,
      },
    };
  }
}
