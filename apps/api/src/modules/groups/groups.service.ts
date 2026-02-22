import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  AuctionStatus,
  CycleStatus,
  GroupStatus,
  MemberRole,
  MemberStatus,
  NotificationType,
  PayoutMode,
  Prisma,
} from '@prisma/client';
import { randomBytes, randomInt } from 'crypto';

import { AuditService } from '../../common/audit/audit.service';
import { DateService } from '../../common/date/date.service';
import { PrismaService } from '../../common/prisma/prisma.service';
import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import { CreateGroupDto } from './dto/create-group.dto';
import { CreateInviteDto } from './dto/create-invite.dto';
import { GenerateCyclesDto } from './dto/generate-cycles.dto';
import { JoinGroupDto } from './dto/join-group.dto';
import { PayoutOrderItemDto } from './dto/payout-order-item.dto';
import { UpdateMemberRoleDto } from './dto/update-member-role.dto';
import { UpdateMemberStatusDto } from './dto/update-member-status.dto';
import {
  GroupCycleResponseDto,
  GroupDetailResponseDto,
  GroupJoinResponseDto,
  GroupMemberResponseDto,
  RoundStartResponseDto,
  GroupSummaryResponseDto,
  InviteCodeResponseDto,
} from './entities/groups.entities';
import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class GroupsService {
  private readonly logger = new Logger(GroupsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly auditService: AuditService,
    private readonly configService: ConfigService,
    private readonly dateService: DateService,
    private readonly notificationsService: NotificationsService,
  ) {}

  async createGroup(
    currentUser: AuthenticatedUser,
    dto: CreateGroupDto,
  ): Promise<GroupDetailResponseDto> {
    const startDate = new Date(dto.startDate);
    const currency = (dto.currency ?? 'ETB').toUpperCase();

    const group = await this.prisma.$transaction(async (tx) => {
      const createdGroup = await tx.equbGroup.create({
        data: {
          name: dto.name.trim(),
          currency,
          contributionAmount: dto.contributionAmount,
          frequency: dto.frequency,
          startDate,
          createdByUserId: currentUser.id,
        },
      });

      await tx.equbMember.create({
        data: {
          groupId: createdGroup.id,
          userId: currentUser.id,
          role: MemberRole.ADMIN,
          status: MemberStatus.ACTIVE,
          joinedAt: new Date(),
        },
      });

      return createdGroup;
    });

    await this.auditService.log(
      'GROUP_CREATED',
      currentUser.id,
      {
        groupId: group.id,
      },
      group.id,
    );

    return {
      id: group.id,
      name: group.name,
      currency: group.currency,
      contributionAmount: group.contributionAmount,
      frequency: group.frequency,
      startDate: group.startDate,
      status: group.status,
      createdByUserId: group.createdByUserId,
      createdAt: group.createdAt,
      strictPayout: group.strictPayout,
      timezone: group.timezone,
      membership: {
        role: MemberRole.ADMIN,
        status: MemberStatus.ACTIVE,
      },
    };
  }

  async listGroups(
    currentUser: AuthenticatedUser,
  ): Promise<GroupSummaryResponseDto[]> {
    const memberships = await this.prisma.equbMember.findMany({
      where: {
        userId: currentUser.id,
        status: MemberStatus.ACTIVE,
      },
      include: {
        group: true,
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    return memberships.map((membership) => ({
      id: membership.group.id,
      name: membership.group.name,
      currency: membership.group.currency,
      contributionAmount: membership.group.contributionAmount,
      frequency: membership.group.frequency,
      startDate: membership.group.startDate,
      status: membership.group.status,
    }));
  }

  async getGroupDetails(
    currentUser: AuthenticatedUser,
    groupId: string,
  ): Promise<GroupDetailResponseDto> {
    const [group, membership] = await Promise.all([
      this.prisma.equbGroup.findUnique({
        where: { id: groupId },
      }),
      this.prisma.equbMember.findUnique({
        where: {
          groupId_userId: {
            groupId,
            userId: currentUser.id,
          },
        },
      }),
    ]);

    if (!group) {
      throw new NotFoundException('Group not found');
    }

    if (!membership) {
      throw new NotFoundException('Membership not found');
    }

    return {
      id: group.id,
      name: group.name,
      currency: group.currency,
      contributionAmount: group.contributionAmount,
      frequency: group.frequency,
      startDate: group.startDate,
      status: group.status,
      createdByUserId: group.createdByUserId,
      createdAt: group.createdAt,
      strictPayout: group.strictPayout,
      timezone: group.timezone,
      membership: {
        role: membership.role,
        status: membership.status,
      },
    };
  }

  async createInvite(
    currentUser: AuthenticatedUser,
    groupId: string,
    dto: CreateInviteDto,
  ): Promise<InviteCodeResponseDto> {
    const group = await this.prisma.equbGroup.findUnique({
      where: { id: groupId },
      select: { id: true, status: true },
    });

    if (!group) {
      throw new NotFoundException('Group not found');
    }

    if (group.status !== GroupStatus.ACTIVE) {
      throw new BadRequestException(
        'Invite codes can only be created for active groups',
      );
    }

    const expiresAt = dto.expiresAt ? new Date(dto.expiresAt) : null;

    if (expiresAt && expiresAt <= new Date()) {
      throw new BadRequestException('Invite expiry must be in the future');
    }

    let createdInvite: { code: string } | null = null;

    for (let attempt = 0; attempt < 5; attempt += 1) {
      const code = this.generateInviteCode();
      try {
        createdInvite = await this.prisma.inviteCode.create({
          data: {
            groupId,
            code,
            createdByUserId: currentUser.id,
            expiresAt,
            maxUses: dto.maxUses ?? null,
          },
          select: {
            code: true,
          },
        });
        break;
      } catch (error) {
        if (
          error instanceof Prisma.PrismaClientKnownRequestError &&
          error.code === 'P2002'
        ) {
          continue;
        }
        throw error;
      }
    }

    if (!createdInvite) {
      throw new ConflictException('Failed to generate unique invite code');
    }

    await this.auditService.log(
      'INVITE_CREATED',
      currentUser.id,
      {
        code: createdInvite.code,
      },
      groupId,
    );

    return {
      code: createdInvite.code,
      joinUrl: this.buildJoinUrl(createdInvite.code),
    };
  }

  async joinGroup(
    currentUser: AuthenticatedUser,
    dto: JoinGroupDto,
  ): Promise<GroupJoinResponseDto> {
    const normalizedCode = dto.code.trim().toUpperCase();

    if (!normalizedCode) {
      throw new BadRequestException('Invite code is required');
    }

    const result = await this.prisma.$transaction(async (tx) => {
      const invite = await tx.inviteCode.findUnique({
        where: { code: normalizedCode },
        include: {
          group: {
            select: {
              id: true,
              status: true,
            },
          },
        },
      });

      if (!invite) {
        throw new NotFoundException('Invite code not found');
      }

      if (invite.isRevoked) {
        throw new BadRequestException('Invite code is revoked');
      }

      if (invite.expiresAt && invite.expiresAt < new Date()) {
        throw new BadRequestException('Invite code is expired');
      }

      if (invite.maxUses !== null && invite.usedCount >= invite.maxUses) {
        throw new BadRequestException('Invite code usage limit reached');
      }

      if (invite.group.status !== GroupStatus.ACTIVE) {
        throw new BadRequestException('Cannot join an archived group');
      }

      const existingMembership = await tx.equbMember.findUnique({
        where: {
          groupId_userId: {
            groupId: invite.groupId,
            userId: currentUser.id,
          },
        },
      });

      if (existingMembership?.status === MemberStatus.REMOVED) {
        throw new ForbiddenException(
          'You were removed from this group and cannot rejoin with invite code',
        );
      }

      if (existingMembership?.status === MemberStatus.ACTIVE) {
        throw new BadRequestException(
          'You are already an active member of this group',
        );
      }

      const joinedAt = new Date();

      let membership: {
        role: MemberRole;
        status: MemberStatus;
        joinedAt: Date | null;
      };

      if (existingMembership) {
        membership = await tx.equbMember.update({
          where: { id: existingMembership.id },
          data: {
            status: MemberStatus.ACTIVE,
            joinedAt,
          },
          select: {
            role: true,
            status: true,
            joinedAt: true,
          },
        });
      } else {
        membership = await tx.equbMember.create({
          data: {
            groupId: invite.groupId,
            userId: currentUser.id,
            role: MemberRole.MEMBER,
            status: MemberStatus.ACTIVE,
            joinedAt,
          },
          select: {
            role: true,
            status: true,
            joinedAt: true,
          },
        });
      }

      const inviteUpdate = await tx.inviteCode.updateMany({
        where: {
          id: invite.id,
          usedCount: invite.usedCount,
          isRevoked: false,
        },
        data: {
          usedCount: {
            increment: 1,
          },
        },
      });

      if (inviteUpdate.count === 0) {
        throw new ConflictException('Invite code is no longer available');
      }

      return {
        groupId: invite.groupId,
        role: membership.role,
        status: membership.status,
        joinedAt: membership.joinedAt,
      };
    });

    await this.auditService.log(
      'MEMBER_JOINED',
      currentUser.id,
      {
        code: normalizedCode,
      },
      result.groupId,
    );

    await this.notificationsService.notifyGroupAdmins(
      result.groupId,
      {
        type: NotificationType.MEMBER_JOINED,
        title: 'New member joined',
        body: `${currentUser.phone} joined your Equb group.`,
        data: {
          groupId: result.groupId,
          joinedUserId: currentUser.id,
        },
      },
      {
        excludeUserId: currentUser.id,
      },
    );

    return result;
  }

  async listMembers(groupId: string): Promise<GroupMemberResponseDto[]> {
    const memberships = await this.prisma.equbMember.findMany({
      where: {
        groupId,
      },
      include: {
        user: {
          select: {
            id: true,
            phone: true,
            fullName: true,
          },
        },
      },
      orderBy: {
        createdAt: 'asc',
      },
    });

    return memberships.map((membership) => ({
      user: membership.user,
      role: membership.role,
      status: membership.status,
      payoutPosition: membership.payoutPosition,
      joinedAt: membership.joinedAt,
    }));
  }

  async updateMemberRole(
    currentUser: AuthenticatedUser,
    groupId: string,
    targetUserId: string,
    dto: UpdateMemberRoleDto,
  ): Promise<GroupMemberResponseDto> {
    const targetMembership = await this.prisma.equbMember.findUnique({
      where: {
        groupId_userId: {
          groupId,
          userId: targetUserId,
        },
      },
      include: {
        user: {
          select: {
            id: true,
            phone: true,
            fullName: true,
          },
        },
      },
    });

    if (!targetMembership) {
      throw new NotFoundException('Member not found in this group');
    }

    if (targetMembership.status !== MemberStatus.ACTIVE) {
      throw new BadRequestException('Only active members can change roles');
    }

    if (
      targetMembership.role === MemberRole.ADMIN &&
      dto.role === MemberRole.MEMBER
    ) {
      const activeAdminCount = await this.countActiveAdmins(groupId);

      if (activeAdminCount <= 1) {
        throw new BadRequestException(
          'Group must retain at least one active admin',
        );
      }
    }

    const updatedMembership = await this.prisma.equbMember.update({
      where: {
        id: targetMembership.id,
      },
      data: {
        role: dto.role,
      },
      include: {
        user: {
          select: {
            id: true,
            phone: true,
            fullName: true,
          },
        },
      },
    });

    await this.auditService.log(
      'MEMBER_ROLE_UPDATED',
      currentUser.id,
      {
        targetUserId,
        previousRole: targetMembership.role,
        nextRole: dto.role,
      },
      groupId,
    );

    return {
      user: updatedMembership.user,
      role: updatedMembership.role,
      status: updatedMembership.status,
      payoutPosition: updatedMembership.payoutPosition,
      joinedAt: updatedMembership.joinedAt,
    };
  }

  async updateMemberStatus(
    currentUser: AuthenticatedUser,
    groupId: string,
    targetUserId: string,
    dto: UpdateMemberStatusDto,
  ): Promise<GroupMemberResponseDto> {
    const [actorMembership, targetMembership] = await Promise.all([
      this.prisma.equbMember.findUnique({
        where: {
          groupId_userId: {
            groupId,
            userId: currentUser.id,
          },
        },
      }),
      this.prisma.equbMember.findUnique({
        where: {
          groupId_userId: {
            groupId,
            userId: targetUserId,
          },
        },
        include: {
          user: {
            select: {
              id: true,
              phone: true,
              fullName: true,
            },
          },
        },
      }),
    ]);

    if (!actorMembership || actorMembership.status !== MemberStatus.ACTIVE) {
      throw new ForbiddenException('Only active members can update statuses');
    }

    if (!targetMembership) {
      throw new NotFoundException('Member not found in this group');
    }

    if (targetMembership.status !== MemberStatus.ACTIVE) {
      throw new BadRequestException('Only active members can change status');
    }

    if (dto.status === 'LEFT') {
      if (currentUser.id !== targetUserId) {
        throw new ForbiddenException('Members can only leave for themselves');
      }
    }

    if (dto.status === 'REMOVED') {
      if (currentUser.id === targetUserId) {
        throw new BadRequestException('Use LEFT status to leave group');
      }

      if (actorMembership.role !== MemberRole.ADMIN) {
        throw new ForbiddenException('Only admins can remove members');
      }
    }

    if (targetMembership.role === MemberRole.ADMIN) {
      const activeAdminCount = await this.countActiveAdmins(groupId);
      if (activeAdminCount <= 1) {
        throw new BadRequestException(
          'Group must retain at least one active admin',
        );
      }
    }

    const updatedMembership = await this.prisma.equbMember.update({
      where: {
        id: targetMembership.id,
      },
      data: {
        status: dto.status,
      },
      include: {
        user: {
          select: {
            id: true,
            phone: true,
            fullName: true,
          },
        },
      },
    });

    await this.auditService.log(
      'MEMBER_STATUS_UPDATED',
      currentUser.id,
      {
        targetUserId,
        previousStatus: targetMembership.status,
        nextStatus: dto.status,
      },
      groupId,
    );

    return {
      user: updatedMembership.user,
      role: updatedMembership.role,
      status: updatedMembership.status,
      payoutPosition: updatedMembership.payoutPosition,
      joinedAt: updatedMembership.joinedAt,
    };
  }

  async updatePayoutOrder(
    currentUser: AuthenticatedUser,
    groupId: string,
    payload: PayoutOrderItemDto[],
  ): Promise<GroupMemberResponseDto[]> {
    if (payload.length === 0) {
      throw new BadRequestException('Payout order payload cannot be empty');
    }

    const activeMembers = await this.prisma.equbMember.findMany({
      where: {
        groupId,
        status: MemberStatus.ACTIVE,
      },
      include: {
        user: {
          select: {
            id: true,
            phone: true,
            fullName: true,
          },
        },
      },
      orderBy: {
        createdAt: 'asc',
      },
    });

    if (activeMembers.length === 0) {
      throw new BadRequestException('No active members found for this group');
    }

    if (payload.length !== activeMembers.length) {
      throw new BadRequestException(
        'Payout order must include every active member exactly once',
      );
    }

    const activeUserIds = new Set(activeMembers.map((member) => member.userId));
    const payloadUserIds = payload.map((item) => item.userId);

    if (new Set(payloadUserIds).size !== payloadUserIds.length) {
      throw new BadRequestException('Duplicate userId in payout order payload');
    }

    for (const userId of payloadUserIds) {
      if (!activeUserIds.has(userId)) {
        throw new BadRequestException(
          `Payout order contains non-active member userId=${userId}`,
        );
      }
    }

    const payoutPositions = payload.map((item) => item.payoutPosition);
    this.assertContiguousPositions(payoutPositions);

    const payoutPositionByUserId = new Map(
      payload.map((item) => [item.userId, item.payoutPosition]),
    );

    const updatedMembers = await this.prisma.$transaction(async (tx) => {
      await Promise.all(
        activeMembers.map((member) => {
          const payoutPosition = payoutPositionByUserId.get(member.userId);

          if (!payoutPosition) {
            throw new BadRequestException(
              `Missing payout position for userId=${member.userId}`,
            );
          }

          return tx.equbMember.update({
            where: {
              id: member.id,
            },
            data: {
              payoutPosition,
            },
          });
        }),
      );

      return tx.equbMember.findMany({
        where: {
          groupId,
        },
        include: {
          user: {
            select: {
              id: true,
              phone: true,
              fullName: true,
            },
          },
        },
        orderBy: [{ payoutPosition: 'asc' }, { createdAt: 'asc' }],
      });
    });

    await this.auditService.log(
      'PAYOUT_ORDER_UPDATED',
      currentUser.id,
      {
        payload,
      },
      groupId,
    );

    return updatedMembers.map((member) => ({
      user: member.user,
      role: member.role,
      status: member.status,
      payoutPosition: member.payoutPosition,
      joinedAt: member.joinedAt,
    }));
  }

  async startRound(
    currentUser: AuthenticatedUser,
    groupId: string,
  ): Promise<RoundStartResponseDto> {
    const round = await this.prisma.$transaction(async (tx) => {
      const group = await tx.equbGroup.findUnique({
        where: { id: groupId },
        select: { id: true, status: true },
      });

      if (!group) {
        throw new NotFoundException('Group not found');
      }

      if (group.status !== GroupStatus.ACTIVE) {
        throw new BadRequestException(
          'Rounds can only be started for active groups',
        );
      }

      const existingOpenCycle = await tx.equbCycle.findFirst({
        where: {
          groupId,
          status: CycleStatus.OPEN,
        },
        select: { id: true },
      });

      if (existingOpenCycle) {
        throw new BadRequestException(
          'Cannot start a new round while a cycle is still open',
        );
      }

      const existingActiveRound = await tx.equbRound.findFirst({
        where: {
          groupId,
          closedAt: null,
        },
        select: { id: true },
      });

      if (existingActiveRound) {
        throw new BadRequestException('An active round already exists');
      }

      const activeMembers = await tx.equbMember.findMany({
        where: {
          groupId,
          status: MemberStatus.ACTIVE,
        },
        include: {
          user: {
            select: {
              id: true,
              phone: true,
              fullName: true,
            },
          },
        },
        orderBy: [{ payoutPosition: 'asc' }, { createdAt: 'asc' }],
      });

      if (activeMembers.length === 0) {
        throw new BadRequestException('No active members found for this group');
      }

      const shuffledMembers = this.shuffleRandomDrawMembers(activeMembers);

      const latestRound = await tx.equbRound.findFirst({
        where: { groupId },
        orderBy: {
          roundNo: 'desc',
        },
        select: {
          roundNo: true,
        },
      });

      return tx.equbRound.create({
        data: {
          groupId,
          roundNo: (latestRound?.roundNo ?? 0) + 1,
          payoutMode: PayoutMode.RANDOM_DRAW,
          startedByUserId: currentUser.id,
          schedules: {
            create: shuffledMembers.map((member, index) => ({
              position: index + 1,
              userId: member.userId,
            })),
          },
        },
        include: {
          schedules: {
            include: {
              user: {
                select: {
                  id: true,
                  phone: true,
                  fullName: true,
                },
              },
            },
            orderBy: {
              position: 'asc',
            },
          },
        },
      });
    });

    await this.auditService.log(
      'ROUND_STARTED',
      currentUser.id,
      {
        roundId: round.id,
        roundNo: round.roundNo,
        payoutMode: round.payoutMode,
      },
      groupId,
    );

    await this.auditService.log(
      'SCHEDULE_GENERATED',
      currentUser.id,
      {
        roundId: round.id,
        schedule: round.schedules.map((entry) => ({
          position: entry.position,
          userId: entry.userId,
        })),
      },
      groupId,
    );

    return {
      id: round.id,
      groupId: round.groupId,
      roundNo: round.roundNo,
      payoutMode: round.payoutMode,
      startedByUserId: round.startedByUserId,
      startedAt: round.startedAt,
      schedule: round.schedules.map((entry) => ({
        position: entry.position,
        userId: entry.userId,
        user: entry.user,
      })),
    };
  }

  async generateCycles(
    currentUser: AuthenticatedUser,
    groupId: string,
    dto: GenerateCyclesDto,
  ): Promise<GroupCycleResponseDto> {
    if (dto?.count != null) {
      this.logger.warn(
        `Deprecated generate count payload ignored for groupId=${groupId}`,
      );
    }

    const createdCycle = await this.prisma.$transaction(async (tx) => {
      const group = await tx.equbGroup.findUnique({
        where: {
          id: groupId,
        },
        select: {
          id: true,
          frequency: true,
          startDate: true,
          timezone: true,
          status: true,
        },
      });

      if (!group) {
        throw new NotFoundException('Group not found');
      }

      if (group.status !== GroupStatus.ACTIVE) {
        throw new BadRequestException(
          'Cycles can only be generated for active groups',
        );
      }

      const existingOpenCycle = await tx.equbCycle.findFirst({
        where: {
          groupId,
          status: CycleStatus.OPEN,
        },
      });

      if (existingOpenCycle) {
        throw new ConflictException(
          'An open cycle already exists for this group',
        );
      }

      const activeRound = await tx.equbRound.findFirst({
        where: {
          groupId,
          closedAt: null,
          payoutMode: PayoutMode.RANDOM_DRAW,
        },
        include: {
          schedules: {
            orderBy: {
              position: 'asc',
            },
          },
        },
      });

      if (!activeRound) {
        throw new BadRequestException(
          'Active round is required before generating cycles',
        );
      }

      if (activeRound.schedules.length === 0) {
        throw new BadRequestException(
          'Active round has no payout schedule',
        );
      }

      const latestRoundCycle = await tx.equbCycle.findFirst({
        where: {
          roundId: activeRound.id,
        },
        orderBy: {
          cycleNo: 'desc',
        },
      });

      const nextCycleNo = (latestRoundCycle?.cycleNo ?? 0) + 1;
      if (nextCycleNo > activeRound.schedules.length) {
        await tx.equbRound.update({
          where: { id: activeRound.id },
          data: { closedAt: new Date() },
        });
        throw new ConflictException('Round completed');
      }

      const latestCycle = await tx.equbCycle.findFirst({
        where: { groupId },
        orderBy: [{ dueDate: 'desc' }, { createdAt: 'desc' }],
      });

      const dueDate = latestCycle
        ? this.dateService.advanceDueDate(
            latestCycle.dueDate,
            group.frequency,
            group.timezone,
          )
        : this.dateService.normalizeGroupDate(group.startDate, group.timezone);

      const scheduledEntry = activeRound.schedules.find(
        (entry) => entry.position === nextCycleNo,
      );
      if (!scheduledEntry) {
        throw new BadRequestException(
          `No scheduled payout member found for position=${nextCycleNo}`,
        );
      }

      return tx.equbCycle.create({
        data: {
          groupId,
          roundId: activeRound.id,
          cycleNo: nextCycleNo,
          dueDate,
          scheduledPayoutUserId: scheduledEntry.userId,
          finalPayoutUserId: scheduledEntry.userId,
          auctionStatus: AuctionStatus.NONE,
          status: CycleStatus.OPEN,
          createdByUserId: currentUser.id,
        },
        include: {
          scheduledPayoutUser: {
            select: {
              id: true,
              phone: true,
              fullName: true,
            },
          },
          finalPayoutUser: {
            select: {
              id: true,
              phone: true,
              fullName: true,
            },
          },
          winningBidUser: {
            select: {
              id: true,
              phone: true,
              fullName: true,
            },
          },
        },
      });
    });

    await this.auditService.log(
      'CYCLE_GENERATED',
      currentUser.id,
      {
        roundId: createdCycle.roundId,
        cycleNo: createdCycle.cycleNo,
        dueDate: createdCycle.dueDate,
        scheduledPayoutUserId: createdCycle.scheduledPayoutUserId,
        finalPayoutUserId: createdCycle.finalPayoutUserId,
        status: createdCycle.status,
      },
      groupId,
    );

    return this.toCycleResponse(createdCycle);
  }

  async getCurrentCycle(
    groupId: string,
  ): Promise<GroupCycleResponseDto | null> {
    const currentCycle = await this.prisma.equbCycle.findFirst({
      where: {
        groupId,
        status: CycleStatus.OPEN,
      },
      include: {
        scheduledPayoutUser: {
          select: {
            id: true,
            phone: true,
            fullName: true,
          },
        },
        finalPayoutUser: {
          select: {
            id: true,
            phone: true,
            fullName: true,
          },
        },
        winningBidUser: {
          select: {
            id: true,
            phone: true,
            fullName: true,
          },
        },
      },
      orderBy: {
        cycleNo: 'desc',
      },
    });

    if (!currentCycle) {
      return null;
    }

    return this.toCycleResponse(currentCycle);
  }

  async getCycleById(
    groupId: string,
    cycleId: string,
  ): Promise<GroupCycleResponseDto> {
    const cycle = await this.prisma.equbCycle.findFirst({
      where: {
        id: cycleId,
        groupId,
      },
      include: {
        scheduledPayoutUser: {
          select: {
            id: true,
            phone: true,
            fullName: true,
          },
        },
        finalPayoutUser: {
          select: {
            id: true,
            phone: true,
            fullName: true,
          },
        },
        winningBidUser: {
          select: {
            id: true,
            phone: true,
            fullName: true,
          },
        },
      },
    });

    if (!cycle) {
      throw new NotFoundException('Cycle not found');
    }

    return this.toCycleResponse(cycle);
  }

  async listCycles(groupId: string): Promise<GroupCycleResponseDto[]> {
    const cycles = await this.prisma.equbCycle.findMany({
      where: {
        groupId,
      },
      include: {
        scheduledPayoutUser: {
          select: {
            id: true,
            phone: true,
            fullName: true,
          },
        },
        finalPayoutUser: {
          select: {
            id: true,
            phone: true,
            fullName: true,
          },
        },
        winningBidUser: {
          select: {
            id: true,
            phone: true,
            fullName: true,
          },
        },
      },
      orderBy: {
        cycleNo: 'desc',
      },
      take: 50,
    });

    return cycles.map((cycle) => this.toCycleResponse(cycle));
  }

  private async countActiveAdmins(groupId: string): Promise<number> {
    return this.prisma.equbMember.count({
      where: {
        groupId,
        role: MemberRole.ADMIN,
        status: MemberStatus.ACTIVE,
      },
    });
  }

  private assertContiguousPositions(positions: number[]): void {
    const sorted = [...positions].sort((a, b) => a - b);

    if (new Set(sorted).size !== sorted.length) {
      throw new BadRequestException('Payout positions must be unique');
    }

    for (let index = 0; index < sorted.length; index += 1) {
      const expectedPosition = index + 1;
      if (sorted[index] !== expectedPosition) {
        throw new BadRequestException(
          'Payout positions must be contiguous from 1..N',
        );
      }
    }
  }

  private toCycleResponse(cycle: {
    id: string;
    groupId: string;
    roundId: string;
    cycleNo: number;
    dueDate: Date;
    scheduledPayoutUserId: string;
    finalPayoutUserId: string;
    auctionStatus: AuctionStatus;
    winningBidAmount: number | null;
    winningBidUserId: string | null;
    status: CycleStatus;
    createdByUserId: string;
    createdAt: Date;
    scheduledPayoutUser: {
      id: string;
      phone: string;
      fullName: string | null;
    };
    finalPayoutUser: {
      id: string;
      phone: string;
      fullName: string | null;
    };
    winningBidUser: {
      id: string;
      phone: string;
      fullName: string | null;
    } | null;
  }): GroupCycleResponseDto {
    return {
      id: cycle.id,
      groupId: cycle.groupId,
      roundId: cycle.roundId,
      cycleNo: cycle.cycleNo,
      dueDate: cycle.dueDate,
      scheduledPayoutUserId: cycle.scheduledPayoutUserId,
      finalPayoutUserId: cycle.finalPayoutUserId,
      payoutUserId: cycle.finalPayoutUserId,
      auctionStatus: cycle.auctionStatus,
      winningBidAmount: cycle.winningBidAmount,
      winningBidUserId: cycle.winningBidUserId,
      status: cycle.status,
      createdByUserId: cycle.createdByUserId,
      createdAt: cycle.createdAt,
      scheduledPayoutUser: cycle.scheduledPayoutUser,
      finalPayoutUser: cycle.finalPayoutUser,
      winningBidUser: cycle.winningBidUser,
      payoutUser: cycle.finalPayoutUser,
    };
  }

  private shuffleRandomDrawMembers<
    T extends { userId: string },
  >(members: T[]): T[] {
    const shuffled = [...members];
    for (let index = shuffled.length - 1; index > 0; index -= 1) {
      const swapIndex = randomInt(index + 1);
      [shuffled[index], shuffled[swapIndex]] = [
        shuffled[swapIndex],
        shuffled[index],
      ];
    }

    return shuffled;
  }

  private generateInviteCode(): string {
    let generated = '';

    while (generated.length < 8) {
      generated += randomBytes(6)
        .toString('base64url')
        .replace(/[-_]/g, '')
        .toUpperCase();
    }

    return generated.slice(0, 8);
  }

  private buildJoinUrl(code: string): string {
    const baseUrl = this.configService.get<string>('INVITE_BASE_URL')?.trim();

    if (!baseUrl) {
      return code;
    }

    return `${baseUrl.replace(/\/$/, '')}/groups/join?code=${code}`;
  }
}
