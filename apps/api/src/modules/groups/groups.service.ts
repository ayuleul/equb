import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GroupStatus, MemberRole, MemberStatus, Prisma } from '@prisma/client';
import { randomBytes } from 'crypto';

import { AuditService } from '../../common/audit/audit.service';
import { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import { PrismaService } from '../../common/prisma/prisma.service';
import { CreateGroupDto } from './dto/create-group.dto';
import { CreateInviteDto } from './dto/create-invite.dto';
import { JoinGroupDto } from './dto/join-group.dto';
import { UpdateMemberRoleDto } from './dto/update-member-role.dto';
import { UpdateMemberStatusDto } from './dto/update-member-status.dto';
import {
  GroupDetailResponseDto,
  GroupJoinResponseDto,
  GroupMemberResponseDto,
  GroupSummaryResponseDto,
  InviteCodeResponseDto,
} from './entities/groups.entities';

@Injectable()
export class GroupsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly auditService: AuditService,
    private readonly configService: ConfigService,
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

    if (dto.status === MemberStatus.LEFT) {
      if (currentUser.id !== targetUserId) {
        throw new ForbiddenException('Members can only leave for themselves');
      }
    }

    if (dto.status === MemberStatus.REMOVED) {
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

  private async countActiveAdmins(groupId: string): Promise<number> {
    return this.prisma.equbMember.count({
      where: {
        groupId,
        role: MemberRole.ADMIN,
        status: MemberStatus.ACTIVE,
      },
    });
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
