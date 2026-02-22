import { BadRequestException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import {
  AuctionStatus,
  CycleStatus,
  GroupFrequency,
  GroupStatus,
  MemberRole,
  MemberStatus,
  PayoutMode,
} from '@prisma/client';

import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/common/prisma/prisma.service';
import type { AuthenticatedUser } from '../src/common/types/authenticated-user.type';
import { GroupsController } from '../src/modules/groups/groups.controller';

type UserRecord = {
  id: string;
  phone: string;
  fullName: string | null;
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

type RoundRecord = {
  id: string;
  groupId: string;
  roundNo: number;
  payoutMode: PayoutMode;
  startedByUserId: string;
  startedAt: Date;
  closedAt: Date | null;
};

type ScheduleRecord = {
  roundId: string;
  position: number;
  userId: string;
};

type CycleRecord = {
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
};

describe('Cycles (e2e)', () => {
  let groupsController: GroupsController;

  const users: UserRecord[] = [
    {
      id: 'user_admin',
      phone: '+251911111111',
      fullName: 'Admin User',
    },
    {
      id: 'user_member',
      phone: '+251922222222',
      fullName: 'Member User',
    },
  ];

  const groups: GroupRecord[] = [];
  const members: MemberRecord[] = [];
  const rounds: RoundRecord[] = [];
  const schedules: ScheduleRecord[] = [];
  const cycles: CycleRecord[] = [];

  const adminUser: AuthenticatedUser = {
    id: 'user_admin',
    phone: '+251911111111',
  };

  const findUser = (userId: string) => {
    return users.find((user) => user.id === userId) ?? null;
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
        }) => {
          const filtered = members.filter((member) => {
            const groupMatch =
              !where.groupId || member.groupId === where.groupId;
            const userMatch = !where.userId || member.userId === where.userId;
            const statusMatch = !where.status || member.status === where.status;
            return groupMatch && userMatch && statusMatch;
          });

          if (include?.user) {
            return filtered.map((member) => ({
              ...member,
              user: findUser(member.userId),
            }));
          }

          return filtered;
        },
      ),
      findUnique: jest.fn(() => null),
      update: jest.fn(),
      count: jest.fn(),
    },
    equbRound: {
      findFirst: jest.fn(
        ({
          where,
          select,
          include,
          orderBy,
        }: {
          where: {
            groupId: string;
            closedAt?: Date | null;
          };
          select?: { id?: boolean; roundNo?: boolean };
          include?: {
            schedules?: {
              orderBy: { position: 'asc' | 'desc' };
            };
          };
          orderBy?: { roundNo: 'asc' | 'desc' };
        }) => {
          let filtered = rounds.filter((round) => round.groupId === where.groupId);
          if (Object.prototype.hasOwnProperty.call(where, 'closedAt')) {
            filtered = filtered.filter((round) =>
              where.closedAt === null ? round.closedAt === null : true,
            );
          }

          if (filtered.length === 0) {
            return null;
          }

          if (orderBy?.roundNo === 'desc') {
            filtered = [...filtered].sort((a, b) => b.roundNo - a.roundNo);
          }

          const found = filtered[0];

          if (select) {
            return {
              ...(select.id ? { id: found.id } : {}),
              ...(select.roundNo ? { roundNo: found.roundNo } : {}),
            };
          }

          if (include?.schedules) {
            return {
              ...found,
              schedules: schedules
                .filter((schedule) => schedule.roundId === found.id)
                .sort((a, b) => a.position - b.position),
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
            roundNo: number;
            payoutMode: PayoutMode;
            startedByUserId: string;
            schedules: {
              create: Array<{ position: number; userId: string }>;
            };
          };
          include?: {
            schedules?: {
              include: {
                user: {
                  select: { id: true; phone: true; fullName: true };
                };
              };
              orderBy: { position: 'asc' | 'desc' };
            };
          };
        }) => {
          const round: RoundRecord = {
            id: `round_${rounds.length + 1}`,
            groupId: data.groupId,
            roundNo: data.roundNo,
            payoutMode: data.payoutMode,
            startedByUserId: data.startedByUserId,
            startedAt: new Date(),
            closedAt: null,
          };
          rounds.push(round);

          for (const entry of data.schedules.create) {
            schedules.push({
              roundId: round.id,
              position: entry.position,
              userId: entry.userId,
            });
          }

          if (include?.schedules) {
            return {
              ...round,
              schedules: schedules
                .filter((schedule) => schedule.roundId === round.id)
                .sort((a, b) => a.position - b.position)
                .map((schedule) => ({
                  ...schedule,
                  user: findUser(schedule.userId),
                })),
            };
          }

          return round;
        },
      ),
      update: jest.fn(
        ({
          where,
          data,
        }: {
          where: { id: string };
          data: { closedAt: Date };
        }) => {
          const round = rounds.find((item) => item.id === where.id);
          if (!round) {
            throw new Error('Round not found');
          }
          round.closedAt = data.closedAt;
          return round;
        },
      ),
    },
    equbCycle: {
      findFirst: jest.fn(
        ({
          where,
          include,
          orderBy,
        }: {
          where: {
            groupId: string;
            status?: CycleStatus;
          };
          include?: {
            scheduledPayoutUser?: {
              select: { id: true; phone: true; fullName: true };
            };
            finalPayoutUser?: {
              select: { id: true; phone: true; fullName: true };
            };
            winningBidUser?: {
              select: { id: true; phone: true; fullName: true };
            };
          };
          orderBy?: Array<{ dueDate?: 'asc' | 'desc'; createdAt?: 'asc' | 'desc' }> | { cycleNo: 'asc' | 'desc' };
        }) => {
          let filtered = cycles.filter((cycle) => cycle.groupId === where.groupId);
          if (where.status) {
            filtered = filtered.filter((cycle) => cycle.status === where.status);
          }

          if (filtered.length === 0) {
            return null;
          }

          if (Array.isArray(orderBy)) {
            filtered = [...filtered].sort((a, b) => {
              const dueDateDiff = b.dueDate.getTime() - a.dueDate.getTime();
              if (dueDateDiff !== 0) {
                return dueDateDiff;
              }
              return b.createdAt.getTime() - a.createdAt.getTime();
            });
          } else if (orderBy && 'cycleNo' in orderBy && orderBy.cycleNo === 'desc') {
            filtered = [...filtered].sort((a, b) => b.cycleNo - a.cycleNo);
          }

          const found = filtered[0];

          if (include) {
            return {
              ...found,
              ...(include.scheduledPayoutUser
                ? { scheduledPayoutUser: findUser(found.scheduledPayoutUserId) }
                : {}),
              ...(include.finalPayoutUser
                ? { finalPayoutUser: findUser(found.finalPayoutUserId) }
                : {}),
              ...(include.winningBidUser
                ? { winningBidUser: found.winningBidUserId ? findUser(found.winningBidUserId) : null }
                : {}),
            };
          }

          return found;
        },
      ),
      count: jest.fn(({ where }: { where: { roundId: string } }) => {
        return cycles.filter((cycle) => cycle.roundId === where.roundId).length;
      }),
      create: jest.fn(
        ({
          data,
          include,
        }: {
          data: {
            groupId: string;
            roundId: string;
            cycleNo: number;
            dueDate: Date;
            scheduledPayoutUserId: string;
            finalPayoutUserId: string;
            auctionStatus: AuctionStatus;
            status: CycleStatus;
            createdByUserId: string;
          };
          include?: {
            scheduledPayoutUser?: {
              select: { id: true; phone: true; fullName: true };
            };
            finalPayoutUser?: {
              select: { id: true; phone: true; fullName: true };
            };
            winningBidUser?: {
              select: { id: true; phone: true; fullName: true };
            };
          };
        }) => {
          const cycle: CycleRecord = {
            id: `cycle_${cycles.length + 1}`,
            groupId: data.groupId,
            roundId: data.roundId,
            cycleNo: data.cycleNo,
            dueDate: data.dueDate,
            scheduledPayoutUserId: data.scheduledPayoutUserId,
            finalPayoutUserId: data.finalPayoutUserId,
            auctionStatus: data.auctionStatus,
            winningBidAmount: null,
            winningBidUserId: null,
            status: data.status,
            createdByUserId: data.createdByUserId,
            createdAt: new Date(),
          };
          cycles.push(cycle);

          if (include) {
            return {
              ...cycle,
              scheduledPayoutUser: findUser(cycle.scheduledPayoutUserId),
              finalPayoutUser: findUser(cycle.finalPayoutUserId),
              winningBidUser: null,
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
            scheduledPayoutUser: findUser(cycle.scheduledPayoutUserId),
            finalPayoutUser: findUser(cycle.finalPayoutUserId),
            winningBidUser: cycle.winningBidUserId
              ? findUser(cycle.winningBidUserId)
              : null,
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
    rounds.splice(0, rounds.length);
    schedules.splice(0, schedules.length);
    cycles.splice(0, cycles.length);
    jest.clearAllMocks();
  });

  it('start random round -> generate cycle -> scheduled and final recipients match', async () => {
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

    const round = await groupsController.startRound(adminUser, group.id);
    expect(round.payoutMode).toBe(PayoutMode.RANDOM_DRAW);
    expect(round.schedule).toHaveLength(2);

    const generatedCycles = await groupsController.generateCycles(
      adminUser,
      group.id,
      { count: 1 },
    );

    expect(generatedCycles[0].scheduledPayoutUserId).toBe(
      generatedCycles[0].finalPayoutUserId,
    );
    expect(generatedCycles[0].auctionStatus).toBe(AuctionStatus.NONE);

    const currentCycle = await groupsController.getCurrentCycle(group.id);
    expect(currentCycle).not.toBeNull();
    expect(currentCycle?.scheduledPayoutUserId).toBe(
      currentCycle?.finalPayoutUserId,
    );
    expect(currentCycle?.status).toBe(CycleStatus.OPEN);
  });

  it('disallows cycle generation when no active round exists', async () => {
    const group = await groupsController.createGroup(adminUser, {
      name: 'No Round Group',
      contributionAmount: 500,
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
