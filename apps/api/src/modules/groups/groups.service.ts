import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  AuctionStatus,
  ContributionStatus,
  CycleStatus,
  CycleState,
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
  PARTICIPATING_MEMBER_STATUSES,
  VERIFIED_MEMBER_STATUSES,
  isParticipatingMemberStatus,
  isSuspendedMemberStatus,
  normalizeMemberStatus,
} from '../../common/membership/member-status.util';
import { createSecureSeed, sha256Hex } from '../../common/crypto/secure-shuffle';
import { DateService } from '../../common/date/date.service';
import { PrismaService } from '../../common/prisma/prisma.service';
import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import { CreateGroupDto } from './dto/create-group.dto';
import { CreateInviteDto } from './dto/create-invite.dto';
import { JoinGroupDto } from './dto/join-group.dto';
import { UpdateGroupRulesDto } from './dto/update-group-rules.dto';
import { UpdateMemberRoleDto } from './dto/update-member-role.dto';
import { UpdateMemberStatusDto } from './dto/update-member-status.dto';
import {
  GroupCycleResponseDto,
  GroupDetailResponseDto,
  GroupJoinResponseDto,
  GroupMemberResponseDto,
  GroupRulesResponseDto,
  GroupSummaryResponseDto,
  InviteCodeResponseDto,
} from './entities/groups.entities';
import {
  GROUP_LOCKED_OPEN_CYCLE_MESSAGE,
  GROUP_LOCKED_OPEN_CYCLE_REASON_CODE,
  GROUP_RULESET_REQUIRED_MESSAGE,
  GROUP_RULESET_REQUIRED_REASON_CODE,
} from './groups.constants';
import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class GroupsService {
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
          status: MemberStatus.VERIFIED,
          joinedAt: new Date(),
          verifiedAt: new Date(),
          verifiedByUserId: currentUser.id,
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
        status: {
          in: PARTICIPATING_MEMBER_STATUSES,
        },
      },
      include: {
        group: {
          include: {
            rules: {
              select: {
                groupId: true,
                requiresMemberVerification: true,
              },
            },
            members: {
              select: {
                status: true,
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
      this.toGroupSummaryResponse(
        membership.group,
        membership.group.rules,
        (membership.group.members ?? []).map((member) => member.status),
      ),
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
              requiresMemberVerification: true,
            },
          },
          members: {
            select: {
              status: true,
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

    return this.toGroupDetailResponse(
      group,
      membership,
      group.rules,
      (group.members ?? []).map((member) => member.status),
    );
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

      if (isSuspendedMemberStatus(existingMembership?.status)) {
        throw new ForbiddenException(
          'Suspended members cannot self-rejoin with invite code',
        );
      }

      if (isParticipatingMemberStatus(existingMembership?.status)) {
        throw new BadRequestException(
          'You are already a joined member of this group',
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
            status: MemberStatus.JOINED,
            joinedAt,
            verifiedAt: null,
            verifiedByUserId: null,
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
            status: MemberStatus.JOINED,
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
        status: normalizeMemberStatus(membership.status),
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

    return memberships.map((membership) => this.toMemberResponse(membership));
  }

  async verifyMember(
    currentUser: AuthenticatedUser,
    groupId: string,
    memberId: string,
  ): Promise<GroupMemberResponseDto> {
    const membership = await this.prisma.equbMember.findFirst({
      where: {
        id: memberId,
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
    });

    if (!membership) {
      throw new NotFoundException('Member not found in this group');
    }

    const normalizedStatus = normalizeMemberStatus(membership.status);
    if (normalizedStatus === MemberStatus.SUSPENDED) {
      throw new BadRequestException('Suspended members cannot be verified');
    }

    if (normalizedStatus === MemberStatus.VERIFIED) {
      return this.toMemberResponse(membership);
    }

    if (
      normalizedStatus !== MemberStatus.JOINED &&
      normalizedStatus !== MemberStatus.INVITED
    ) {
      throw new BadRequestException(
        'Only joined or invited members can be verified',
      );
    }

    const verifiedAt = new Date();

    const updatedMembership = await this.prisma.equbMember.update({
      where: {
        id: membership.id,
      },
      data: {
        status: MemberStatus.VERIFIED,
        verifiedAt,
        verifiedByUserId: currentUser.id,
        joinedAt: membership.joinedAt ?? verifiedAt,
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
      'MEMBER_VERIFIED',
      currentUser.id,
      {
        memberId,
        targetUserId: updatedMembership.userId,
        previousStatus: membership.status,
        nextStatus: updatedMembership.status,
      },
      groupId,
    );

    return this.toMemberResponse(updatedMembership);
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

    if (!isParticipatingMemberStatus(targetMembership.status)) {
      throw new BadRequestException('Only joined members can change roles');
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

    return this.toMemberResponse(updatedMembership);
  }

  async updateMemberStatus(
    currentUser: AuthenticatedUser,
    groupId: string,
    targetUserId: string,
    dto: UpdateMemberStatusDto,
  ): Promise<GroupMemberResponseDto> {
    const requestedStatus = normalizeMemberStatus(dto.status);
    if (requestedStatus !== MemberStatus.SUSPENDED) {
      throw new BadRequestException('Only SUSPENDED status is supported');
    }

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

    if (
      !actorMembership ||
      !isParticipatingMemberStatus(actorMembership.status)
    ) {
      throw new ForbiddenException('Only joined members can update statuses');
    }

    if (!targetMembership) {
      throw new NotFoundException('Member not found in this group');
    }

    if (!isParticipatingMemberStatus(targetMembership.status)) {
      throw new BadRequestException('Only joined members can change status');
    }

    const isSelfAction = currentUser.id === targetUserId;
    if (isSelfAction && dto.status === MemberStatus.REMOVED) {
      throw new BadRequestException('Use SUSPENDED status to leave group');
    }

    if (!isSelfAction && actorMembership.role !== MemberRole.ADMIN) {
      throw new ForbiddenException('Only admins can suspend other members');
    }

    if (
      targetMembership.role === MemberRole.ADMIN &&
      isParticipatingMemberStatus(targetMembership.status)
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
        status: requestedStatus,
        payoutPosition: null,
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
        nextStatus: requestedStatus,
      },
      groupId,
    );

    return this.toMemberResponse(updatedMembership);
  }

  async startCycle(
    currentUser: AuthenticatedUser,
    groupId: string,
  ): Promise<GroupCycleResponseDto> {
    const cycleResult = await this.prisma.$transaction(async (tx) => {
      const group = await tx.equbGroup.findUnique({
        where: { id: groupId },
        select: {
          id: true,
          status: true,
          contributionAmount: true,
          frequency: true,
          startDate: true,
          timezone: true,
          rules: {
            select: {
              contributionAmount: true,
              requiresMemberVerification: true,
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
          'Cycles can only be started for active groups',
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
        throw new ConflictException('An open cycle already exists for this group');
      }

      const eligibleStatuses = group.rules.requiresMemberVerification
        ? VERIFIED_MEMBER_STATUSES
        : PARTICIPATING_MEMBER_STATUSES;

      const eligibleMembers = await tx.equbMember.findMany({
        where: {
          groupId,
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

      const uniqueEligibleUserIds = [
        ...new Set(eligibleMembers.map((member) => member.userId)),
      ];

      if (uniqueEligibleUserIds.length < 2) {
        throw new BadRequestException(
          group.rules.requiresMemberVerification
            ? 'At least 2 verified members are required to start a cycle'
            : 'At least 2 joined members are required to start a cycle',
        );
      }

      const defaultRecipientUserId = uniqueEligibleUserIds[0];

      const activeRound = await tx.equbRound.findFirst({
        where: {
          groupId,
          closedAt: null,
          payoutMode: PayoutMode.RANDOM_DRAW,
        },
        select: {
          id: true,
        },
        orderBy: {
          roundNo: 'desc',
        },
      });

      const roundId =
        activeRound?.id ??
        (
          await tx.equbRound.create({
            data: {
              groupId,
              roundNo:
                ((await tx.equbRound.findFirst({
                  where: { groupId },
                  orderBy: { roundNo: 'desc' },
                  select: { roundNo: true },
                }))?.roundNo ?? 0) + 1,
              payoutMode: PayoutMode.RANDOM_DRAW,
              drawSeedHash: sha256Hex(createSecureSeed(32)),
              startedByUserId: currentUser.id,
            },
            select: { id: true },
          })
        ).id;

      const latestCycle = await tx.equbCycle.findFirst({
        where: { groupId },
        orderBy: [{ dueDate: 'desc' }, { createdAt: 'desc' }],
        select: {
          cycleNo: true,
          dueDate: true,
        },
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

      const createdCycle = await tx.equbCycle.create({
        data: {
          groupId,
          roundId,
          cycleNo: (latestCycle?.cycleNo ?? 0) + 1,
          dueDate,
          dueAt: dueDate,
          state: CycleState.DUE,
          scheduledPayoutUserId: defaultRecipientUserId,
          finalPayoutUserId: defaultRecipientUserId,
          selectedWinnerUserId: null,
          selectionMethod: null,
          selectionMetadata: Prisma.JsonNull,
          auctionStatus: AuctionStatus.NONE,
          status: CycleStatus.OPEN,
          createdByUserId: currentUser.id,
        },
        select: {
          id: true,
          dueDate: true,
        },
      });

      const dueRows = await tx.contribution.createMany({
        data: uniqueEligibleUserIds.map((userId) => ({
          groupId,
          cycleId: createdCycle.id,
          userId,
          amount: group.rules?.contributionAmount ?? group.contributionAmount,
          status: ContributionStatus.PENDING,
        })),
        skipDuplicates: true,
      });

      return {
        cycleId: createdCycle.id,
        dueAt: createdCycle.dueDate,
        dueRowsCreated: dueRows.count,
        eligibleMemberCount: uniqueEligibleUserIds.length,
      };
    });

    await this.auditService.log(
      'CYCLE_STARTED',
      currentUser.id,
      {
        cycleId: cycleResult.cycleId,
        dueAt: cycleResult.dueAt,
        dueRowsCreated: cycleResult.dueRowsCreated,
        eligibleMemberCount: cycleResult.eligibleMemberCount,
      },
      groupId,
    );

    return this.getCycleById(groupId, cycleResult.cycleId);
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
        selectedWinnerUser: {
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
        selectedWinnerUser: {
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
        selectedWinnerUser: {
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
    rules: {
      groupId: string;
      requiresMemberVerification: boolean;
    } | null,
    memberStatuses: MemberStatus[],
  ): GroupSummaryResponseDto {
    const flags = this.toRulesGateFlags(rules, memberStatuses);

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
    rules: {
      groupId: string;
      requiresMemberVerification: boolean;
    } | null,
    memberStatuses: MemberStatus[],
  ): GroupDetailResponseDto {
    const summary = this.toGroupSummaryResponse(group, rules, memberStatuses);

    return {
      ...summary,
      createdByUserId: group.createdByUserId,
      createdAt: group.createdAt,
      strictPayout: group.strictPayout,
      timezone: group.timezone,
      membership: {
        role: membership.role,
        status: normalizeMemberStatus(membership.status),
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

  private toRulesGateFlags(
    rules: {
      groupId: string;
      requiresMemberVerification: boolean;
    } | null,
    memberStatuses: MemberStatus[],
  ): {
    rulesetConfigured: boolean;
    canInviteMembers: boolean;
    canStartCycle: boolean;
  } {
    const rulesetConfigured = rules != null;
    if (!rulesetConfigured) {
      return {
        rulesetConfigured: false,
        canInviteMembers: false,
        canStartCycle: false,
      };
    }

    const eligibleCount = this.countEligibleMembers(
      memberStatuses,
      rules.requiresMemberVerification,
    );

    return {
      rulesetConfigured,
      canInviteMembers: rulesetConfigured,
      canStartCycle: eligibleCount >= 2,
    };
  }

  private countEligibleMembers(
    memberStatuses: MemberStatus[],
    requiresMemberVerification: boolean,
  ): number {
    const eligibleStatuses = requiresMemberVerification
      ? VERIFIED_MEMBER_STATUSES
      : PARTICIPATING_MEMBER_STATUSES;

    return memberStatuses.filter((status) => eligibleStatuses.includes(status))
      .length;
  }

  private toMemberResponse(member: {
    id: string;
    user: {
      id: string;
      phone: string;
      fullName: string | null;
    };
    role: MemberRole;
    status: MemberStatus;
    payoutPosition: number | null;
    joinedAt: Date | null;
    verifiedAt?: Date | null;
    verifiedByUserId?: string | null;
  }): GroupMemberResponseDto {
    return {
      id: member.id,
      user: member.user,
      role: member.role,
      status: normalizeMemberStatus(member.status),
      payoutPosition: member.payoutPosition,
      joinedAt: member.joinedAt,
      verifiedAt: member.verifiedAt ?? null,
      verifiedByUserId: member.verifiedByUserId ?? null,
    };
  }

  private async countActiveAdmins(groupId: string): Promise<number> {
    return this.prisma.equbMember.count({
      where: {
        groupId,
        role: MemberRole.ADMIN,
        status: {
          in: PARTICIPATING_MEMBER_STATUSES,
        },
      },
    });
  }

  private async assertGroupMembershipOpen(
    groupId: string,
    prismaClient:
      | Pick<Prisma.TransactionClient, 'equbCycle'>
      | Pick<PrismaService, 'equbCycle'> = this.prisma,
  ): Promise<void> {
    const openCycle = await prismaClient.equbCycle.findFirst({
      where: {
        groupId,
        status: CycleStatus.OPEN,
      },
      select: {
        id: true,
      },
    });

    if (!openCycle) {
      return;
    }

    throw new ConflictException({
      message: GROUP_LOCKED_OPEN_CYCLE_MESSAGE,
      reasonCode: GROUP_LOCKED_OPEN_CYCLE_REASON_CODE,
      cycleId: openCycle.id,
      cycleStatus: CycleStatus.OPEN,
    });
  }

  private toCycleResponse(cycle: {
    id: string;
    groupId: string;
    roundId: string;
    cycleNo: number;
    dueDate: Date;
    dueAt: Date;
    state: CycleState;
    scheduledPayoutUserId: string;
    finalPayoutUserId: string;
    selectedWinnerUserId: string | null;
    selectionMethod: GroupRulePayoutMode | null;
    selectionMetadata: Prisma.JsonValue | null;
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
    selectedWinnerUser: {
      id: string;
      phone: string;
      fullName: string | null;
    } | null;
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
      dueAt: cycle.dueAt,
      state: cycle.state,
      scheduledPayoutUserId: cycle.scheduledPayoutUserId,
      finalPayoutUserId: cycle.finalPayoutUserId,
      selectedWinnerUserId: cycle.selectedWinnerUserId,
      selectionMethod: cycle.selectionMethod,
      selectionMetadata:
        cycle.selectionMetadata == null
          ? null
          : (cycle.selectionMetadata as Record<string, unknown>),
      payoutUserId: cycle.finalPayoutUserId,
      auctionStatus: cycle.auctionStatus,
      winningBidAmount: cycle.winningBidAmount,
      winningBidUserId: cycle.winningBidUserId,
      status: cycle.status,
      createdByUserId: cycle.createdByUserId,
      createdAt: cycle.createdAt,
      scheduledPayoutUser: cycle.scheduledPayoutUser,
      finalPayoutUser: cycle.finalPayoutUser,
      selectedWinnerUser: cycle.selectedWinnerUser,
      winningBidUser: cycle.winningBidUser,
      payoutUser: cycle.finalPayoutUser,
    };
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
