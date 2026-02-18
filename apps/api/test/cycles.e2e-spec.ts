import { BadRequestException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import {
  CycleStatus,
  GroupFrequency,
  GroupStatus,
  MemberRole,
  MemberStatus,
} from '@prisma/client';

import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/common/prisma/prisma.service';
import type { AuthenticatedUser } from '../src/common/types/authenticated-user.type';
import { GroupsController } from '../src/modules/groups/groups.controller';

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
  strictPayout: boolean;
  timezone: string;
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

type CycleRecord = {
  id: string;
  groupId: string;
  cycleNo: number;
  dueDate: Date;
  payoutUserId: string;
  status: CycleStatus;
  createdByUserId: string;
  createdAt: Date;
};

describe('Cycles (e2e)', () => {
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
  const cycles: CycleRecord[] = [];

  const adminUser: AuthenticatedUser = {
    id: 'user_admin',
    phone: '+251911111111',
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
          const group: GroupRecord = {
            id: `group_${groups.length + 1}`,
            name: data.name,
            currency: data.currency,
            contributionAmount: data.contributionAmount,
            frequency: data.frequency,
            startDate: data.startDate,
            status: GroupStatus.ACTIVE,
            strictPayout: false,
            timezone: 'Africa/Addis_Ababa',
            createdByUserId: data.createdByUserId,
            createdAt: new Date(),
          };

          groups.push(group);
          return group;
        },
      ),
      findUnique: jest.fn(
        ({
          where,
          select,
        }: {
          where: { id: string };
          select?: {
            id?: boolean;
            frequency?: boolean;
            startDate?: boolean;
            timezone?: boolean;
            status?: boolean;
          };
        }) => {
          const group = groups.find((item) => item.id === where.id) ?? null;
          if (!group) {
            return null;
          }

          if (!select) {
            return group;
          }

          return {
            ...(select.id ? { id: group.id } : {}),
            ...(select.frequency ? { frequency: group.frequency } : {}),
            ...(select.startDate ? { startDate: group.startDate } : {}),
            ...(select.timezone ? { timezone: group.timezone } : {}),
            ...(select.status ? { status: group.status } : {}),
          };
        },
      ),
    },
    equbMember: {
      create: jest.fn(
        ({
          data,
        }: {
          data: {
            groupId: string;
            userId: string;
            role: MemberRole;
            status: MemberStatus;
            joinedAt: Date;
          };
        }) => {
          const member: MemberRecord = {
            id: `member_${members.length + 1}`,
            groupId: data.groupId,
            userId: data.userId,
            role: data.role,
            status: data.status,
            payoutPosition: null,
            joinedAt: data.joinedAt,
            createdAt: new Date(),
          };

          members.push(member);
          return member;
        },
      ),
      findMany: jest.fn(
        ({
          where,
          include,
          select,
        }: {
          where: {
            groupId?: string;
            userId?: string;
            status?: MemberStatus;
          };
          include?: {
            user?: {
              select: { id: true; phone: true; fullName: true };
            };
          };
          select?: { userId?: boolean; payoutPosition?: boolean };
        }) => {
          const filtered = members.filter((member) => {
            const groupMatch =
              !where.groupId || member.groupId === where.groupId;
            const userMatch = !where.userId || member.userId === where.userId;
            const statusMatch = !where.status || member.status === where.status;
            return groupMatch && userMatch && statusMatch;
          });

          if (select) {
            return filtered.map((member) => ({
              ...(select.userId ? { userId: member.userId } : {}),
              ...(select.payoutPosition
                ? { payoutPosition: member.payoutPosition }
                : {}),
            }));
          }

          if (include?.user) {
            return filtered.map((member) => ({
              ...member,
              user: users.find((user) => user.id === member.userId) ?? null,
            }));
          }

          return filtered;
        },
      ),
      update: jest.fn(
        ({
          where,
          data,
          include,
        }: {
          where: { id: string };
          data: {
            payoutPosition?: number;
            role?: MemberRole;
            status?: MemberStatus;
          };
          include?: {
            user?: {
              select: { id: true; phone: true; fullName: true };
            };
          };
        }) => {
          const member = members.find((item) => item.id === where.id);
          if (!member) {
            throw new Error('Member not found');
          }

          if (typeof data.payoutPosition === 'number') {
            member.payoutPosition = data.payoutPosition;
          }
          if (data.role) {
            member.role = data.role;
          }
          if (data.status) {
            member.status = data.status;
          }

          if (include?.user) {
            return {
              ...member,
              user: users.find((user) => user.id === member.userId) ?? null,
            };
          }

          return member;
        },
      ),
      count: jest.fn(
        ({
          where,
        }: {
          where: {
            groupId: string;
            role: MemberRole;
            status: MemberStatus;
          };
        }) => {
          return members.filter(
            (member) =>
              member.groupId === where.groupId &&
              member.role === where.role &&
              member.status === where.status,
          ).length;
        },
      ),
      findUnique: jest.fn(() => null),
    },
    equbCycle: {
      findFirst: jest.fn(
        ({
          where,
          include,
          orderBy,
        }: {
          where: { groupId: string; status?: CycleStatus; id?: string };
          include?: {
            payoutUser?: {
              select: { id: true; phone: true; fullName: true };
            };
          };
          orderBy?: { cycleNo: 'asc' | 'desc' };
        }) => {
          let filtered = cycles.filter(
            (cycle) => cycle.groupId === where.groupId,
          );

          if (where.status) {
            filtered = filtered.filter(
              (cycle) => cycle.status === where.status,
            );
          }

          if (where.id) {
            filtered = filtered.filter((cycle) => cycle.id === where.id);
          }

          if (filtered.length === 0) {
            return null;
          }

          if (orderBy?.cycleNo === 'desc') {
            filtered = [...filtered].sort((a, b) => b.cycleNo - a.cycleNo);
          }

          const found = filtered[0];

          if (include?.payoutUser) {
            return {
              ...found,
              payoutUser:
                users.find((user) => user.id === found.payoutUserId) ?? null,
            };
          }

          return found;
        },
      ),
      create: jest.fn(
        ({
          data,
          include,
        }: {
          data: {
            groupId: string;
            cycleNo: number;
            dueDate: Date;
            payoutUserId: string;
            status: CycleStatus;
            createdByUserId: string;
          };
          include?: {
            payoutUser?: {
              select: { id: true; phone: true; fullName: true };
            };
          };
        }) => {
          const cycle: CycleRecord = {
            id: `cycle_${cycles.length + 1}`,
            groupId: data.groupId,
            cycleNo: data.cycleNo,
            dueDate: data.dueDate,
            payoutUserId: data.payoutUserId,
            status: data.status,
            createdByUserId: data.createdByUserId,
            createdAt: new Date(),
          };

          cycles.push(cycle);

          if (include?.payoutUser) {
            return {
              ...cycle,
              payoutUser:
                users.find((user) => user.id === cycle.payoutUserId) ?? null,
            };
          }

          return cycle;
        },
      ),
      findMany: jest.fn(({ where }: { where: { groupId: string } }) => {
        return cycles
          .filter((cycle) => cycle.groupId === where.groupId)
          .sort((a, b) => b.cycleNo - a.cycleNo)
          .map((cycle) => ({
            ...cycle,
            payoutUser:
              users.find((user) => user.id === cycle.payoutUserId) ?? null,
          }));
      }),
    },
    inviteCode: {
      create: jest.fn(),
      findUnique: jest.fn(),
      updateMany: jest.fn(),
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
    cycles.splice(0, cycles.length);
    jest.clearAllMocks();
  });

  it('set payout order -> generate cycle -> current cycle returns expected payout user', async () => {
    const group = await groupsController.createGroup(adminUser, {
      name: 'Cycle Group',
      contributionAmount: 700,
      frequency: GroupFrequency.MONTHLY,
      startDate: '2026-03-01',
      currency: 'ETB',
    });

    members.push({
      id: 'member_2',
      groupId: group.id,
      userId: 'user_member',
      role: MemberRole.MEMBER,
      status: MemberStatus.ACTIVE,
      payoutPosition: null,
      joinedAt: new Date(),
      createdAt: new Date(),
    });

    await groupsController.updatePayoutOrder(adminUser, group.id, [
      { userId: 'user_admin', payoutPosition: 1 },
      { userId: 'user_member', payoutPosition: 2 },
    ]);

    const generatedCycles = await groupsController.generateCycles(
      adminUser,
      group.id,
      { count: 1 },
    );

    expect(generatedCycles[0].payoutUserId).toBe('user_admin');

    const currentCycle = await groupsController.getCurrentCycle(group.id);

    expect(currentCycle).not.toBeNull();
    expect(currentCycle?.payoutUserId).toBe('user_admin');
    expect(currentCycle?.status).toBe(CycleStatus.OPEN);
  });

  it('disallows cycle generation if payout order is incomplete', async () => {
    const group = await groupsController.createGroup(adminUser, {
      name: 'Incomplete Group',
      contributionAmount: 400,
      frequency: GroupFrequency.WEEKLY,
      startDate: '2026-03-01',
      currency: 'ETB',
    });

    members.push({
      id: 'member_2',
      groupId: group.id,
      userId: 'user_member',
      role: MemberRole.MEMBER,
      status: MemberStatus.ACTIVE,
      payoutPosition: null,
      joinedAt: new Date(),
      createdAt: new Date(),
    });

    await expect(
      groupsController.generateCycles(adminUser, group.id, { count: 1 }),
    ).rejects.toBeInstanceOf(BadRequestException);
  });
});
