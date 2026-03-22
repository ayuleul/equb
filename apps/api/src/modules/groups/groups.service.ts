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
  GroupVisibility,
  JoinRequestStatus,
  MemberRole,
  MemberStatus,
  NotificationType,
  PayoutMode,
  Prisma,
  WinnerSelectionTiming,
} from '@prisma/client';
import { randomBytes } from 'crypto';

import { AuditService } from '../../common/audit/audit.service';
import { RoundEligibilityService } from '../../common/cycles/round-eligibility.service';
import { WinnerSelectionService } from '../../common/cycles/winner-selection.service';
import {
  PARTICIPATING_MEMBER_STATUSES,
  isParticipatingMemberStatus,
  isSuspendedMemberStatus,
  normalizeMemberStatus,
} from '../../common/membership/member-status.util';
import {
  createSecureSeed,
  sha256Hex,
} from '../../common/crypto/secure-shuffle';
import { DateService } from '../../common/date/date.service';
import { PrismaService } from '../../common/prisma/prisma.service';
import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import { CreateGroupDto } from './dto/create-group.dto';
import { CreateInviteDto } from './dto/create-invite.dto';
import { CreateJoinRequestDto } from './dto/create-join-request.dto';
import { JoinGroupDto } from './dto/join-group.dto';
import { DiscoverMetricsService } from './discover-metrics.service';
import { UpdateGroupDto } from './dto/update-group.dto';
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
  JoinRequestResponseDto,
  PublicGroupDetailResponseDto,
  PublicGroupRulesSummaryResponseDto,
  PublicGroupSummaryResponseDto,
} from './entities/groups.entities';
import {
  GROUP_JOIN_REQUEST_COOLDOWN_MESSAGE,
  GROUP_JOIN_REQUEST_COOLDOWN_REASON_CODE,
  GROUP_JOIN_REQUEST_RETRY_COOLDOWN_DAYS,
  GROUP_JOIN_REQUESTS_BLOCKED_MESSAGE,
  GROUP_JOIN_REQUESTS_BLOCKED_REASON_CODE,
  GROUP_LOCKED_OPEN_CYCLE_MESSAGE,
  GROUP_LOCKED_OPEN_CYCLE_REASON_CODE,
  GROUP_RULESET_REQUIRED_MESSAGE,
  GROUP_RULESET_REQUIRED_REASON_CODE,
} from './groups.constants';
import { NotificationsService } from '../notifications/notifications.service';
import {
  GroupTrustSummaryDto,
  MemberReliabilitySummaryDto,
} from '../reputation/entities/reputation.entities';
import { ReputationService } from '../reputation/reputation.service';
import { RealtimeService } from '../realtime/realtime.service';

