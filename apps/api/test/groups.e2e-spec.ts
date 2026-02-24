import { BadRequestException, ConflictException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import {
  GroupFrequency,
  GroupStatus,
  MemberRole,
  MemberStatus,
} from '@prisma/client';

import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/common/prisma/prisma.service';
import { AuthenticatedUser } from '../src/common/types/authenticated-user.type';
import { GroupsController } from '../src/modules/groups/groups.controller';
import {
  GROUP_LOCKED_OPEN_CYCLE_MESSAGE,
  GROUP_LOCKED_OPEN_CYCLE_REASON_CODE,
  GROUP_RULESET_REQUIRED_MESSAGE,
  GROUP_RULESET_REQUIRED_REASON_CODE,
} from '../src/modules/groups/groups.constants';

type UserRecord = {
  id: string;
  phone: string;
  fullName: string | null;
  createdAt: Date;
};

type GroupRecord = {
  id: string;
  name: string;
  currency: string;
  contributionAmount: number;
  frequency: GroupFrequency;
  startDate: Date;
  status: GroupStatus;
  createdByUserId: string;
  createdAt: Date;
};

type MemberRecord = {
  id: string;
  groupId: string;
  userId: string;
  role: MemberRole;
  status: MemberStatus;
  payoutPosition: number | null;
  joinedAt: Date | null;
  createdAt: Date;
};

type InviteRecord = {
  id: string;
  groupId: string;
  code: string;
  createdByUserId: string;
  expiresAt: Date | null;
  maxUses: number | null;
  usedCount: number;
  isRevoked: boolean;
  createdAt: Date;
};

type RoundRecord = {
  id: string;
  groupId: string;
  closedAt: Date | null;
};

type GroupRulesRecord = {
  groupId: string;
};

describe('Groups (e2e)', () => {
  let groupsController: GroupsController;

  const users: UserRecord[] = [
    {
      id: 'user_admin',
      phone: '+251911111111',
      fullName: 'Admin User',
      createdAt: new Date(),
    },
    {
      id: 'user_member',
      phone: '+251922222222',
      fullName: 'Member User',
      createdAt: new Date(),
    },
  ];
  const groups: GroupRecord[] = [];
  const members: MemberRecord[] = [];
  const invites: InviteRecord[] = [];
  const rounds: RoundRecord[] = [];
  const groupRules: GroupRulesRecord[] = [];

  const actorAdmin: AuthenticatedUser = {
    id: 'user_admin',
    phone: '+251911111111',
  };
  const actorMember: AuthenticatedUser = {
    id: 'user_member',
    phone: '+251922222222',
  };

  const prismaMock = {
    equbGroup: {
      create: jest.fn(
        ({
          data,
        }: {
          data: {
            name: string;
            currency: string;
            contributionAmount: number;
            frequency: GroupFrequency;
            startDate: Date;
            createdByUserId: string;
          };
        }) => {
          const record: GroupRecord = {
            id: `group_${groups.length + 1}`,
            name: data.name,
            currency: data.currency,
            contributionAmount: data.contributionAmount,
            frequency: data.frequency,
            startDate: data.startDate,
            status: GroupStatus.ACTIVE,
            createdByUserId: data.createdByUserId,
            createdAt: new Date(),
          };
          groups.push(record);
          return record;
        },
      ),
      findUnique: jest.fn(
        ({
          where,
          include,
          select,
        }: {
          where: { id: string };
          include?: { rules?: { select: { groupId: true } } };
          select?: { id?: boolean; status?: boolean; rules?: boolean };
        }) => {
          const group = groups.find((item) => item.id === where.id) ?? null;
          if (!group) {
            return null;
          }

          const rules =
            groupRules.find((item) => item.groupId === group.id) ?? null;

          if (include?.rules) {
            return {
              ...group,
              rules,
            };
          }

          if (select) {
            return {
              ...(select.id ? { id: group.id } : {}),
              ...(select.status ? { status: group.status } : {}),
              ...(select.rules ? { rules } : {}),
            };
          }

          return group;
        },
      ),
    },
    equbMember: {
      create: jest.fn(
        ({
          data,
          select,
        }: {
          data: {
            groupId: string;
            userId: string;
            role: MemberRole;
            status: MemberStatus;
            joinedAt: Date;
          };
          select?: {
            role?: boolean;
            status?: boolean;
            joinedAt?: boolean;
          };
        }) => {
          const record: MemberRecord = {
            id: `member_${members.length + 1}`,
            groupId: data.groupId,
            userId: data.userId,
            role: data.role,
            status: data.status,
            payoutPosition: null,
            joinedAt: data.joinedAt,
            createdAt: new Date(),
          };

          const duplicate = members.find(
            (item) =>
              item.groupId === record.groupId && item.userId === record.userId,
          );
          if (!duplicate) {
            members.push(record);
          }

          if (select) {
            return {
              ...(select.role ? { role: record.role } : {}),
              ...(select.status ? { status: record.status } : {}),
              ...(select.joinedAt ? { joinedAt: record.joinedAt } : {}),
            };
          }

          return record;
        },
      ),
      findMany: jest.fn(
        ({
          where,
          include,
        }: {
          where: { groupId?: string; userId?: string; status?: MemberStatus };
          include?: {
            group?:
              | boolean
              | { include: { rules: { select: { groupId: true } } } };
            user?: { select: { id: true; phone: true; fullName: true } };
          };
        }) => {
          const filtered = members.filter((item) => {
            const groupCheck = !where.groupId || item.groupId === where.groupId;
            const userCheck = !where.userId || item.userId === where.userId;
            const statusCheck = !where.status || item.status === where.status;
            return groupCheck && userCheck && statusCheck;
          });

          return filtered.map((membership) => {
            if (include?.group) {
              const group = groups.find(
                (item) => item.id === membership.groupId,
              );
              return {
                ...membership,
                group: group
                  ? {
                      ...group,
                      rules:
                        groupRules.find((item) => item.groupId === group.id) ??
                        null,
                    }
                  : null,
              };
            }

            if (include?.user) {
              return {
                ...membership,
                user: users.find((user) => user.id === membership.userId),
              };
            }

            return membership;
          });
        },
      ),
      findUnique: jest.fn(
        ({
          where,
          include,
          select,
        }: {
          where: { groupId_userId: { groupId: string; userId: string } };
          include?: {
            user?: { select: { id: true; phone: true; fullName: true } };
          };
          select?: { status?: boolean; role?: boolean };
        }) => {
          const membership =
            members.find(
              (item) =>
                item.groupId === where.groupId_userId.groupId &&
                item.userId === where.groupId_userId.userId,
            ) ?? null;

          if (!membership) {
            return null;
          }

          if (select) {
            return {
              ...(select.status ? { status: membership.status } : {}),
              ...(select.role ? { role: membership.role } : {}),
            };
          }

          if (include?.user) {
            return {
              ...membership,
              user: users.find((user) => user.id === membership.userId) ?? null,
            };
          }

          return membership;
        },
      ),
      update: jest.fn(
        ({
          where,
          data,
          include,
          select,
        }: {
          where: { id: string };
          data: {
            role?: MemberRole;
            status?: MemberStatus;
            joinedAt?: Date;
          };
          include?: {
            user?: { select: { id: true; phone: true; fullName: true } };
          };
          select?: {
            role?: boolean;
            status?: boolean;
            joinedAt?: boolean;
          };
        }) => {
          const membership = members.find((item) => item.id === where.id);
          if (!membership) {
            throw new Error('Membership not found');
          }

          if (data.role) {
            membership.role = data.role;
          }
          if (data.status) {
            membership.status = data.status;
          }
          if (data.joinedAt) {
            membership.joinedAt = data.joinedAt;
          }

          if (select) {
            return {
              ...(select.role ? { role: membership.role } : {}),
              ...(select.status ? { status: membership.status } : {}),
              ...(select.joinedAt ? { joinedAt: membership.joinedAt } : {}),
            };
          }

          if (include?.user) {
            return {
              ...membership,
              user: users.find((user) => user.id === membership.userId) ?? null,
            };
          }

          return membership;
        },
      ),
      count: jest.fn(
        ({
          where,
        }: {
          where: {
            groupId: string;
            role: MemberRole;
            status: MemberStatus | { in: MemberStatus[] };
          };
        }) => {
          const allowedStatuses =
            typeof where.status === 'object' && where.status != null && 'in' in where.status
              ? where.status.in
              : [where.status as MemberStatus];
          return members.filter(
            (item) =>
              item.groupId === where.groupId &&
              item.role === where.role &&
              allowedStatuses.includes(item.status),
          ).length;
        },
      ),
    },
    inviteCode: {
      create: jest.fn(
        ({
          data,
          select,
        }: {
          data: {
            groupId: string;
            code: string;
            createdByUserId: string;
            expiresAt: Date | null;
            maxUses: number | null;
          };
          select?: { code?: boolean };
        }) => {
          if (invites.some((invite) => invite.code === data.code)) {
            throw new Error('Duplicate invite code');
          }

          const record: InviteRecord = {
            id: `invite_${invites.length + 1}`,
            groupId: data.groupId,
            code: data.code,
            createdByUserId: data.createdByUserId,
            expiresAt: data.expiresAt,
            maxUses: data.maxUses,
            usedCount: 0,
            isRevoked: false,
            createdAt: new Date(),
          };

          invites.push(record);

          if (select?.code) {
            return { code: record.code };
          }

          return record;
        },
      ),
      findUnique: jest.fn(
        ({
          where,
          include,
        }: {
          where: { code: string };
          include?: {
            group?: {
              select: {
                id: true;
                status: true;
                rules?: {
                  select: {
                    groupId: true;
                  };
                };
              };
            };
          };
        }) => {
          const invite =
            invites.find((item) => item.code === where.code) ?? null;
          if (!invite) {
            return null;
          }

          if (include?.group) {
            const group = groups.find((item) => item.id === invite.groupId);
            return {
              ...invite,
              group: group
                ? {
                    id: group.id,
                    status: group.status,
                    ...(include.group.select.rules
                      ? {
                          rules:
                            groupRules.find(
                              (item) => item.groupId === group.id,
                            ) ?? null,
                        }
                      : {}),
                  }
                : null,
            };
          }

          return invite;
        },
      ),
      updateMany: jest.fn(
        ({
          where,
          data,
        }: {
          where: { id: string; usedCount: number; isRevoked: boolean };
          data: { usedCount: { increment: number } };
        }) => {
          const invite = invites.find(
            (item) =>
              item.id === where.id &&
              item.usedCount === where.usedCount &&
              item.isRevoked === where.isRevoked,
          );

          if (!invite) {
            return { count: 0 };
          }

          invite.usedCount += data.usedCount.increment;
          return { count: 1 };
        },
      ),
    },
    equbCycle: {
      findFirst: jest.fn(
        ({
          where,
          select,
        }: {
          where: { groupId: string; status?: string };
          select?: { id?: boolean; status?: boolean };
        }) => {
          const activeRound =
            rounds.find(
              (item) => item.groupId === where.groupId && item.closedAt === null,
            ) ?? null;
          if (!activeRound) {
            return null;
          }

          if (!select) {
            return {
              id: activeRound.id,
              groupId: activeRound.groupId,
              status: 'OPEN',
            };
          }

          return {
            ...(select.id ? { id: activeRound.id } : {}),
            ...(select.status ? { status: 'OPEN' } : {}),
          };
        },
      ),
    },
    equbRound: {
      findFirst: jest.fn(
        ({
          where,
          select,
        }: {
          where: { groupId: string; closedAt?: Date | null };
          select?: { id?: boolean };
        }) => {
          const activeOnly = Object.prototype.hasOwnProperty.call(
            where,
            'closedAt',
          )
            ? where.closedAt === null
            : false;

          const round =
            rounds.find((item) => {
              const sameGroup = item.groupId === where.groupId;
              if (!sameGroup) {
                return false;
              }
              if (!activeOnly) {
                return true;
              }
              return item.closedAt === null;
            }) ?? null;

          if (!round) {
            return null;
          }

          if (!select) {
            return round;
          }

          return {
            ...(select.id ? { id: round.id } : {}),
          };
        },
      ),
    },
    groupRules: {
      create: jest.fn(({ data }: { data: { groupId: string } }) => {
        const existing = groupRules.find(
          (item) => item.groupId === data.groupId,
        );
        if (existing) {
          return existing;
        }

        const record: GroupRulesRecord = {
          groupId: data.groupId,
        };
        groupRules.push(record);
        return record;
      }),
      findUnique: jest.fn(({ where }: { where: { groupId: string } }) => {
        return (
          groupRules.find((item) => item.groupId === where.groupId) ?? null
        );
      }),
      upsert: jest.fn(
        ({
          where,
        }: {
          where: {
            groupId: string;
          };
        }) => {
          const existing = groupRules.find(
            (item) => item.groupId === where.groupId,
          );
          if (existing) {
            return existing;
          }

          const created: GroupRulesRecord = {
            groupId: where.groupId,
          };
          groupRules.push(created);
          return created;
        },
      ),
    },
    auditLog: {
      create: jest.fn(() => ({ id: `audit_${Date.now()}` })),
    },
    $transaction: jest.fn(
      (
        arg:
          | ((tx: PrismaService) => Promise<unknown>)
          | Array<Promise<unknown>>,
      ) => {
        if (typeof arg === 'function') {
          return arg(prismaMock);
        }
        return Promise.all(arg);
      },
    ),
  } as unknown as PrismaService;

  beforeAll(async () => {
    process.env.INVITE_BASE_URL = 'http://localhost:3000';

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(PrismaService)
      .useValue(prismaMock)
      .compile();

    groupsController = moduleFixture.get<GroupsController>(GroupsController);
  });

  beforeEach(() => {
    groups.splice(0, groups.length);
    members.splice(0, members.length);
    invites.splice(0, invites.length);
    rounds.splice(0, rounds.length);
    groupRules.splice(0, groupRules.length);
    jest.clearAllMocks();
  });

  function startActiveRound(groupId: string): string {
    const roundId = `round_${rounds.length + 1}`;
    rounds.push({
      id: roundId,
      groupId,
      closedAt: null,
    });
    return roundId;
  }

  function closeRound(roundId: string): void {
    const round = rounds.find((item) => item.id === roundId);
    if (!round) {
      throw new Error(`Round not found: ${roundId}`);
    }
    round.closedAt = new Date();
  }

  async function expectGroupLockedConflict(
    action: () => Promise<unknown>,
  ): Promise<void> {
    try {
      await action();
      throw new Error('Expected group lock conflict but request succeeded');
    } catch (error) {
      expect(error).toBeInstanceOf(ConflictException);
      if (error instanceof ConflictException) {
        expect(error.getStatus()).toBe(409);
        expect(error.getResponse()).toMatchObject({
          message: GROUP_LOCKED_OPEN_CYCLE_MESSAGE,
          reasonCode: GROUP_LOCKED_OPEN_CYCLE_REASON_CODE,
          cycleStatus: 'OPEN',
        });
      }
    }
  }

  it('create group sets creator as VERIFIED ADMIN member', async () => {
    const group = await groupsController.createGroup(actorAdmin, {
      name: 'Family Equb',
      contributionAmount: 500,
      frequency: GroupFrequency.MONTHLY,
      startDate: '2026-03-01',
      currency: 'ETB',
    });

    expect(group.membership.role).toBe(MemberRole.ADMIN);
    expect(group.membership.status).toBe(MemberStatus.VERIFIED);

    const creatorMembership = members.find(
      (item) => item.groupId === group.id && item.userId === actorAdmin.id,
    );

    expect(creatorMembership?.role).toBe(MemberRole.ADMIN);
    expect(creatorMembership?.status).toBe(MemberStatus.VERIFIED);
    expect(group.rulesetConfigured).toBe(true);
    expect(group.canInviteMembers).toBe(true);
    expect(group.canStartCycle).toBe(false);
  });

  it('blocks invite creation until ruleset is configured', async () => {
    const group = await groupsController.createGroup(actorAdmin, {
      name: 'Rules Pending Group',
      currency: 'ETB',
    });

    expect(group.rulesetConfigured).toBe(false);
    expect(group.canInviteMembers).toBe(false);
    expect(group.canStartCycle).toBe(false);

    try {
      await groupsController.createInvite(actorAdmin, group.id, {});
      throw new Error('Expected ruleset-required conflict');
    } catch (error) {
      expect(error).toBeInstanceOf(ConflictException);
      if (error instanceof ConflictException) {
        expect(error.getStatus()).toBe(409);
        expect(error.getResponse()).toMatchObject({
          message: GROUP_RULESET_REQUIRED_MESSAGE,
          reasonCode: GROUP_RULESET_REQUIRED_REASON_CODE,
        });
      }
    }
  });

  it('create invite and join with code sets joining member JOINED', async () => {
    const group = await groupsController.createGroup(actorAdmin, {
      name: 'Office Equb',
      contributionAmount: 750,
      frequency: GroupFrequency.WEEKLY,
      startDate: '2026-03-02',
      currency: 'ETB',
    });

    const invite = await groupsController.createInvite(actorAdmin, group.id, {
      maxUses: 10,
    });

    const joinResult = await groupsController.joinGroup(actorMember, {
      code: invite.code,
    });

    expect(joinResult.groupId).toBe(group.id);
    expect(joinResult.status).toBe(MemberStatus.JOINED);

    const joinedMembership = members.find(
      (item) => item.groupId === group.id && item.userId === actorMember.id,
    );

    expect(joinedMembership?.status).toBe(MemberStatus.JOINED);
  });

  it('role updates work and last-admin protection is enforced', async () => {
    const group = await groupsController.createGroup(actorAdmin, {
      name: 'Team Equb',
      contributionAmount: 600,
      frequency: GroupFrequency.MONTHLY,
      startDate: '2026-03-03',
      currency: 'ETB',
    });

    const invite = await groupsController.createInvite(
      actorAdmin,
      group.id,
      {},
    );

    await groupsController.joinGroup(actorMember, {
      code: invite.code,
    });

    const promoted = await groupsController.updateMemberRole(
      actorAdmin,
      group.id,
      actorMember.id,
      {
        role: MemberRole.ADMIN,
      },
    );

    expect(promoted.role).toBe(MemberRole.ADMIN);

    await groupsController.updateMemberRole(
      actorAdmin,
      group.id,
      actorAdmin.id,
      {
        role: MemberRole.MEMBER,
      },
    );

    await expect(
      groupsController.updateMemberRole(actorMember, group.id, actorMember.id, {
        role: MemberRole.MEMBER,
      }),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('blocks joining via code while round is active', async () => {
    const group = await groupsController.createGroup(actorAdmin, {
      name: 'Locked Group Join',
      contributionAmount: 700,
      frequency: GroupFrequency.MONTHLY,
      startDate: '2026-03-10',
      currency: 'ETB',
    });
    const invite = await groupsController.createInvite(actorAdmin, group.id, {
      maxUses: 10,
    });
    startActiveRound(group.id);

    await expectGroupLockedConflict(() =>
      groupsController.joinGroup(actorMember, {
        code: invite.code,
      }),
    );
  });

  it('blocks invite acceptance endpoint while round is active', async () => {
    const group = await groupsController.createGroup(actorAdmin, {
      name: 'Locked Group Accept',
      contributionAmount: 700,
      frequency: GroupFrequency.MONTHLY,
      startDate: '2026-03-11',
      currency: 'ETB',
    });
    const invite = await groupsController.createInvite(actorAdmin, group.id, {
      maxUses: 10,
    });
    startActiveRound(group.id);

    await expectGroupLockedConflict(() =>
      groupsController.acceptInvite(actorMember, group.id, invite.code),
    );
  });

  it('allows joining after active round ends', async () => {
    const group = await groupsController.createGroup(actorAdmin, {
      name: 'Unlocked Group Join',
      contributionAmount: 700,
      frequency: GroupFrequency.MONTHLY,
      startDate: '2026-03-12',
      currency: 'ETB',
    });
    const invite = await groupsController.createInvite(actorAdmin, group.id, {
      maxUses: 10,
    });
    const roundId = startActiveRound(group.id);
    closeRound(roundId);

    const joinResult = await groupsController.joinGroup(actorMember, {
      code: invite.code,
    });

    expect(joinResult.groupId).toBe(group.id);
    expect(joinResult.status).toBe(MemberStatus.JOINED);
  });
});
