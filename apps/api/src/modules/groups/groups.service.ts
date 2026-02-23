import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  InternalServerErrorException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  AuctionStatus,
  CycleStatus,
  GroupFrequency,
  GroupPaymentMethod,
  GroupRuleFineType,
  GroupRuleFrequency,
  GroupRulePayoutMode,
  GroupStatus,
  MemberRole,
  MemberStatus,
  NotificationType,
  PayoutMode,
  Prisma,
} from '@prisma/client';
import { randomBytes } from 'crypto';

import { AuditService } from '../../common/audit/audit.service';
import {
  decryptSeed,
  encryptSeed,
  parseDrawSeedEncryptionKey,
} from '../../common/crypto/seed-encryption';
import {
  createSecureSeed,
  seededShuffle,
  sha256Hex,
} from '../../common/crypto/secure-shuffle';
import { DateService } from '../../common/date/date.service';
import { PrismaService } from '../../common/prisma/prisma.service';
import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import { CreateGroupDto } from './dto/create-group.dto';
import { CreateInviteDto } from './dto/create-invite.dto';
import { GenerateCyclesDto } from './dto/generate-cycles.dto';
import { JoinGroupDto } from './dto/join-group.dto';
import { PayoutOrderItemDto } from './dto/payout-order-item.dto';
import { UpdateGroupRulesDto } from './dto/update-group-rules.dto';
import { UpdateMemberRoleDto } from './dto/update-member-role.dto';
import { UpdateMemberStatusDto } from './dto/update-member-status.dto';
import {
  CurrentRoundScheduleResponseDto,
  GroupCycleResponseDto,
  GroupDetailResponseDto,
  GroupJoinResponseDto,
  GroupMemberResponseDto,
  GroupRulesResponseDto,
  RoundSeedRevealResponseDto,
  RoundStartResponseDto,
  GroupSummaryResponseDto,
  InviteCodeResponseDto,
} from './entities/groups.entities';
import {
  GROUP_LOCKED_ACTIVE_ROUND_MESSAGE,
  GROUP_LOCKED_ACTIVE_ROUND_REASON_CODE,
  GROUP_RULESET_REQUIRED_MESSAGE,
  GROUP_RULESET_REQUIRED_REASON_CODE,
} from './groups.constants';
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
    const legacyFieldCount =
      (dto.contributionAmount != null ? 1 : 0) +
      (dto.frequency != null ? 1 : 0) +
      (dto.startDate != null ? 1 : 0);
    if (legacyFieldCount > 0 && legacyFieldCount < 3) {
      throw new BadRequestException(
        'contributionAmount, frequency, and startDate must be provided together',
      );
    }
    const hasLegacyRulesPayload = legacyFieldCount === 3;

    const startDate =
      dto.startDate != null
        ? new Date(dto.startDate)
        : this.dateService.normalizeGroupDate(new Date(), 'Africa/Addis_Ababa');
    const currency = (dto.currency ?? 'ETB').toUpperCase();

    const group = await this.prisma.$transaction(async (tx) => {
      const createdGroup = await tx.equbGroup.create({
        data: {
          name: dto.name.trim(),
          currency,
          contributionAmount: dto.contributionAmount ?? 0,
          frequency: dto.frequency ?? GroupFrequency.MONTHLY,
          startDate,
          createdByUserId: currentUser.id,
        },
      });

      if (hasLegacyRulesPayload) {
        await tx.groupRules.create({
          data: {
            groupId: createdGroup.id,
            contributionAmount: dto.contributionAmount!,
            frequency:
              dto.frequency === GroupFrequency.WEEKLY
                ? GroupRuleFrequency.WEEKLY
                : GroupRuleFrequency.MONTHLY,
            customIntervalDays: null,
            graceDays: 0,
            fineType: GroupRuleFineType.NONE,
            fineAmount: 0,
            payoutMode: GroupRulePayoutMode.LOTTERY,
            paymentMethods: [GroupPaymentMethod.CASH_ACK],
            requiresMemberVerification: false,
            strictCollection: false,
          },
        });
      }

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

    return this.getGroupDetails(currentUser, group.id);
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
        group: {
          include: {
            rules: {
              select: {
                groupId: true,
              },
            },
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    return memberships.map((membership) =>
      this.toGroupSummaryResponse(membership.group, membership.group.rules != null),
    );
  }

  async getGroupDetails(
    currentUser: AuthenticatedUser,
    groupId: string,
  ): Promise<GroupDetailResponseDto> {
    const [group, membership] = await Promise.all([
      this.prisma.equbGroup.findUnique({
        where: { id: groupId },
        include: {
          rules: {
            select: {
              groupId: true,
            },
          },
        },
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

    return this.toGroupDetailResponse(group, membership, group.rules != null);
  }

  async getGroupRules(groupId: string): Promise<GroupRulesResponseDto> {
    const [group, rules] = await Promise.all([
      this.prisma.equbGroup.findUnique({
        where: { id: groupId },
        select: { id: true },
      }),
      this.prisma.groupRules.findUnique({
        where: { groupId },
      }),
    ]);

    if (!group) {
      throw new NotFoundException('Group not found');
    }

    if (!rules) {
      throw new NotFoundException('Group rules are not configured');
    }

    return this.toGroupRulesResponse(rules);
  }

  async updateGroupRules(
    currentUser: AuthenticatedUser,
    groupId: string,
    dto: UpdateGroupRulesDto,
  ): Promise<GroupRulesResponseDto> {
    const fineAmount =
      dto.fineType === GroupRuleFineType.NONE ? 0 : dto.fineAmount;

    if (
      dto.frequency === GroupRuleFrequency.CUSTOM_INTERVAL &&
      dto.customIntervalDays == null
    ) {
      throw new BadRequestException(
        'customIntervalDays is required for CUSTOM_INTERVAL frequency',
      );
    }

    const rules = await this.prisma.$transaction(async (tx) => {
      const group = await tx.equbGroup.findUnique({
        where: { id: groupId },
        select: {
          id: true,
          frequency: true,
        },
      });

      if (!group) {
        throw new NotFoundException('Group not found');
      }

      const updatedRules = await tx.groupRules.upsert({
        where: { groupId },
        create: {
          groupId,
          contributionAmount: dto.contributionAmount,
          frequency: dto.frequency,
          customIntervalDays:
            dto.frequency === GroupRuleFrequency.CUSTOM_INTERVAL
              ? dto.customIntervalDays!
              : null,
          graceDays: dto.graceDays,
          fineType: dto.fineType,
          fineAmount,
          payoutMode: dto.payoutMode,
          paymentMethods: dto.paymentMethods,
          requiresMemberVerification: dto.requiresMemberVerification,
          strictCollection: dto.strictCollection,
        },
        update: {
          contributionAmount: dto.contributionAmount,
          frequency: dto.frequency,
          customIntervalDays:
            dto.frequency === GroupRuleFrequency.CUSTOM_INTERVAL
              ? dto.customIntervalDays!
              : null,
          graceDays: dto.graceDays,
          fineType: dto.fineType,
          fineAmount,
          payoutMode: dto.payoutMode,
          paymentMethods: dto.paymentMethods,
          requiresMemberVerification: dto.requiresMemberVerification,
          strictCollection: dto.strictCollection,
        },
      });

      await tx.equbGroup.update({
        where: { id: groupId },
        data: {
          contributionAmount: dto.contributionAmount,
          strictPayout: dto.strictCollection,
          frequency:
            dto.frequency === GroupRuleFrequency.WEEKLY
              ? GroupFrequency.WEEKLY
              : dto.frequency === GroupRuleFrequency.MONTHLY
                ? GroupFrequency.MONTHLY
                : group.frequency,
        },
      });

      return updatedRules;
    });

    await this.auditService.log(
      'GROUP_RULES_UPDATED',
      currentUser.id,
      {
        contributionAmount: rules.contributionAmount,
        frequency: rules.frequency,
        customIntervalDays: rules.customIntervalDays,
        graceDays: rules.graceDays,
        fineType: rules.fineType,
        fineAmount: rules.fineAmount,
        payoutMode: rules.payoutMode,
        paymentMethods: rules.paymentMethods,
        requiresMemberVerification: rules.requiresMemberVerification,
        strictCollection: rules.strictCollection,
      },
      groupId,
    );

    return this.toGroupRulesResponse(rules);
  }

  async createInvite(
    currentUser: AuthenticatedUser,
    groupId: string,
    dto: CreateInviteDto,
  ): Promise<InviteCodeResponseDto> {
    const group = await this.prisma.equbGroup.findUnique({
      where: { id: groupId },
      select: {
        id: true,
        status: true,
        rules: {
          select: {
            groupId: true,
          },
        },
      },
    });

    if (!group) {
      throw new NotFoundException('Group not found');
    }

    if (group.status !== GroupStatus.ACTIVE) {
      throw new BadRequestException(
        'Invite codes can only be created for active groups',
      );
    }

    if (!group.rules) {
      throw new ConflictException({
        message: GROUP_RULESET_REQUIRED_MESSAGE,
        reasonCode: GROUP_RULESET_REQUIRED_REASON_CODE,
      });
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
    options?: {
      expectedGroupId?: string;
    },
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
              rules: {
                select: {
                  groupId: true,
                },
              },
            },
          },
        },
      });

      if (!invite) {
        throw new NotFoundException('Invite code not found');
      }

      if (
        options?.expectedGroupId &&
        invite.groupId !== options.expectedGroupId
      ) {
        throw new NotFoundException('Invite code not found for this group');
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

      if (!invite.group.rules) {
        throw new ConflictException({
          message: GROUP_RULESET_REQUIRED_MESSAGE,
          reasonCode: GROUP_RULESET_REQUIRED_REASON_CODE,
        });
      }

      await this.assertGroupMembershipOpen(invite.groupId, tx);

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

  async acceptInvite(
    currentUser: AuthenticatedUser,
    groupId: string,
    code: string,
  ): Promise<GroupJoinResponseDto> {
    return this.joinGroup(
      currentUser,
      { code },
      {
        expectedGroupId: groupId,
      },
    );
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
    await this.assertRulesetConfigured(groupId);

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
    const drawSeed = createSecureSeed(32);
    const drawSeedHash = sha256Hex(drawSeed);
    const encryptedSeed = encryptSeed(
      drawSeed,
      this.getDrawSeedEncryptionKey(),
    );
    let expectedScheduleCount = 0;

    const round = await this.prisma.$transaction(async (tx) => {
      const group = await tx.equbGroup.findUnique({
        where: { id: groupId },
        select: {
          id: true,
          status: true,
          rules: {
            select: {
              groupId: true,
            },
          },
        },
      });

      if (!group) {
        throw new NotFoundException('Group not found');
      }

      if (group.status !== GroupStatus.ACTIVE) {
        throw new BadRequestException(
          'Rounds can only be started for active groups',
        );
      }

      if (!group.rules) {
        throw new ConflictException({
          message: GROUP_RULESET_REQUIRED_MESSAGE,
          reasonCode: GROUP_RULESET_REQUIRED_REASON_CODE,
        });
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

      const shuffledMembers = seededShuffle(activeMembers, drawSeed);
      expectedScheduleCount = shuffledMembers.length;

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
          drawSeedHash,
          drawSeedCiphertext: encryptedSeed,
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

    if (round.schedules.length !== expectedScheduleCount) {
      throw new InternalServerErrorException(
        'Round schedule count mismatch after persistence',
      );
    }

    this.assertContiguousPositions(
      round.schedules.map((entry) => entry.position),
    );
    if (
      new Set(round.schedules.map((entry) => entry.userId)).size !==
      expectedScheduleCount
    ) {
      throw new InternalServerErrorException(
        'Round schedule contains duplicate members',
      );
    }

    await this.auditService.log(
      'ROUND_STARTED',
      currentUser.id,
      {
        roundId: round.id,
        roundNo: round.roundNo,
        payoutMode: round.payoutMode,
        drawSeedHash: round.drawSeedHash,
      },
      groupId,
    );

    await this.auditService.log(
      'SCHEDULE_GENERATED',
      currentUser.id,
      {
        roundId: round.id,
        drawSeedHash: round.drawSeedHash,
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
      drawSeedHash: round.drawSeedHash,
      startedByUserId: round.startedByUserId,
      startedAt: round.startedAt,
      schedule: round.schedules.map((entry) => ({
        position: entry.position,
        userId: entry.userId,
        user: entry.user,
      })),
    };
  }

  async getCurrentRoundSchedule(
    groupId: string,
  ): Promise<CurrentRoundScheduleResponseDto> {
    const activeRound = await this.prisma.equbRound.findFirst({
      where: {
        groupId,
        closedAt: null,
        payoutMode: PayoutMode.RANDOM_DRAW,
      },
      include: {
        schedules: {
          include: {
            user: {
              select: {
                fullName: true,
                phone: true,
              },
            },
          },
          orderBy: {
            position: 'asc',
          },
        },
      },
    });

    if (!activeRound) {
      throw new NotFoundException('Active round not found');
    }

    if (activeRound.schedules.length === 0) {
      throw new BadRequestException('Active round has no payout schedule');
    }

    this.assertContiguousPositions(
      activeRound.schedules.map((entry) => entry.position),
    );

    return {
      roundId: activeRound.id,
      roundNo: activeRound.roundNo,
      drawSeedHash: activeRound.drawSeedHash,
      schedule: activeRound.schedules.map((entry) => ({
        position: entry.position,
        userId: entry.userId,
        displayName: entry.user.fullName ?? entry.user.phone,
      })),
    };
  }

  async revealCurrentRoundSeed(
    currentUser: AuthenticatedUser,
    groupId: string,
  ): Promise<RoundSeedRevealResponseDto> {
    const drawSeedEncryptionKey = this.getDrawSeedEncryptionKey();
    const revealResult = await this.prisma.$transaction(async (tx) => {
      const activeRound = await tx.equbRound.findFirst({
        where: {
          groupId,
          closedAt: null,
          payoutMode: PayoutMode.RANDOM_DRAW,
        },
        select: {
          id: true,
          roundNo: true,
          drawSeedHash: true,
          drawSeedCiphertext: true,
          drawSeedRevealedAt: true,
          drawSeedRevealedByUserId: true,
        },
      });

      if (!activeRound) {
        throw new NotFoundException('Active round not found');
      }

      if (!activeRound.drawSeedCiphertext) {
        throw new BadRequestException(
          'Seed reveal is unavailable for this round',
        );
      }

      let seed: Buffer;
      try {
        seed = decryptSeed(
          activeRound.drawSeedCiphertext,
          drawSeedEncryptionKey,
        );
      } catch {
        throw new InternalServerErrorException(
          'Failed to decrypt the current round seed',
        );
      }

      const seedHash = sha256Hex(seed);
      if (seedHash !== activeRound.drawSeedHash) {
        throw new InternalServerErrorException(
          'Current round seed commitment verification failed',
        );
      }

      let revealedAt = activeRound.drawSeedRevealedAt;
      let revealedByUserId = activeRound.drawSeedRevealedByUserId;
      let createdAuditLog = false;

      if (!revealedAt || !revealedByUserId) {
        const updatedRound = await tx.equbRound.update({
          where: { id: activeRound.id },
          data: {
            drawSeedRevealedAt: new Date(),
            drawSeedRevealedByUserId: currentUser.id,
          },
          select: {
            drawSeedRevealedAt: true,
            drawSeedRevealedByUserId: true,
          },
        });
        revealedAt = updatedRound.drawSeedRevealedAt;
        revealedByUserId = updatedRound.drawSeedRevealedByUserId;
        createdAuditLog = true;
      }

      if (!revealedAt || !revealedByUserId) {
        throw new InternalServerErrorException(
          'Current round reveal metadata is incomplete',
        );
      }

      return {
        roundId: activeRound.id,
        roundNo: activeRound.roundNo,
        seedHex: seed.toString('hex'),
        seedHash,
        revealedAt,
        revealedByUserId,
        createdAuditLog,
      };
    });

    if (revealResult.createdAuditLog) {
      await this.auditService.log(
        'SEED_REVEALED',
        currentUser.id,
        {
          roundId: revealResult.roundId,
          roundNo: revealResult.roundNo,
          drawSeedHash: revealResult.seedHash,
        },
        groupId,
      );
    }

    return {
      roundId: revealResult.roundId,
      roundNo: revealResult.roundNo,
      seedHex: revealResult.seedHex,
      seedHash: revealResult.seedHash,
      revealedAt: revealResult.revealedAt,
      revealedByUserId: revealResult.revealedByUserId,
    };
  }

  async drawNextCycle(
    currentUser: AuthenticatedUser,
    groupId: string,
  ): Promise<GroupCycleResponseDto> {
    return this.generateCycles(currentUser, groupId, {});
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

    const drawResult = await this.prisma.$transaction(async (tx) => {
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
          rules: {
            select: {
              frequency: true,
              customIntervalDays: true,
            },
          },
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

      if (!group.rules) {
        throw new ConflictException({
          message: GROUP_RULESET_REQUIRED_MESSAGE,
          reasonCode: GROUP_RULESET_REQUIRED_REASON_CODE,
        });
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
            include: {
              user: {
                select: {
                  id: true,
                  phone: true,
                  fullName: true,
                  firstName: true,
                  middleName: true,
                  lastName: true,
                },
              },
            },
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
        throw new BadRequestException('Active round has no payout schedule');
      }

      this.assertContiguousPositions(
        activeRound.schedules.map((entry) => entry.position),
      );

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
        ? group.rules.frequency === GroupRuleFrequency.CUSTOM_INTERVAL
          ? this.dateService.advanceDueDateByDays(
              latestCycle.dueDate,
              group.rules.customIntervalDays!,
              group.timezone,
            )
          : this.dateService.advanceDueDate(
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

      const createdCycle = await tx.equbCycle.create({
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

      const roundMemberSnapshot = activeRound.schedules.map(
        (entry) => entry.userId,
      );
      const winnerUserId = createdCycle.finalPayoutUserId;
      const winnerMember = activeRound.schedules.find(
        (entry) => entry.userId === winnerUserId,
      );
      if (!winnerMember) {
        throw new BadRequestException('Winner is not part of round snapshot');
      }

      const winnerFullName = this.formatEthiopianFullName({
        firstName: winnerMember.user.firstName,
        middleName: winnerMember.user.middleName,
        lastName: winnerMember.user.lastName,
        fullName: winnerMember.user.fullName,
        phone: winnerMember.user.phone,
      });
      const cycleRoute = `/groups/${groupId}/cycles/${createdCycle.id}`;

      const createdNotificationDispatches: Array<{
        userId: string;
        title: string;
        body: string;
        data: Record<string, unknown>;
      }> = [];

      for (const memberUserId of roundMemberSnapshot) {
        const isWinner = memberUserId === winnerUserId;
        const title = isWinner ? '🎲 You won this turn' : '🎲 Winner drawn';
        const body = isWinner
          ? 'You are the recipient for this turn. Keep an eye on contributions and payout.'
          : `${winnerFullName} won this turn.`;
        const notificationType = isWinner
          ? NotificationType.LOTTERY_WINNER
          : NotificationType.LOTTERY_ANNOUNCEMENT;
        const eventId = isWinner
          ? `DRAW_${createdCycle.id}_WINNER`
          : `DRAW_${createdCycle.id}_ANNOUNCEMENT`;
        const notificationData: Record<string, unknown> = {
          groupId,
          cycleId: createdCycle.id,
          roundId: activeRound.id,
          route: cycleRoute,
          kind: isWinner ? 'winner' : 'announcement',
          ...(isWinner
            ? {}
            : {
                winnerUserId,
                winnerFullName,
              }),
        };

        try {
          await tx.notification.create({
            data: {
              userId: memberUserId,
              groupId,
              eventId,
              type: notificationType,
              title,
              body,
              dataJson: notificationData as Prisma.InputJsonValue,
            },
          });

          createdNotificationDispatches.push({
            userId: memberUserId,
            title,
            body,
            data: notificationData,
          });
        } catch (error) {
          if (this.isUniqueConstraintViolation(error)) {
            continue;
          }
          throw error;
        }
      }

      return {
        cycle: createdCycle,
        createdNotificationDispatches,
      };
    });

    await this.auditService.log(
      'CYCLE_GENERATED',
      currentUser.id,
      {
        roundId: drawResult.cycle.roundId,
        cycleNo: drawResult.cycle.cycleNo,
        dueDate: drawResult.cycle.dueDate,
        scheduledPayoutUserId: drawResult.cycle.scheduledPayoutUserId,
        finalPayoutUserId: drawResult.cycle.finalPayoutUserId,
        status: drawResult.cycle.status,
      },
      groupId,
    );

    await Promise.all([
      this.auditService.log(
        'LOTTERY_DRAW_COMPLETED',
        currentUser.id,
        {
          roundId: drawResult.cycle.roundId,
          cycleId: drawResult.cycle.id,
          winnerUserId: drawResult.cycle.finalPayoutUserId,
          notifiedCount: drawResult.createdNotificationDispatches.length,
        },
        groupId,
      ),
      ...drawResult.createdNotificationDispatches.map((dispatch) =>
        this.notificationsService.sendPushToUser(
          dispatch.userId,
          dispatch.title,
          dispatch.body,
          dispatch.data,
        ),
      ),
    ]);

    return this.toCycleResponse(drawResult.cycle);
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

  private toGroupSummaryResponse(
    group: {
      id: string;
      name: string;
      currency: string;
      contributionAmount: number;
      frequency: GroupFrequency;
      startDate: Date;
      status: GroupStatus;
    },
    rulesetConfigured: boolean,
  ): GroupSummaryResponseDto {
    const flags = this.toRulesGateFlags(rulesetConfigured);

    return {
      id: group.id,
      name: group.name,
      currency: group.currency,
      contributionAmount: group.contributionAmount,
      frequency: group.frequency,
      startDate: group.startDate,
      status: group.status,
      ...flags,
    };
  }

  private toGroupDetailResponse(
    group: {
      id: string;
      name: string;
      currency: string;
      contributionAmount: number;
      frequency: GroupFrequency;
      startDate: Date;
      status: GroupStatus;
      createdByUserId: string;
      createdAt: Date;
      strictPayout: boolean;
      timezone: string;
    },
    membership: {
      role: MemberRole;
      status: MemberStatus;
    },
    rulesetConfigured: boolean,
  ): GroupDetailResponseDto {
    const summary = this.toGroupSummaryResponse(group, rulesetConfigured);

    return {
      ...summary,
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

  private toGroupRulesResponse(rules: {
    groupId: string;
    contributionAmount: number;
    frequency: GroupRuleFrequency;
    customIntervalDays: number | null;
    graceDays: number;
    fineType: GroupRuleFineType;
    fineAmount: number;
    payoutMode: GroupRulePayoutMode;
    paymentMethods: GroupPaymentMethod[];
    requiresMemberVerification: boolean;
    strictCollection: boolean;
    createdAt: Date;
    updatedAt: Date;
  }): GroupRulesResponseDto {
    return {
      groupId: rules.groupId,
      contributionAmount: rules.contributionAmount,
      frequency: rules.frequency,
      customIntervalDays: rules.customIntervalDays,
      graceDays: rules.graceDays,
      fineType: rules.fineType,
      fineAmount: rules.fineAmount,
      payoutMode: rules.payoutMode,
      paymentMethods: rules.paymentMethods,
      requiresMemberVerification: rules.requiresMemberVerification,
      strictCollection: rules.strictCollection,
      createdAt: rules.createdAt,
      updatedAt: rules.updatedAt,
    };
  }

  private toRulesGateFlags(rulesetConfigured: boolean): {
    rulesetConfigured: boolean;
    canInviteMembers: boolean;
    canStartCycle: boolean;
  } {
    return {
      rulesetConfigured,
      canInviteMembers: rulesetConfigured,
      canStartCycle: rulesetConfigured,
    };
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

  private async assertGroupMembershipOpen(
    groupId: string,
    prismaClient:
      | Pick<Prisma.TransactionClient, 'equbRound'>
      | Pick<PrismaService, 'equbRound'> = this.prisma,
  ): Promise<void> {
    const activeRound = await prismaClient.equbRound.findFirst({
      where: {
        groupId,
        closedAt: null,
      },
      select: {
        id: true,
      },
    });

    if (!activeRound) {
      return;
    }

    throw new ConflictException({
      message: GROUP_LOCKED_ACTIVE_ROUND_MESSAGE,
      reasonCode: GROUP_LOCKED_ACTIVE_ROUND_REASON_CODE,
      roundId: activeRound.id,
      roundStatus: 'ACTIVE',
    });
  }

  private async assertRulesetConfigured(
    groupId: string,
    prismaClient:
      | Pick<Prisma.TransactionClient, 'groupRules'>
      | Pick<PrismaService, 'groupRules'> = this.prisma,
  ): Promise<void> {
    const rules = await prismaClient.groupRules.findUnique({
      where: { groupId },
      select: {
        groupId: true,
      },
    });

    if (rules) {
      return;
    }

    throw new ConflictException({
      message: GROUP_RULESET_REQUIRED_MESSAGE,
      reasonCode: GROUP_RULESET_REQUIRED_REASON_CODE,
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

  private formatEthiopianFullName(user: {
    firstName?: string | null;
    middleName?: string | null;
    lastName?: string | null;
    fullName?: string | null;
    phone?: string | null;
  }): string {
    const normalizedParts = [user.firstName, user.middleName, user.lastName]
      .map((value) => value?.trim() ?? '')
      .filter((value) => value.length > 0);
    if (normalizedParts.length > 0) {
      return normalizedParts.join(' ');
    }

    const fullName = user.fullName?.trim();
    if (fullName) {
      return fullName;
    }

    const phone = user.phone?.trim();
    if (phone) {
      return phone;
    }

    return 'A member';
  }

  private isUniqueConstraintViolation(error: unknown): boolean {
    if (
      error instanceof Prisma.PrismaClientKnownRequestError &&
      error.code === 'P2002'
    ) {
      return true;
    }

    if (
      typeof error === 'object' &&
      error !== null &&
      'code' in error &&
      (error as { code?: string }).code === 'P2002'
    ) {
      return true;
    }

    return false;
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

  private getDrawSeedEncryptionKey(): Buffer {
    const rawKey = this.configService.get<string>('DRAW_SEED_ENC_KEY')?.trim();
    if (!rawKey) {
      throw new InternalServerErrorException(
        'DRAW_SEED_ENC_KEY is not configured',
      );
    }

    try {
      return parseDrawSeedEncryptionKey(rawKey);
    } catch (error) {
      this.logger.error(
        'Invalid DRAW_SEED_ENC_KEY configuration',
        error instanceof Error ? error.stack : undefined,
      );
      throw new InternalServerErrorException(
        'DRAW_SEED_ENC_KEY is invalid; expected 32-byte hex/base64',
      );
    }
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