@Injectable()
export class GroupsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly auditService: AuditService,
    private readonly configService: ConfigService,
    private readonly dateService: DateService,
    private readonly notificationsService: NotificationsService,
    private readonly roundEligibilityService: RoundEligibilityService,
    private readonly winnerSelectionService: WinnerSelectionService,
    private readonly reputationService: ReputationService,
    private readonly realtimeService: RealtimeService,
    private readonly discoverMetricsService: DiscoverMetricsService,
  ) {}

  async createGroup(
    currentUser: AuthenticatedUser,
    dto: CreateGroupDto,
  ): Promise<GroupDetailResponseDto> {
    let publicHosting: Awaited<
      ReturnType<typeof this.reputationService.getPublicHostingEligibility>
    > | null = null;
    if (dto.visibility === GroupVisibility.PUBLIC) {
      publicHosting = await this.reputationService.assertCanCreatePublicEqub(
        currentUser.id,
        {
          contributionAmount: dto.contributionAmount ?? null,
          durationDays:
            dto.frequency != null
              ? this.resolveLegacyDurationDays(dto.frequency)
              : null,
          activePublicEqubCount: await this.countActivePublicGroupsForHost(
            currentUser.id,
          ),
        },
      );
    }

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
          description: dto.description?.trim() || null,
          currency,
          contributionAmount: dto.contributionAmount ?? 0,
          frequency: dto.frequency ?? GroupFrequency.MONTHLY,
          startDate,
          visibility: dto.visibility ?? GroupVisibility.PRIVATE,
          hostTier:
            dto.visibility === GroupVisibility.PUBLIC
              ? (publicHosting?.hostTier ?? null)
              : null,
          hostReputationAtCreation:
            dto.visibility === GroupVisibility.PUBLIC
              ? (publicHosting?.trustScore ?? null)
              : null,
          createdByUserId: currentUser.id,
        } as Prisma.EqubGroupUncheckedCreateInput,
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
            winnerSelectionTiming: WinnerSelectionTiming.BEFORE_COLLECTION,
            paymentMethods: [GroupPaymentMethod.CASH_ACK],
            roundSize: 2,
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

      await this.reputationService.applyEvent(tx, {
        userId: currentUser.id,
        eventType: 'GROUP_HOSTED',
        metricChanges: {
          equbsHosted: 1,
        },
        idempotencyKey: `reputation:group-hosted:${createdGroup.id}:${currentUser.id}`,
        relatedGroupId: createdGroup.id,
        metadata: {
          visibility: createdGroup.visibility,
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

    if (group.visibility === GroupVisibility.PUBLIC) {
      await this.discoverMetricsService.refreshMetricsForGroups([group.id]);
    }

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
                roundSize: true,
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

  async listPublicGroups(
    currentUser: AuthenticatedUser,
  ): Promise<PublicGroupSummaryResponseDto[]> {
    const groups = await this.prisma.equbGroup.findMany({
      where: {
        visibility: GroupVisibility.PUBLIC,
        status: GroupStatus.ACTIVE,
        createdByUserId: {
          not: currentUser.id,
        },
        joinRequests: {
          none: {
            userId: currentUser.id,
            status: {
              in: [JoinRequestStatus.REQUESTED, JoinRequestStatus.APPROVED],
            },
          },
        },
      },
      include: {
        createdByUser: {
          select: {
            id: true,
            fullName: true,
            phone: true,
          },
        },
        rules: {
          select: {
            contributionAmount: true,
            frequency: true,
            customIntervalDays: true,
            payoutMode: true,
            roundSize: true,
            winnerSelectionTiming: true,
          },
        },
        _count: {
          select: {
            members: {
              where: {
                status: {
                  in: PARTICIPATING_MEMBER_STATUSES,
                },
              },
            },
            cycles: true,
          },
        },
      },
      orderBy: [{ createdAt: 'desc' }],
    });

    return Promise.all(
      groups.map(async (group) =>
        this.toPublicGroupSummaryResponse(
          group,
          await this.reputationService.getHostSummary(group.createdByUser.id),
          await this.reputationService.getGroupTrustSummary(group.id),
        ),
      ),
    );
  }

  async getPublicGroupDetails(
    currentUser: AuthenticatedUser,
    groupId: string,
  ): Promise<PublicGroupDetailResponseDto> {
    const group = await this.prisma.equbGroup.findFirst({
      where: {
        id: groupId,
        visibility: GroupVisibility.PUBLIC,
        status: GroupStatus.ACTIVE,
      },
      include: {
        rules: {
          select: {
            contributionAmount: true,
            frequency: true,
            customIntervalDays: true,
            payoutMode: true,
            roundSize: true,
            winnerSelectionTiming: true,
          },
        },
        _count: {
          select: {
            members: {
              where: {
                status: {
                  in: PARTICIPATING_MEMBER_STATUSES,
                },
              },
            },
            cycles: true,
          },
        },
        members: {
          where: {
            userId: currentUser.id,
            status: {
              in: PARTICIPATING_MEMBER_STATUSES,
            },
          },
          select: {
            id: true,
          },
          take: 1,
        },
      },
    });

    if (!group) {
      throw new NotFoundException('Public group not found');
    }

    const [host, trustSummary] = await Promise.all([
      this.reputationService.getHostSummary(group.createdByUserId),
      this.reputationService.getGroupTrustSummary(group.id),
    ]);

    return this.toPublicGroupDetailResponse(group, host, trustSummary);
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
              roundSize: true,
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

    const trustSummary =
      await this.reputationService.getGroupTrustSummary(groupId);

    return this.toGroupDetailResponse(
      group,
      membership,
      group.rules,
      (group.members ?? []).map((member) => member.status),
      trustSummary,
    );
  }

  async updateGroup(
    currentUser: AuthenticatedUser,
    groupId: string,
    dto: UpdateGroupDto,
  ): Promise<GroupDetailResponseDto> {
    if (
      dto.name == null &&
      dto.description == null &&
      dto.currency == null &&
      dto.visibility == null
    ) {
      throw new BadRequestException('No supported group fields were provided');
    }

    const group = await this.prisma.equbGroup.findUnique({
      where: { id: groupId },
      select: {
        id: true,
        visibility: true,
      },
    });

    if (!group) {
      throw new NotFoundException('Group not found');
    }

    let publicHosting: Awaited<
      ReturnType<typeof this.reputationService.getPublicHostingEligibility>
    > | null = null;
    if (dto.visibility === GroupVisibility.PUBLIC) {
      publicHosting = await this.reputationService.assertCanCreatePublicEqub(
        currentUser.id,
        {
          activePublicEqubCount: await this.countActivePublicGroupsForHost(
            currentUser.id,
            group.id,
          ),
        },
      );
    }

    await this.prisma.equbGroup.update({
      where: { id: groupId },
      data: {
        ...(dto.name != null ? { name: dto.name.trim() } : {}),
        ...(dto.description != null
          ? { description: dto.description.trim() || null }
          : {}),
        ...(dto.currency != null ? { currency: dto.currency.trim() } : {}),
        ...(dto.visibility != null ? { visibility: dto.visibility } : {}),
        ...(dto.visibility === GroupVisibility.PUBLIC &&
        group.visibility !== GroupVisibility.PUBLIC
          ? {
              hostTier: publicHosting?.hostTier ?? null,
              hostReputationAtCreation: publicHosting?.trustScore ?? null,
            }
          : {}),
      },
    });

    await this.auditService.log(
      'GROUP_UPDATED',
      currentUser.id,
      {
        ...(dto.name != null ? { name: dto.name.trim() } : {}),
        ...(dto.description != null
          ? { description: dto.description.trim() || null }
          : {}),
        ...(dto.currency != null ? { currency: dto.currency.trim() } : {}),
        ...(dto.visibility != null ? { visibility: dto.visibility } : {}),
      },
      groupId,
    );

    await this.discoverMetricsService.refreshMetricsForGroups([groupId]);

    return this.getGroupDetails(currentUser, groupId);
  }

  async getGroupRules(groupId: string): Promise<GroupRulesResponseDto | null> {
    const [group, rules, members] = await Promise.all([
      this.prisma.equbGroup.findUnique({
        where: { id: groupId },
        select: { id: true },
      }),
      this.prisma.groupRules.findUnique({
        where: { groupId },
      }),
      this.prisma.equbMember.findMany({
        where: { groupId },
        select: { status: true },
      }),
    ]);

    if (!group) {
      throw new NotFoundException('Group not found');
    }

    if (!rules) {
      return null;
    }

    const eligibleCount = this.countEligibleMembers(
      members.map((member) => member.status),
    );

    await this.discoverMetricsService.refreshMetricsForGroups([groupId]);

    return this.toGroupRulesResponse(rules, eligibleCount);
  }

  async updateGroupRules(
    currentUser: AuthenticatedUser,
    groupId: string,
    dto: UpdateGroupRulesDto,
  ): Promise<GroupRulesResponseDto> {
    const fineAmount =
      dto.fineType === GroupRuleFineType.NONE ? 0 : dto.fineAmount;
    this.validateWinnerSelectionTiming(dto);

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
          visibility: true,
          createdByUserId: true,
        },
      });

      if (!group) {
        throw new NotFoundException('Group not found');
      }

      if (group.visibility === GroupVisibility.PUBLIC) {
        await this.reputationService.assertCanCreatePublicEqub(
          group.createdByUserId,
          {
            maxMembers: dto.roundSize,
            contributionAmount: dto.contributionAmount,
            durationDays: this.resolveRulesDurationDays(dto),
            activePublicEqubCount: await this.countActivePublicGroupsForHost(
              group.createdByUserId,
              groupId,
            ),
          },
        );
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
          winnerSelectionTiming: dto.winnerSelectionTiming,
          paymentMethods: dto.paymentMethods,
          roundSize: dto.roundSize,
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
          winnerSelectionTiming: dto.winnerSelectionTiming,
          paymentMethods: dto.paymentMethods,
          roundSize: dto.roundSize,
        },
      });

      await tx.equbGroup.update({
        where: { id: groupId },
        data: {
          contributionAmount: dto.contributionAmount,
          strictPayout: false,
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
        winnerSelectionTiming: rules.winnerSelectionTiming,
        paymentMethods: rules.paymentMethods,
        roundSize: rules.roundSize,
      },
      groupId,
    );

    const members = await this.prisma.equbMember.findMany({
      where: { groupId },
      select: { status: true },
    });
    const eligibleCount = this.countEligibleMembers(
      members.map((member) => member.status),
    );

    return this.toGroupRulesResponse(rules, eligibleCount);
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
              visibility: true,
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
        select: {
          id: true,
          status: true,
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

      await this.upsertApprovedMembership(
        tx,
        invite.groupId,
        currentUser.id,
        invite.group.visibility,
        currentUser.id,
        new Date(),
      );

      const membership = await tx.equbMember.findUnique({
        where: {
          groupId_userId: {
            groupId: invite.groupId,
            userId: currentUser.id,
          },
        },
        select: {
          role: true,
          status: true,
          joinedAt: true,
        },
      });

      if (!membership) {
        throw new NotFoundException('Membership not found after join');
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

    await this.prisma.$transaction(async (tx) => {
      await this.reputationService.applyEvent(tx, {
        userId: currentUser.id,
        eventType: 'MEMBER_JOINED',
        metricChanges: {
          equbsJoined: 1,
        },
        idempotencyKey: `reputation:member-joined:${result.groupId}:${currentUser.id}`,
        relatedGroupId: result.groupId,
      });
    });

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

    this.realtimeService.emitGroupEvent(
      result.groupId,
      this.buildRealtimeEvent('member.updated', result.groupId, {
        entityId: currentUser.id,
      }),
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

  async createJoinRequest(
    currentUser: AuthenticatedUser,
    groupId: string,
    dto: CreateJoinRequestDto,
  ): Promise<JoinRequestResponseDto> {
    const result = await this.prisma.$transaction(async (tx) => {
      const group = await tx.equbGroup.findUnique({
        where: { id: groupId },
        select: {
          id: true,
          visibility: true,
          contributionAmount: true,
          rules: {
            select: {
              contributionAmount: true,
            },
          },
        },
      });

      if (!group) {
        throw new NotFoundException('Group not found');
      }

      if (group.visibility !== GroupVisibility.PUBLIC) {
        throw new BadRequestException(
          'Only public groups accept join requests',
        );
      }

      await this.reputationService.assertCanJoinHighValuePublicGroup(
        currentUser.id,
        group.rules?.contributionAmount ?? group.contributionAmount,
      );

      await this.assertJoinRequestsOpen(groupId, tx);

      const existingMembership = await tx.equbMember.findUnique({
        where: {
          groupId_userId: {
            groupId,
            userId: currentUser.id,
          },
        },
        select: {
          id: true,
          status: true,
        },
      });

      if (isParticipatingMemberStatus(existingMembership?.status)) {
        throw new BadRequestException('You are already a member of this group');
      }

      const existingRequest = await tx.joinRequest.findFirst({
        where: {
          groupId,
          userId: currentUser.id,
          status: JoinRequestStatus.REQUESTED,
        },
        select: {
          id: true,
        },
      });

      if (existingRequest) {
        throw new ConflictException('You already have an open join request');
      }

      const latestRejectedRequest = await tx.joinRequest.findFirst({
        where: {
          groupId,
          userId: currentUser.id,
          status: JoinRequestStatus.REJECTED,
        },
        orderBy: [{ reviewedAt: 'desc' }, { createdAt: 'desc' }],
        select: {
          reviewedAt: true,
          createdAt: true,
        },
      });

      if (latestRejectedRequest) {
        const rejectedAt =
          latestRejectedRequest.reviewedAt ?? latestRejectedRequest.createdAt;
        const retryAvailableAt = new Date(rejectedAt);
        retryAvailableAt.setDate(
          retryAvailableAt.getDate() + GROUP_JOIN_REQUEST_RETRY_COOLDOWN_DAYS,
        );

        if (new Date() < retryAvailableAt) {
          throw new ConflictException({
            message: GROUP_JOIN_REQUEST_COOLDOWN_MESSAGE,
            reasonCode: GROUP_JOIN_REQUEST_COOLDOWN_REASON_CODE,
            retryAvailableAt,
          });
        }
      }

      const joinRequest = await tx.joinRequest.create({
        data: {
          groupId,
          userId: currentUser.id,
          status: JoinRequestStatus.REQUESTED,
          message: dto.message?.trim() || null,
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

      return this.toJoinRequestResponse(joinRequest);
    });

    await this.auditService.log(
      'GROUP_JOIN_REQUEST_CREATED',
      currentUser.id,
      {
        joinRequestId: result.id,
        status: result.status,
      },
      groupId,
    );

    this.realtimeService.emitGroupEvent(
      groupId,
      this.buildRealtimeEvent('join-request.updated', groupId, {
        entityId: result.id,
      }),
    );

    await this.discoverMetricsService.refreshMetricsForGroups([groupId]);

    return result;
  }

  async getMyJoinRequest(
    currentUser: AuthenticatedUser,
    groupId: string,
  ): Promise<JoinRequestResponseDto | null> {
    await this.assertGroupExists(groupId);

    const request = await this.prisma.joinRequest.findFirst({
      where: {
        groupId,
        userId: currentUser.id,
      },
      orderBy: [{ createdAt: 'desc' }],
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

    return request ? this.toJoinRequestResponse(request) : null;
  }

  async listJoinRequests(groupId: string): Promise<JoinRequestResponseDto[]> {
    await this.assertGroupExists(groupId);

    const requests = await this.prisma.joinRequest.findMany({
      where: {
        groupId,
        status: JoinRequestStatus.REQUESTED,
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
      orderBy: [{ createdAt: 'asc' }],
    });
    const reputationByUserId =
      await this.reputationService.getReliabilitySummaries(
        requests.map((request) => request.userId),
      );

    return requests.map((request) =>
      this.toJoinRequestResponse(
        request,
        reputationByUserId.get(request.userId) ?? null,
      ),
    );
  }

  async approveJoinRequest(
    currentUser: AuthenticatedUser,
    groupId: string,
    joinRequestId: string,
  ): Promise<JoinRequestResponseDto> {
    const result = await this.reviewJoinRequest(
      currentUser,
      groupId,
      joinRequestId,
      JoinRequestStatus.APPROVED,
    );

    await this.auditService.log(
      'GROUP_JOIN_REQUEST_APPROVED',
      currentUser.id,
      {
        joinRequestId,
      },
      groupId,
    );

    this.realtimeService.emitGroupEvent(
      groupId,
      this.buildRealtimeEvent('join-request.updated', groupId, {
        entityId: joinRequestId,
      }),
    );

    this.realtimeService.emitGroupEvent(
      groupId,
      this.buildRealtimeEvent('member.updated', groupId, {
        entityId: result.userId,
      }),
    );

    await this.discoverMetricsService.refreshMetricsForGroups([groupId]);

    return result;
  }

  async rejectJoinRequest(
    currentUser: AuthenticatedUser,
    groupId: string,
    joinRequestId: string,
  ): Promise<JoinRequestResponseDto> {
    const result = await this.reviewJoinRequest(
      currentUser,
      groupId,
      joinRequestId,
      JoinRequestStatus.REJECTED,
    );

    await this.auditService.log(
      'GROUP_JOIN_REQUEST_REJECTED',
      currentUser.id,
      {
        joinRequestId,
      },
      groupId,
    );

    this.realtimeService.emitGroupEvent(
      groupId,
      this.buildRealtimeEvent('join-request.updated', groupId, {
        entityId: joinRequestId,
      }),
    );

    await this.discoverMetricsService.refreshMetricsForGroups([groupId]);

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
    const reputationByUserId =
      await this.reputationService.getReliabilitySummaries(
        memberships.map((membership) => membership.userId),
      );

    return memberships.map((membership) =>
      this.toMemberResponse(
        membership,
        reputationByUserId.get(membership.userId) ?? null,
      ),
    );
  }

  async getGroupTrustSummary(groupId: string): Promise<GroupTrustSummaryDto> {
    return this.reputationService.getGroupTrustSummary(groupId);
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

    this.realtimeService.emitGroupEvent(
      groupId,
      this.buildRealtimeEvent('member.updated', groupId, {
        entityId: updatedMembership.id,
      }),
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

    this.realtimeService.emitGroupEvent(
      groupId,
      this.buildRealtimeEvent('member.updated', groupId, {
        entityId: updatedMembership.id,
      }),
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

    await this.prisma.$transaction(async (tx) => {
      await this.reputationService.applyEvent(tx, {
        userId: targetUserId,
        eventType:
          isSelfAction === true
            ? 'MEMBER_LEFT_GROUP'
            : 'MEMBER_REMOVED_FROM_GROUP',
        metricChanges: {
          removalsCount: 1,
          ...(isSelfAction ? { equbsLeftEarly: 1 } : {}),
        },
        idempotencyKey: `reputation:member-suspended:${groupId}:${targetUserId}:${isSelfAction ? 'self' : 'admin'}`,
        relatedGroupId: groupId,
        metadata: {
          actorUserId: currentUser.id,
          previousStatus: targetMembership.status,
          nextStatus: requestedStatus,
          selfAction: isSelfAction,
        },
      });
    });

    this.realtimeService.emitGroupEvent(
      groupId,
      this.buildRealtimeEvent('member.updated', groupId, {
        entityId: updatedMembership.id,
      }),
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
              frequency: true,
              customIntervalDays: true,
              roundSize: true,
              payoutMode: true,
              winnerSelectionTiming: true,
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
        throw new ConflictException(
          'An open cycle already exists for this group',
        );
      }

      const eligibleMembers = await tx.equbMember.findMany({
        where: {
          groupId,
          status: {
            in: PARTICIPATING_MEMBER_STATUSES,
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

      let roundId = activeRound?.id ?? null;
      let roundParticipantUserIds: string[] = [];
      let remainingEligibleWinnerUserIds: string[] = [];

      if (activeRound) {
        roundParticipantUserIds =
          await this.roundEligibilityService.getRoundParticipantUserIds(tx, {
            roundId: activeRound.id,
            fallbackUserIds: uniqueEligibleUserIds,
          });
        const completedWinnerUserIds =
          await this.roundEligibilityService.listCompletedWinnerUserIds(
            tx,
            activeRound.id,
          );
        remainingEligibleWinnerUserIds =
          this.roundEligibilityService.computeRemainingEligibleWinnerUserIds(
            roundParticipantUserIds,
            completedWinnerUserIds,
          );

        if (remainingEligibleWinnerUserIds.length === 0) {
          await this.roundEligibilityService.closeRoundIfOpen(tx, {
            roundId: activeRound.id,
            closedAt: new Date(),
          });
          roundId = null;
          roundParticipantUserIds = [];
        }
      }

      if (roundId == null) {
        if (uniqueEligibleUserIds.length < 2) {
          throw new BadRequestException(
            'At least 2 participating members are required to start a cycle',
          );
        }

        const requiredToStart = this.resolveRequiredToStart(group.rules);
        const readiness = this.buildStartReadiness(
          uniqueEligibleUserIds.length,
          requiredToStart,
        );

        if (!readiness.isReadyToStart) {
          throw new BadRequestException(
            `Not enough eligible members to start this cycle. Required: ${requiredToStart}, eligible: ${uniqueEligibleUserIds.length}.`,
          );
        }

        roundId = (
          await tx.equbRound.create({
            data: {
              groupId,
              roundNo:
                ((
                  await tx.equbRound.findFirst({
                    where: { groupId },
                    orderBy: { roundNo: 'desc' },
                    select: { roundNo: true },
                  })
                )?.roundNo ?? 0) + 1,
              payoutMode: PayoutMode.RANDOM_DRAW,
              drawSeedHash: sha256Hex(createSecureSeed(32)),
              startedByUserId: currentUser.id,
            },
            select: { id: true },
          })
        ).id;
        roundParticipantUserIds = uniqueEligibleUserIds;
        remainingEligibleWinnerUserIds = uniqueEligibleUserIds;

        await tx.payoutSchedule.createMany({
          data: roundParticipantUserIds.map((userId, index) => ({
            roundId: roundId!,
            position: index + 1,
            userId,
          })),
          skipDuplicates: true,
        });
      }

      if (remainingEligibleWinnerUserIds.length === 0) {
        throw new ConflictException(
          'All eligible members have already received payout in this Equb round',
        );
      }

      const defaultRecipientUserId = remainingEligibleWinnerUserIds[0];

      const latestCycle = await tx.equbCycle.findFirst({
        where: { groupId },
        orderBy: [{ dueDate: 'desc' }, { createdAt: 'desc' }],
        select: {
          cycleNo: true,
          dueDate: true,
        },
      });

      const firstCycleDueBase = this.resolveFirstCycleDueBase(new Date());
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
        : this.dateService.normalizeGroupDate(
            firstCycleDueBase,
            group.timezone,
          );
      const latestRoundCycle = await tx.equbCycle.findFirst({
        where: {
          roundId: roundId!,
        },
        orderBy: [{ cycleNo: 'desc' }, { createdAt: 'desc' }],
        select: {
          cycleNo: true,
        },
      });

      const createdCycle = await tx.equbCycle.create({
        data: {
          groupId,
          roundId: roundId!,
          cycleNo: (latestRoundCycle?.cycleNo ?? 0) + 1,
          dueDate,
          dueAt: dueDate,
          state: CycleState.SETUP,
          scheduledPayoutUserId: defaultRecipientUserId,
          finalPayoutUserId: defaultRecipientUserId,
          selectedWinnerUserId: null,
          winnerSelectedAt: null,
          selectionMethod: null,
          selectionMetadata: Prisma.JsonNull,
          auctionStatus: AuctionStatus.NONE,
          status: CycleStatus.OPEN,
          payoutSentAt: null,
          payoutSentByUserId: null,
          payoutReceivedConfirmedAt: null,
          payoutReceivedConfirmedByUserId: null,
          createdByUserId: currentUser.id,
        },
        select: {
          id: true,
          dueDate: true,
        },
      });

      const dueRows = await tx.contribution.createMany({
        data: roundParticipantUserIds.map((userId) => ({
          groupId,
          cycleId: createdCycle.id,
          userId,
          amount: group.rules?.contributionAmount ?? group.contributionAmount,
          status: ContributionStatus.PENDING,
        })),
        skipDuplicates: true,
      });

      if (
        group.rules.winnerSelectionTiming ===
        WinnerSelectionTiming.BEFORE_COLLECTION
      ) {
        await this.winnerSelectionService.selectWinner(tx, {
          cycleId: createdCycle.id,
          actorUserId: currentUser.id,
        });
      }

      await tx.equbCycle.update({
        where: { id: createdCycle.id },
        data: {
          state: CycleState.COLLECTING,
        },
      });

      return {
        cycleId: createdCycle.id,
        dueAt: createdCycle.dueDate,
        dueRowsCreated: dueRows.count,
        eligibleMemberCount: roundParticipantUserIds.length,
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
    const cycle = await this.getCycleById(groupId, cycleResult.cycleId);

    this.realtimeService.emitTurnEvent(
      groupId,
      cycle.id,
      this.buildRealtimeEvent('turn.started', groupId, {
        turnId: cycle.id,
        entityId: cycle.id,
      }),
    );

    if (cycle.selectedWinnerUserId) {
      this.realtimeService.emitTurnEvent(
        groupId,
        cycle.id,
        this.buildRealtimeEvent('winner.selected', groupId, {
          turnId: cycle.id,
          entityId: cycle.selectedWinnerUserId,
        }),
      );
      this.realtimeService.emitTurnEvent(
        groupId,
        cycle.id,
        this.buildRealtimeEvent('turn.updated', groupId, {
          turnId: cycle.id,
          entityId: cycle.id,
        }),
      );
    }

    return cycle;
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
        createdAt: 'desc',
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
        createdAt: 'desc',
      },
      take: 50,
    });

    return cycles.map((cycle) => this.toCycleResponse(cycle));
  }

  private toGroupSummaryResponse(
    group: {
      id: string;
      name: string;
      description?: string | null;
      currency: string;
      contributionAmount: number;
      frequency: GroupFrequency;
      startDate: Date;
      status: GroupStatus;
      visibility?: GroupVisibility;
      hostTier?: string | null;
      hostReputationAtCreation?: number | null;
    },
    rules: {
      groupId: string;
      roundSize: number;
    } | null,
    memberStatuses: MemberStatus[],
  ): GroupSummaryResponseDto {
    const flags = this.toRulesGateFlags(rules, memberStatuses);

    return {
      id: group.id,
      name: group.name,
      description: group.description ?? null,
      currency: group.currency,
      contributionAmount: group.contributionAmount,
      frequency: group.frequency,
      startDate: group.startDate,
      status: group.status,
      visibility: group.visibility ?? GroupVisibility.PRIVATE,
      hostTier: group.hostTier ?? null,
      hostReputationAtCreation: group.hostReputationAtCreation ?? null,
      hostReputationLevel:
        group.hostReputationAtCreation != null
          ? this.reputationService.deriveTrustLevel(
              group.hostReputationAtCreation,
            )
          : null,
      allowedPublicEqubLimits: this.toAllowedPublicEqubLimits(
        group.hostTier ?? null,
      ),
      ...flags,
    };
  }

  private toGroupDetailResponse(
    group: {
      id: string;
      name: string;
      description?: string | null;
      currency: string;
      contributionAmount: number;
      frequency: GroupFrequency;
      startDate: Date;
      status: GroupStatus;
      visibility?: GroupVisibility;
      hostTier?: string | null;
      hostReputationAtCreation?: number | null;
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
      roundSize: number;
    } | null,
    memberStatuses: MemberStatus[],
    trustSummary: GroupTrustSummaryDto,
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
      trustSummary,
    };
  }

  private toGroupRulesResponse(
    rules: {
      groupId: string;
      contributionAmount: number;
      frequency: GroupRuleFrequency;
      customIntervalDays: number | null;
      graceDays: number;
      fineType: GroupRuleFineType;
      fineAmount: number;
      payoutMode: GroupRulePayoutMode;
      winnerSelectionTiming: WinnerSelectionTiming;
      paymentMethods: GroupPaymentMethod[];
      roundSize: number;
      createdAt: Date;
      updatedAt: Date;
    },
    eligibleCount: number,
  ): GroupRulesResponseDto {
    const requiredToStart = this.resolveRequiredToStart(rules);
    const readiness = this.buildStartReadiness(
      eligibleCount,
      requiredToStart,
    );

    return {
      groupId: rules.groupId,
      contributionAmount: rules.contributionAmount,
      frequency: rules.frequency,
      customIntervalDays: rules.customIntervalDays,
      graceDays: rules.graceDays,
      fineType: rules.fineType,
      fineAmount: rules.fineAmount,
      payoutMode: rules.payoutMode,
      winnerSelectionTiming: rules.winnerSelectionTiming,
      paymentMethods: rules.paymentMethods,
      roundSize: rules.roundSize,
      requiredToStart,
      readiness,
      createdAt: rules.createdAt,
      updatedAt: rules.updatedAt,
    };
  }

  private toPublicGroupRulesSummaryResponse(rules: {
    contributionAmount: number;
    frequency: GroupRuleFrequency;
    customIntervalDays: number | null;
    payoutMode: GroupRulePayoutMode;
    roundSize: number;
    winnerSelectionTiming: WinnerSelectionTiming;
  }): PublicGroupRulesSummaryResponseDto {
    return {
      contributionAmount: rules.contributionAmount,
      frequency: rules.frequency,
      customIntervalDays: rules.customIntervalDays,
      payoutMode: rules.payoutMode,
      roundSize: rules.roundSize,
      winnerSelectionTiming: rules.winnerSelectionTiming,
    };
  }

  private toPublicGroupSummaryResponse(
    group: {
      id: string;
      name: string;
      description: string | null;
      currency: string;
      contributionAmount: number;
      frequency: GroupFrequency;
      hostTier?: string | null;
      hostReputationAtCreation?: number | null;
      rules: {
        contributionAmount: number;
        frequency: GroupRuleFrequency;
        customIntervalDays: number | null;
        payoutMode: GroupRulePayoutMode;
        roundSize: number;
        winnerSelectionTiming: WinnerSelectionTiming;
      } | null;
      _count: {
        members: number;
        cycles: number;
      };
      createdByUser?: {
        fullName: string | null;
        phone: string;
      };
    },
    host: GroupTrustSummaryDto['host'],
    trustSummary: GroupTrustSummaryDto,
  ): PublicGroupSummaryResponseDto {
    return {
      id: group.id,
      name: group.name,
      description: group.description,
      currency: group.currency,
      contributionAmount:
        group.rules?.contributionAmount ?? group.contributionAmount,
      frequency:
        group.rules?.frequency ??
        (group.frequency === GroupFrequency.WEEKLY
          ? GroupRuleFrequency.WEEKLY
          : GroupRuleFrequency.MONTHLY),
      payoutMode: group.rules?.payoutMode ?? null,
      memberCount: group._count.members,
      alreadyStarted: group._count.cycles > 0,
      hostName:
        group.createdByUser?.fullName ?? group.createdByUser?.phone ?? null,
      hostTier: group.hostTier ?? null,
      hostReputationAtCreation: group.hostReputationAtCreation ?? null,
      hostReputationLevel:
        group.hostReputationAtCreation != null
          ? this.reputationService.deriveTrustLevel(
              group.hostReputationAtCreation,
            )
          : null,
      allowedPublicEqubLimits: this.toAllowedPublicEqubLimits(
        group.hostTier ?? null,
      ),
      host,
      trustSummary,
    };
  }

  private toPublicGroupDetailResponse(
    group: {
      id: string;
      name: string;
      description: string | null;
      currency: string;
      contributionAmount: number;
      frequency: GroupFrequency;
      hostTier?: string | null;
      hostReputationAtCreation?: number | null;
      status: GroupStatus;
      visibility: GroupVisibility;
      rules: {
        contributionAmount: number;
        frequency: GroupRuleFrequency;
        customIntervalDays: number | null;
        payoutMode: GroupRulePayoutMode;
        roundSize: number;
        winnerSelectionTiming: WinnerSelectionTiming;
      } | null;
      members: { id: string }[];
      _count: {
        members: number;
        cycles: number;
      };
      createdByUser?: {
        fullName: string | null;
        phone: string;
      };
    },
    host: GroupTrustSummaryDto['host'],
    trustSummary: GroupTrustSummaryDto,
  ): PublicGroupDetailResponseDto {
    return {
      ...this.toPublicGroupSummaryResponse(group, host, trustSummary),
      visibility: group.visibility,
      status: group.status,
      rulesetConfigured: group.rules != null,
      isCurrentUserMember: group.members.length > 0,
      rules: group.rules
        ? this.toPublicGroupRulesSummaryResponse(group.rules)
        : null,
      host,
      trustSummary,
    };
  }

  private toRulesGateFlags(
    rules: {
      groupId: string;
      roundSize: number;
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
    );
    const requiredToStart = this.resolveRequiredToStart(rules);
    const readiness = this.buildStartReadiness(
      eligibleCount,
      requiredToStart,
    );

    return {
      rulesetConfigured,
      canInviteMembers: rulesetConfigured,
      canStartCycle: readiness.isReadyToStart,
    };
  }

  private countEligibleMembers(memberStatuses: MemberStatus[]): number {
    return memberStatuses.filter((status) =>
      PARTICIPATING_MEMBER_STATUSES.includes(status),
    ).length;
  }

  private validateWinnerSelectionTiming(dto: UpdateGroupRulesDto): void {
    const automaticSelectionModes: GroupRulePayoutMode[] = [
      GroupRulePayoutMode.LOTTERY,
      GroupRulePayoutMode.ROTATION,
    ];

    if (
      dto.winnerSelectionTiming === WinnerSelectionTiming.BEFORE_COLLECTION &&
      !automaticSelectionModes.includes(dto.payoutMode)
    ) {
      throw new BadRequestException(
        'winnerSelectionTiming BEFORE_COLLECTION is only supported for LOTTERY and ROTATION payout modes',
      );
    }
  }

  private resolveRequiredToStart(rules: {
    roundSize: number;
  }): number {
    return rules.roundSize;
  }

  private buildStartReadiness(
    eligibleCount: number,
    requiredToStart: number,
  ): {
    eligibleCount: number;
    isReadyToStart: boolean;
    isWaitingForMembers: boolean;
  } {
    const hasEnoughMembers = eligibleCount >= requiredToStart;

    return {
      eligibleCount,
      isReadyToStart: hasEnoughMembers,
      isWaitingForMembers: !hasEnoughMembers,
    };
  }

  private toMemberResponse(
    member: {
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
    },
    reputation: MemberReliabilitySummaryDto | null = null,
  ): GroupMemberResponseDto {
    return {
      id: member.id,
      user: member.user,
      role: member.role,
      status: normalizeMemberStatus(member.status),
      payoutPosition: member.payoutPosition,
      joinedAt: member.joinedAt,
      verifiedAt: member.verifiedAt ?? null,
      verifiedByUserId: member.verifiedByUserId ?? null,
      ...(reputation ? { reputation } : {}),
    };
  }

  private toJoinRequestResponse(
    request: {
      id: string;
      groupId: string;
      userId: string;
      status: JoinRequestStatus;
      message: string | null;
      createdAt: Date;
      reviewedAt: Date | null;
      reviewedByUserId: string | null;
      user?: {
        id: string;
        phone: string;
        fullName: string | null;
      };
    },
    reputation: MemberReliabilitySummaryDto | null = null,
  ): JoinRequestResponseDto {
    const retryAvailableAt =
      request.status === JoinRequestStatus.REJECTED
        ? this.resolveJoinRequestRetryAvailableAt(
            request.reviewedAt ?? request.createdAt,
          )
        : null;

    return {
      id: request.id,
      groupId: request.groupId,
      userId: request.userId,
      status: request.status,
      message: request.message ?? null,
      createdAt: request.createdAt,
      reviewedAt: request.reviewedAt ?? null,
      reviewedByUserId: request.reviewedByUserId ?? null,
      retryAvailableAt,
      ...(request.user
        ? {
            user: {
              ...request.user,
              ...(reputation ? { reputation } : {}),
            },
          }
        : {}),
    };
  }

  private async countActivePublicGroupsForHost(
    userId: string,
    excludeGroupId?: string,
  ): Promise<number> {
    return this.prisma.equbGroup.count({
      where: {
        createdByUserId: userId,
        visibility: GroupVisibility.PUBLIC,
        status: GroupStatus.ACTIVE,
        ...(excludeGroupId ? { id: { not: excludeGroupId } } : {}),
      },
    });
  }

  private resolveLegacyDurationDays(frequency: GroupFrequency): number {
    return frequency === GroupFrequency.WEEKLY ? 7 : 30;
  }

  private resolveRulesDurationDays(dto: UpdateGroupRulesDto): number | null {
    if (dto.frequency === GroupRuleFrequency.CUSTOM_INTERVAL) {
      return dto.customIntervalDays ?? null;
    }

    if (dto.frequency === GroupRuleFrequency.WEEKLY) {
      return 7;
    }

    if (dto.frequency === GroupRuleFrequency.MONTHLY) {
      return 30;
    }

    return null;
  }

  private toAllowedPublicEqubLimits(hostTier: string | null): {
    maxMembers: number | null;
    maxContributionAmount: number | null;
    maxDurationDays: number | null;
    maxActivePublicEqubs: number | null;
  } | null {
    if (hostTier !== 'starter') {
      return null;
    }

    return {
      maxMembers: this.getNumericConfig('STARTER_PUBLIC_EQUB_MAX_MEMBERS', 10),
      maxContributionAmount: this.getNumericConfig(
        'STARTER_PUBLIC_EQUB_MAX_CONTRIBUTION',
        1000,
      ),
      maxDurationDays: this.getNumericConfig(
        'STARTER_PUBLIC_EQUB_MAX_DURATION',
        30,
      ),
      maxActivePublicEqubs: this.getNumericConfig(
        'MAX_ACTIVE_PUBLIC_EQUBS_FOR_STARTER_HOST',
        1,
      ),
    };
  }

  private getNumericConfig(name: string, fallback: number): number {
    const value = this.configService.get<string | number>(name);
    if (value == null || value === '') {
      return fallback;
    }

    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : fallback;
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

  private async assertGroupExists(groupId: string): Promise<void> {
    const group = await this.prisma.equbGroup.findUnique({
      where: { id: groupId },
      select: { id: true },
    });

    if (!group) {
      throw new NotFoundException('Group not found');
    }
  }

  private resolveJoinRequestRetryAvailableAt(rejectedAt: Date): Date {
    const retryAvailableAt = new Date(rejectedAt);
    retryAvailableAt.setDate(
      retryAvailableAt.getDate() + GROUP_JOIN_REQUEST_RETRY_COOLDOWN_DAYS,
    );
    return retryAvailableAt;
  }

  private async reviewJoinRequest(
    currentUser: AuthenticatedUser,
    groupId: string,
    joinRequestId: string,
    nextStatus: JoinRequestStatus,
  ): Promise<JoinRequestResponseDto> {
    const reviewedAt = new Date();

    const result = await this.prisma.$transaction(async (tx) => {
      const request = await tx.joinRequest.findFirst({
        where: {
          id: joinRequestId,
          groupId,
        },
        include: {
          group: {
            select: {
              visibility: true,
            },
          },
          user: {
            select: {
              id: true,
              phone: true,
              fullName: true,
            },
          },
        },
      });

      if (!request) {
        throw new NotFoundException('Join request not found');
      }

      if (request.status !== JoinRequestStatus.REQUESTED) {
        throw new ConflictException(
          `Join request is already ${request.status.toLowerCase()}`,
        );
      }

      if (nextStatus === JoinRequestStatus.APPROVED) {
        await this.assertGroupMembershipOpen(groupId, tx);
        await this.upsertApprovedMembership(
          tx,
          groupId,
          request.userId,
          request.group.visibility,
          currentUser.id,
          reviewedAt,
        );
        await this.reputationService.applyEvent(tx, {
          userId: request.userId,
          eventType: 'MEMBER_JOINED',
          metricChanges: {
            equbsJoined: 1,
          },
          idempotencyKey: `reputation:member-joined:${groupId}:${request.userId}`,
          relatedGroupId: groupId,
          metadata: {
            approvalSource: 'join_request',
          },
        });
      }

      const updated = await tx.joinRequest.update({
        where: { id: request.id },
        data: {
          status: nextStatus,
          reviewedAt,
          reviewedByUserId: currentUser.id,
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

      return this.toJoinRequestResponse(updated);
    });

    return result;
  }

  private async upsertApprovedMembership(
    tx: Prisma.TransactionClient,
    groupId: string,
    userId: string,
    visibility: GroupVisibility,
    reviewerUserId: string,
    reviewedAt: Date,
  ): Promise<void> {
    const existingMembership = await tx.equbMember.findUnique({
      where: {
        groupId_userId: {
          groupId,
          userId,
        },
      },
      select: {
        id: true,
        status: true,
      },
    });

    if (isSuspendedMemberStatus(existingMembership?.status)) {
      throw new ConflictException(
        'Suspended members cannot be re-added through join approval',
      );
    }

    if (isParticipatingMemberStatus(existingMembership?.status)) {
      throw new ConflictException('User is already a member of this group');
    }

    const joinedAt = reviewedAt;
    const isPublicApproval = visibility === GroupVisibility.PUBLIC;
    const nextMemberStatus = isPublicApproval
      ? MemberStatus.VERIFIED
      : MemberStatus.JOINED;

    if (existingMembership) {
      await tx.equbMember.update({
        where: { id: existingMembership.id },
        data: {
          status: nextMemberStatus,
          joinedAt,
          verifiedAt: isPublicApproval ? reviewedAt : null,
          verifiedByUserId: isPublicApproval ? reviewerUserId : null,
        },
      });
      return;
    }

    await tx.equbMember.create({
      data: {
        groupId,
        userId,
        role: MemberRole.MEMBER,
        status: nextMemberStatus,
        joinedAt,
        verifiedAt: isPublicApproval ? reviewedAt : null,
        verifiedByUserId: isPublicApproval ? reviewerUserId : null,
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

  private async assertJoinRequestsOpen(
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
      message: GROUP_JOIN_REQUESTS_BLOCKED_MESSAGE,
      reasonCode: GROUP_JOIN_REQUESTS_BLOCKED_REASON_CODE,
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
    winnerSelectedAt: Date | null;
    selectionMethod: GroupRulePayoutMode | null;
    selectionMetadata: Prisma.JsonValue | null;
    auctionStatus: AuctionStatus;
    winningBidAmount: number | null;
    winningBidUserId: string | null;
    payoutSentAt: Date | null;
    payoutSentByUserId: string | null;
    payoutReceivedConfirmedAt: Date | null;
    payoutReceivedConfirmedByUserId: string | null;
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
      winnerSelectedAt: cycle.winnerSelectedAt,
      selectionMethod: cycle.selectionMethod,
      selectionMetadata:
        cycle.selectionMetadata == null
          ? null
          : (cycle.selectionMetadata as Record<string, unknown>),
      payoutUserId: cycle.finalPayoutUserId,
      auctionStatus: cycle.auctionStatus,
      winningBidAmount: cycle.winningBidAmount,
      winningBidUserId: cycle.winningBidUserId,
      payoutSentAt: cycle.payoutSentAt,
      payoutSentByUserId: cycle.payoutSentByUserId,
      payoutReceivedConfirmedAt: cycle.payoutReceivedConfirmedAt,
      payoutReceivedConfirmedByUserId: cycle.payoutReceivedConfirmedByUserId,
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

  private buildRealtimeEvent(
    eventType: string,
    groupId: string,
    options?: {
      turnId?: string;
      entityId?: string;
      summary?: Record<string, unknown>;
    },
  ) {
    return {
      eventType,
      groupId,
      turnId: options?.turnId,
      entityId: options?.entityId,
      timestamp: new Date().toISOString(),
      summary: options?.summary,
    };
  }

  private resolveFirstCycleDueBase(startedAt: Date): Date {
    return startedAt;
  }
}
