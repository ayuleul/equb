import { BadRequestException, ConflictException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import {
  AuctionStatus,
  CycleStatus,
  GroupFrequency,
  GroupRuleFrequency,
  GroupStatus,
  MemberRole,
  MemberStatus,
  NotificationStatus,
  NotificationType,
  PayoutMode,
  Platform,
} from '@prisma/client';

import { AppModule } from '../src/app.module';
import { seededShuffle, sha256Hex } from '../src/common/crypto/secure-shuffle';
import { PrismaService } from '../src/common/prisma/prisma.service';
import type { AuthenticatedUser } from '../src/common/types/authenticated-user.type';
import { GroupsController } from '../src/modules/groups/groups.controller';
import { FCM_PROVIDER } from '../src/modules/notifications/interfaces/fcm-provider.interface';

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
  drawSeedHash: string;
  drawSeedCiphertext: string | null;
  drawSeedRevealedAt: Date | null;
  drawSeedRevealedByUserId: string | null;
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

type NotificationRecord = {
  id: string;
  userId: string;
  groupId: string | null;
  eventId: string | null;
  type: NotificationType;
  title: string;
  body: string;
  dataJson: Record<string, unknown> | null;
  status: NotificationStatus;
  createdAt: Date;
  readAt: Date | null;
};

type GroupRulesRecord = {
  groupId: string;
  frequency: GroupRuleFrequency;
  customIntervalDays: number | null;
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
  const notifications: NotificationRecord[] = [];
  const groupRules: GroupRulesRecord[] = [];

  const adminUser: AuthenticatedUser = {
    id: 'user_admin',
    phone: '+251911111111',
  };

  const fcmProviderMock = {
    sendToTokens: jest.fn(() =>
      Promise.resolve({
        sentCount: 0,
        failedCount: 0,
      }),
    ),
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
          include,
          select,
        }: {
          where: { id: string };
          include?: {
            rules?: { select: { groupId: true } };
          };
          select?: {
            id?: boolean;
            frequency?: boolean;
            startDate?: boolean;
            timezone?: boolean;
            status?: boolean;
            rules?: { select: { frequency?: true; customIntervalDays?: true } };
          };
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

          if (!select) {
            return group;
          }

          return {
            ...(select.id ? { id: group.id } : {}),
            ...(select.frequency ? { frequency: group.frequency } : {}),
            ...(select.startDate ? { startDate: group.startDate } : {}),
            ...(select.timezone ? { timezone: group.timezone } : {}),
            ...(select.status ? { status: group.status } : {}),
            ...(select.rules ? { rules } : {}),
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
      findUnique: jest.fn(
        ({
          where,
        }: {
          where: { groupId_userId: { groupId: string; userId: string } };
        }) => {
          return (
            members.find(
              (member) =>
                member.groupId === where.groupId_userId.groupId &&
                member.userId === where.groupId_userId.userId,
            ) ?? null
          );
        },
      ),
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
            payoutMode?: PayoutMode;
          };
          select?: {
            id?: boolean;
            roundNo?: boolean;
            drawSeedHash?: boolean;
            drawSeedCiphertext?: boolean;
            drawSeedRevealedAt?: boolean;
            drawSeedRevealedByUserId?: boolean;
          };
          include?: {
            schedules?: {
              include?: {
                user?: {
                  select: {
                    id?: true;
                    phone?: true;
                    fullName?: true;
                  };
                };
              };
              orderBy: { position: 'asc' | 'desc' };
            };
          };
          orderBy?: { roundNo: 'asc' | 'desc' };
        }) => {
          let filtered = rounds.filter(
            (round) => round.groupId === where.groupId,
          );
          if (where.payoutMode) {
            filtered = filtered.filter(
              (round) => round.payoutMode === where.payoutMode,
            );
          }
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
              ...(select.drawSeedHash
                ? { drawSeedHash: found.drawSeedHash }
                : {}),
              ...(select.drawSeedCiphertext
                ? { drawSeedCiphertext: found.drawSeedCiphertext }
                : {}),
              ...(select.drawSeedRevealedAt
                ? { drawSeedRevealedAt: found.drawSeedRevealedAt }
                : {}),
              ...(select.drawSeedRevealedByUserId
                ? { drawSeedRevealedByUserId: found.drawSeedRevealedByUserId }
                : {}),
            };
          }

          if (include?.schedules) {
            return {
              ...found,
              schedules: schedules
                .filter((schedule) => schedule.roundId === found.id)
                .sort((a, b) => a.position - b.position)
                .map((schedule) => ({
                  ...schedule,
                  ...(include.schedules?.include?.user
                    ? { user: findUser(schedule.userId) }
                    : {}),
                })),
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
            drawSeedHash: string;
            drawSeedCiphertext?: string | null;
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
            drawSeedHash: data.drawSeedHash,
            drawSeedCiphertext: data.drawSeedCiphertext ?? null,
            drawSeedRevealedAt: null,
            drawSeedRevealedByUserId: null,
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
          data: {
            closedAt?: Date;
            drawSeedRevealedAt?: Date;
            drawSeedRevealedByUserId?: string;
          };
        }) => {
          const round = rounds.find((item) => item.id === where.id);
          if (!round) {
            throw new Error('Round not found');
          }
          if (data.closedAt) {
            round.closedAt = data.closedAt;
          }
          if (data.drawSeedRevealedAt) {
            round.drawSeedRevealedAt = data.drawSeedRevealedAt;
          }
          if (data.drawSeedRevealedByUserId) {
            round.drawSeedRevealedByUserId = data.drawSeedRevealedByUserId;
          }
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
            groupId?: string;
            roundId?: string;
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
          orderBy?:
            | Array<{ dueDate?: 'asc' | 'desc'; createdAt?: 'asc' | 'desc' }>
            | { cycleNo: 'asc' | 'desc' };
        }) => {
          let filtered = cycles;
          if (where.groupId) {
            filtered = filtered.filter(
              (cycle) => cycle.groupId === where.groupId,
            );
          }
          if (where.roundId) {
            filtered = filtered.filter(
              (cycle) => cycle.roundId === where.roundId,
            );
          }
          if (where.status) {
            filtered = filtered.filter(
              (cycle) => cycle.status === where.status,
            );
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
          } else if (
            orderBy &&
            'cycleNo' in orderBy &&
            orderBy.cycleNo === 'desc'
          ) {
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
                ? {
                    winningBidUser: found.winningBidUserId
                      ? findUser(found.winningBidUserId)
                      : null,
                  }
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
    notification: {
      create: jest.fn(
        ({
          data,
        }: {
          data: {
            userId: string;
            groupId?: string | null;
            eventId?: string | null;
            type: NotificationType;
            title: string;
            body: string;
            dataJson?: Record<string, unknown> | null;
          };
        }) => {
          const duplicate = notifications.find(
            (item) =>
              item.userId === data.userId &&
              item.eventId !== null &&
              item.eventId === (data.eventId ?? null),
          );
          if (duplicate) {
            const error = new Error('Duplicate notification event');
            (error as Error & { code?: string }).code = 'P2002';
            throw error;
          }

          const notification: NotificationRecord = {
            id: `notification_${notifications.length + 1}`,
            userId: data.userId,
            groupId: data.groupId ?? null,
            eventId: data.eventId ?? null,
            type: data.type,
            title: data.title,
            body: data.body,
            dataJson: data.dataJson ?? null,
            status: NotificationStatus.UNREAD,
            createdAt: new Date(),
            readAt: null,
          };
          notifications.push(notification);
          return notification;
        },
      ),
      findFirst: jest.fn(
        ({
          where,
        }: {
          where: {
            userId?: string;
            eventId?: string;
            type?: NotificationType;
            dataJson?: { path: string[]; equals: string };
          };
        }) => {
          return (
            notifications.find((item) => {
              const userMatch = !where.userId || item.userId === where.userId;
              const eventMatch =
                !where.eventId || item.eventId === where.eventId;
              const typeMatch = !where.type || item.type === where.type;
              const dedupMatch = !where.dataJson
                ? true
                : item.dataJson?.dedupKey === where.dataJson.equals;
              return userMatch && eventMatch && typeMatch && dedupMatch;
            }) ?? null
          );
        },
      ),
    },
    deviceToken: {
      findMany: jest.fn(
        ({
          where,
        }: {
          where: {
            userId: string;
            isActive: boolean;
          };
        }) => {
          if (!where.isActive) {
            return [];
          }
          return [];
        },
      ),
      upsert: jest.fn(
        ({
          create,
        }: {
          create: {
            userId: string;
            token: string;
            platform: Platform;
            isActive: boolean;
            lastSeenAt: Date;
          };
        }) => ({
          id: `device_${create.userId}`,
          ...create,
          createdAt: new Date(),
        }),
      ),
    },
    inviteCode: {
      create: jest.fn(),
      findUnique: jest.fn(),
      updateMany: jest.fn(),
    },
    groupRules: {
      create: jest.fn(
        ({
          data,
        }: {
          data: {
            groupId: string;
            frequency: GroupRuleFrequency;
            customIntervalDays: number | null;
          };
        }) => {
          const existing = groupRules.find(
            (item) => item.groupId === data.groupId,
          );
          if (existing) {
            return existing;
          }

          const record: GroupRulesRecord = {
            groupId: data.groupId,
            frequency: data.frequency,
            customIntervalDays: data.customIntervalDays,
          };
          groupRules.push(record);
          return record;
        },
      ),
      findUnique: jest.fn(({ where }: { where: { groupId: string } }) => {
        return (
          groupRules.find((item) => item.groupId === where.groupId) ?? null
        );
      }),
      upsert: jest.fn(
        ({
          where,
          create,
        }: {
          where: { groupId: string };
          create: {
            frequency: GroupRuleFrequency;
            customIntervalDays: number | null;
          };
        }) => {
          const existing = groupRules.find(
            (item) => item.groupId === where.groupId,
          );
          if (existing) {
            return existing;
          }

          const record: GroupRulesRecord = {
            groupId: where.groupId,
            frequency: create.frequency,
            customIntervalDays: create.customIntervalDays,
          };
          groupRules.push(record);
          return record;
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
    process.env.DRAW_SEED_ENC_KEY =
      '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(PrismaService)
      .useValue(prismaMock)
      .overrideProvider(FCM_PROVIDER)
      .useValue(fcmProviderMock)
      .compile();

    groupsController = moduleFixture.get<GroupsController>(GroupsController);
  });

  beforeEach(() => {
    groups.splice(0, groups.length);
    members.splice(0, members.length);
    rounds.splice(0, rounds.length);
    schedules.splice(0, schedules.length);
    cycles.splice(0, cycles.length);
    notifications.splice(0, notifications.length);
    groupRules.splice(0, groupRules.length);
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

    const generatedCycle = await groupsController.generateCycles(
      adminUser,
      group.id,
      {},
    );

    expect(generatedCycle.scheduledPayoutUserId).toBe(
      generatedCycle.finalPayoutUserId,
    );
    expect(generatedCycle.auctionStatus).toBe(AuctionStatus.NONE);

    const currentCycle = await groupsController.getCurrentCycle(group.id);
    expect(currentCycle).not.toBeNull();
    expect(currentCycle?.scheduledPayoutUserId).toBe(
      currentCycle?.finalPayoutUserId,
    );
    expect(currentCycle?.status).toBe(CycleStatus.OPEN);
  });

  it('draw-next creates winner and announcement notifications for round snapshot members', async () => {
    const group = await groupsController.createGroup(adminUser, {
      name: 'Lottery Notify Group',
      contributionAmount: 750,
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

    await groupsController.startRound(adminUser, group.id);
    const createdCycle = await groupsController.drawNextCycle(
      adminUser,
      group.id,
    );

    expect(notifications).toHaveLength(2);

    const winnerNotification = notifications.find(
      (entry) => entry.type === NotificationType.LOTTERY_WINNER,
    );
    const announcementNotification = notifications.find(
      (entry) => entry.type === NotificationType.LOTTERY_ANNOUNCEMENT,
    );

    expect(winnerNotification).toBeDefined();
    expect(announcementNotification).toBeDefined();
    expect(winnerNotification?.userId).toBe(createdCycle.finalPayoutUserId);
    expect(announcementNotification?.userId).not.toBe(
      createdCycle.finalPayoutUserId,
    );
    expect(announcementNotification?.body).toContain('won this turn');

    expect(winnerNotification?.dataJson).toMatchObject({
      groupId: group.id,
      cycleId: createdCycle.id,
      roundId: createdCycle.roundId,
      kind: 'winner',
      route: `/groups/${group.id}/cycles/${createdCycle.id}`,
    });
    expect(announcementNotification?.dataJson).toMatchObject({
      groupId: group.id,
      cycleId: createdCycle.id,
      roundId: createdCycle.roundId,
      kind: 'announcement',
      winnerUserId: createdCycle.finalPayoutUserId,
      route: `/groups/${group.id}/cycles/${createdCycle.id}`,
    });

    expect((fcmProviderMock.sendToTokens as jest.Mock).mock.calls).toHaveLength(
      2,
    );
  });

  it('stores draw commitment, exposes schedule, reveals seed, and allows deterministic verification', async () => {
    const group = await groupsController.createGroup(adminUser, {
      name: 'Auditable Draw Group',
      contributionAmount: 800,
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

    const startedRound = await groupsController.startRound(adminUser, group.id);
    expect(startedRound.drawSeedHash).toMatch(/^[a-f0-9]{64}$/);
    expect(rounds[0]?.drawSeedCiphertext).toBeTruthy();

    const currentSchedule = await groupsController.getCurrentRoundSchedule(
      group.id,
    );
    expect(currentSchedule.roundId).toBe(startedRound.id);
    expect(currentSchedule.drawSeedHash).toBe(startedRound.drawSeedHash);
    expect(currentSchedule.schedule).toHaveLength(2);
    expect(currentSchedule.schedule.map((entry) => entry.position)).toEqual([
      1, 2,
    ]);

    const reveal = await groupsController.revealCurrentRoundSeed(
      adminUser,
      group.id,
    );
    expect(reveal.seedHash).toBe(currentSchedule.drawSeedHash);
    expect(sha256Hex(Buffer.from(reveal.seedHex, 'hex'))).toBe(
      currentSchedule.drawSeedHash,
    );

    const snapshotUserIds = members
      .filter(
        (entry) =>
          entry.groupId === group.id && entry.status === MemberStatus.ACTIVE,
      )
      .map((entry) => entry.userId);
    const expectedOrder = seededShuffle(
      snapshotUserIds,
      Buffer.from(reveal.seedHex, 'hex'),
    );
    expect(currentSchedule.schedule.map((entry) => entry.userId)).toEqual(
      expectedOrder,
    );

    const secondReveal = await groupsController.revealCurrentRoundSeed(
      adminUser,
      group.id,
    );
    expect(secondReveal.seedHex).toBe(reveal.seedHex);
    expect(secondReveal.revealedAt).toEqual(reveal.revealedAt);
    expect(secondReveal.revealedByUserId).toBe(reveal.revealedByUserId);

    const auditCalls = (prismaMock.auditLog.create as unknown as jest.Mock).mock
      .calls;
    const seedRevealedCalls = auditCalls.filter(
      ([payload]: [{ data: { action: string } }]) =>
        payload.data.action === 'SEED_REVEALED',
    );
    expect(seedRevealedCalls).toHaveLength(1);
    for (const [payload] of auditCalls) {
      expect(JSON.stringify(payload)).not.toContain(reveal.seedHex);
    }
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
      groupsController.generateCycles(adminUser, group.id, {}),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('rejects generation when an open cycle already exists', async () => {
    const group = await groupsController.createGroup(adminUser, {
      name: 'Open Cycle Guard Group',
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

    await groupsController.startRound(adminUser, group.id);
    await groupsController.generateCycles(adminUser, group.id, {});

    await expect(
      groupsController.generateCycles(adminUser, group.id, {}),
    ).rejects.toBeInstanceOf(ConflictException);
  });

  it('generates the next sequential cycle after current cycle is closed', async () => {
    const group = await groupsController.createGroup(adminUser, {
      name: 'Sequential Group',
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

    await groupsController.startRound(adminUser, group.id);
    const firstCycle = await groupsController.generateCycles(
      adminUser,
      group.id,
      {},
    );

    const firstCycleRecord = cycles.find((entry) => entry.id === firstCycle.id);
    if (firstCycleRecord) {
      firstCycleRecord.status = CycleStatus.CLOSED;
    }

    const secondCycle = await groupsController.generateCycles(
      adminUser,
      group.id,
      {},
    );

    expect(secondCycle.cycleNo).toBe(firstCycle.cycleNo + 1);
  });

  it('returns conflict when active round schedule is completed', async () => {
    const group = await groupsController.createGroup(adminUser, {
      name: 'Round Completion Group',
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

    await groupsController.startRound(adminUser, group.id);
    const firstCycle = await groupsController.generateCycles(
      adminUser,
      group.id,
      {},
    );
    const firstCycleRecord = cycles.find((entry) => entry.id === firstCycle.id);
    if (firstCycleRecord) {
      firstCycleRecord.status = CycleStatus.CLOSED;
    }

    const secondCycle = await groupsController.generateCycles(
      adminUser,
      group.id,
      {},
    );
    const secondCycleRecord = cycles.find(
      (entry) => entry.id === secondCycle.id,
    );
    if (secondCycleRecord) {
      secondCycleRecord.status = CycleStatus.CLOSED;
    }

    await expect(
      groupsController.generateCycles(adminUser, group.id, {}),
    ).rejects.toBeInstanceOf(ConflictException);
  });
});
