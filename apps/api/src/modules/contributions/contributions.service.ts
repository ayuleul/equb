import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  ContributionStatus,
  MemberRole,
  MemberStatus,
  NotificationType,
  Prisma,
} from '@prisma/client';

import { AuditService } from '../../common/audit/audit.service';
import { PrismaService } from '../../common/prisma/prisma.service';
import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import { NotificationsService } from '../notifications/notifications.service';
import { ConfirmContributionDto } from './dto/confirm-contribution.dto';
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
          },
        },
      },
    });

    if (!cycle) {
      throw new NotFoundException('Cycle not found');
    }

    if (cycle.status !== 'OPEN') {
      throw new BadRequestException(
        'Contributions can only be submitted for open cycles',
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

    if (!membership || membership.status !== MemberStatus.ACTIVE) {
      throw new ForbiddenException(
        'Only active group members can submit contributions',
      );
    }

    if (
      dto.proofFileKey &&
      !isContributionProofKeyScopedTo(
        dto.proofFileKey,
        cycle.groupId,
        cycle.id,
        currentUser.id,
      )
    ) {
      throw new BadRequestException(
        'proofFileKey does not match allowed scope',
      );
    }

    const amount = dto.amount ?? cycle.group.contributionAmount;
    const submittedAt = new Date();

    const contribution = await this.prisma.$transaction(
      async (tx): Promise<ContributionWithUser> => {
        const existing = await tx.contribution.findUnique({
          where: {
            cycleId_userId: {
              cycleId,
              userId: currentUser.id,
            },
          },
        });

        let upserted: ContributionWithUser;

        if (!existing) {
          upserted = await tx.contribution.create({
            data: {
              groupId: cycle.groupId,
              cycleId,
              userId: currentUser.id,
              amount,
              status: ContributionStatus.SUBMITTED,
              proofFileKey: dto.proofFileKey ?? null,
              paymentRef: dto.paymentRef ?? null,
              note: dto.note ?? null,
              submittedAt,
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
        } else {
          if (existing.status === ContributionStatus.CONFIRMED) {
            throw new BadRequestException(
              'Confirmed contribution cannot be modified',
            );
          }

          upserted = await tx.contribution.update({
            where: {
              id: existing.id,
            },
            data: {
              amount,
              status: ContributionStatus.SUBMITTED,
              proofFileKey: dto.proofFileKey ?? null,
              paymentRef: dto.paymentRef ?? null,
              note: dto.note ?? null,
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
        }

        await this.syncCycleContributionCounts(tx, cycleId);

        return upserted;
      },
    );

    await this.auditService.log(
      'CONTRIBUTION_SUBMITTED',
      currentUser.id,
      {
        contributionId: contribution.id,
        cycleId,
        amount,
      },
      cycle.groupId,
    );

    await this.notificationsService.notifyGroupAdmins(
      cycle.groupId,
      {
        type: NotificationType.CONTRIBUTION_SUBMITTED,
        title: 'Contribution submitted',
        body: `${currentUser.phone} submitted a contribution.`,
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

  async confirmContribution(
    currentUser: AuthenticatedUser,
    contributionId: string,
    dto: ConfirmContributionDto,
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

        if (existing.status !== ContributionStatus.SUBMITTED) {
          throw new BadRequestException(
            'Only submitted contributions can be confirmed',
          );
        }

        const updated = await tx.contribution.update({
          where: { id: contributionId },
          data: {
            status: ContributionStatus.CONFIRMED,
            note: dto.note ?? existing.note,
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

        await this.syncCycleContributionCounts(tx, existing.cycleId);

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
      title: 'Contribution confirmed',
      body: 'Your contribution has been confirmed.',
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

        if (existing.status !== ContributionStatus.SUBMITTED) {
          throw new BadRequestException(
            'Only submitted contributions can be rejected',
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
      requesterMembership.status !== MemberStatus.ACTIVE
    ) {
      throw new ForbiddenException('Active group membership is required');
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
    };

    for (const contribution of contributions) {
      if (contribution.status === ContributionStatus.PENDING) {
        summary.pending += 1;
      }
      if (contribution.status === ContributionStatus.SUBMITTED) {
        summary.submitted += 1;
      }
      if (contribution.status === ContributionStatus.CONFIRMED) {
        summary.confirmed += 1;
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
          status: ContributionStatus.SUBMITTED,
        },
      }),
      tx.contribution.count({
        where: {
          cycleId,
          status: ContributionStatus.CONFIRMED,
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
