import { Test, TestingModule } from '@nestjs/testing';
import {
  ContributionStatus,
  NotificationStatus,
  NotificationType,
  Platform,
} from '@prisma/client';

import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/common/prisma/prisma.service';
import { BullMqService } from '../src/common/queues/bullmq.service';
import type { AuthenticatedUser } from '../src/common/types/authenticated-user.type';
import { ContributionsController } from '../src/modules/contributions/contributions.controller';
import { FCM_PROVIDER } from '../src/modules/notifications/interfaces/fcm-provider.interface';
import { NotificationsController } from '../src/modules/notifications/notifications.controller';

type UserRecord = {
  id: string;
  phone: string;
  fullName: string | null;
};

type DeviceTokenRecord = {
  id: string;
  userId: string;
  token: string;
  platform: Platform;
  isActive: boolean;
  lastSeenAt: Date;
  createdAt: Date;
};

type NotificationRecord = {
  id: string;
  userId: string;
  groupId: string | null;
  type: NotificationType;
  title: string;
  body: string;
  dataJson: Record<string, unknown> | null;
  status: NotificationStatus;
  createdAt: Date;
  readAt: Date | null;
};

type ContributionRecord = {
  id: string;
  groupId: string;
  cycleId: string;
  userId: string;
  amount: number;
  status: ContributionStatus;
  proofFileKey: string | null;
  paymentRef: string | null;
  note: string | null;
  submittedAt: Date | null;
  confirmedByUserId: string | null;
  confirmedAt: Date | null;
  rejectedByUserId: string | null;
  rejectedAt: Date | null;
  rejectReason: string | null;
  createdAt: Date;
};

describe('Notifications (e2e)', () => {
  let notificationsController: NotificationsController;
  let contributionsController: ContributionsController;

  const users: UserRecord[] = [
    {
      id: '00000000-0000-0000-0000-000000000011',
      phone: '+251911111111',
      fullName: 'Admin User',
    },
    {
      id: '00000000-0000-0000-0000-000000000022',
      phone: '+251922222222',
      fullName: 'Member User',
    },
  ];

  const deviceTokens: DeviceTokenRecord[] = [];
  const notifications: NotificationRecord[] = [];
  const contributions: ContributionRecord[] = [];

  const adminUser: AuthenticatedUser = {
    id: '00000000-0000-0000-0000-000000000011',
    phone: '+251911111111',
  };

  const memberUser: AuthenticatedUser = {
    id: '00000000-0000-0000-0000-000000000022',
    phone: '+251922222222',
  };

  const prismaMock = {
    deviceToken: {
      upsert: jest.fn(
        ({
          where,
          create,
          update,
        }: {
          where: { userId_token: { userId: string; token: string } };
          create: Omit<DeviceTokenRecord, 'id' | 'createdAt'>;
          update: Partial<DeviceTokenRecord>;
        }) => {
          const existing = deviceTokens.find(
            (item) =>
              item.userId === where.userId_token.userId &&
              item.token === where.userId_token.token,
          );

          if (existing) {
            Object.assign(existing, update);
            return existing;
          }

          const created: DeviceTokenRecord = {
            id: `device_${deviceTokens.length + 1}`,
            createdAt: new Date(),
            ...create,
          };
          deviceTokens.push(created);
          return created;
        },
      ),
      findMany: jest.fn(
        ({ where }: { where: { userId: string; isActive: boolean } }) =>
          deviceTokens
            .filter(
              (item) =>
                item.userId === where.userId &&
                item.isActive === where.isActive,
            )
            .map((item) => ({ token: item.token })),
      ),
    },
    notification: {
      findFirst: jest.fn(() => null),
      create: jest.fn(
        ({
          data,
        }: {
          data: Omit<
            NotificationRecord,
            'id' | 'status' | 'createdAt' | 'readAt'
          > & {
            status?: NotificationStatus;
          };
        }) => {
          const created: NotificationRecord = {
            id: `notification_${notifications.length + 1}`,
            status: data.status ?? NotificationStatus.UNREAD,
            createdAt: new Date(),
            readAt: null,
            userId: data.userId,
            groupId: data.groupId ?? null,
            type: data.type,
            title: data.title,
            body: data.body,
            dataJson: (data.dataJson as Record<string, unknown>) ?? null,
          };

          notifications.push(created);
          return created;
        },
      ),
      findMany: jest.fn(
        ({
          where,
          skip,
          take,
        }: {
          where: { userId: string; status?: NotificationStatus };
          skip: number;
          take: number;
        }) =>
          notifications
            .filter((item) => {
              const userMatch = item.userId === where.userId;
              const statusMatch = !where.status || item.status === where.status;
              return userMatch && statusMatch;
            })
            .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime())
            .slice(skip, skip + take),
      ),
      count: jest.fn(
        ({
          where,
        }: {
          where: { userId: string; status?: NotificationStatus };
        }) =>
          notifications.filter((item) => {
            const userMatch = item.userId === where.userId;
            const statusMatch = !where.status || item.status === where.status;
            return userMatch && statusMatch;
          }).length,
      ),
      findUnique: jest.fn(({ where }: { where: { id: string } }) => {
        return notifications.find((item) => item.id === where.id) ?? null;
      }),
      update: jest.fn(
        ({
          where,
          data,
        }: {
          where: { id: string };
          data: Partial<NotificationRecord>;
        }) => {
          const record = notifications.find((item) => item.id === where.id);
          if (!record) {
            throw new Error('Notification not found');
          }

          Object.assign(record, data);
          return record;
        },
      ),
    },
    contribution: {
      findUnique: jest.fn(
        ({
          where,
          include,
        }: {
          where: { id: string };
          include?: {
            user?: { select: { id: true; fullName: true; phone: true } };
          };
        }) => {
          const contribution =
            contributions.find((item) => item.id === where.id) ?? null;

          if (!contribution) {
            return null;
          }

          if (include?.user) {
            return {
              ...contribution,
              user:
                users.find((item) => item.id === contribution.userId) ?? null,
            };
          }

          return contribution;
        },
      ),
      update: jest.fn(
        ({
          where,
          data,
          include,
        }: {
          where: { id: string };
          data: Partial<ContributionRecord>;
          include?: {
            user?: { select: { id: true; fullName: true; phone: true } };
          };
        }) => {
          const contribution = contributions.find(
            (item) => item.id === where.id,
          );
          if (!contribution) {
            throw new Error('Contribution not found');
          }

          Object.assign(contribution, data);

          if (include?.user) {
            return {
              ...contribution,
              user:
                users.find((item) => item.id === contribution.userId) ?? null,
            };
          }

          return contribution;
        },
      ),
      count: jest.fn(
        ({
          where,
        }: {
          where: { cycleId: string; status: ContributionStatus };
        }) =>
          contributions.filter(
            (item) =>
              item.cycleId === where.cycleId && item.status === where.status,
          ).length,
      ),
    },
    equbCycle: {
      update: jest.fn(() => ({})),
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

  const bullMqMock = {
    enqueueNotification: jest.fn(() => Promise.resolve(false)),
    enqueueReminderScan: jest.fn(() => Promise.resolve(true)),
    isEnabled: jest.fn(() => false),
    pingRedis: jest.fn(() => Promise.resolve('disabled')),
  } as unknown as BullMqService;

  const fcmProviderMock = {
    sendToTokens: jest.fn(() =>
      Promise.resolve({
        sentCount: 0,
        failedCount: 0,
      }),
    ),
  };

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(PrismaService)
      .useValue(prismaMock)
      .overrideProvider(BullMqService)
      .useValue(bullMqMock)
      .overrideProvider(FCM_PROVIDER)
      .useValue(fcmProviderMock)
      .compile();

    notificationsController = moduleFixture.get<NotificationsController>(
      NotificationsController,
    );
    contributionsController = moduleFixture.get<ContributionsController>(
      ContributionsController,
    );
  });

  beforeEach(() => {
    deviceTokens.splice(0, deviceTokens.length);
    notifications.splice(0, notifications.length);
    contributions.splice(0, contributions.length);
    jest.clearAllMocks();
  });

  it('registers device token and lists notifications', async () => {
    const token = await notificationsController.registerDeviceToken(
      memberUser,
      {
        token: 'fcm-token-1',
        platform: Platform.ANDROID,
      },
    );

    expect(token.userId).toBe(memberUser.id);
    expect(token.platform).toBe(Platform.ANDROID);

    notifications.push({
      id: 'notification_seed_1',
      userId: memberUser.id,
      groupId: null,
      type: NotificationType.DUE_REMINDER,
      title: 'Due reminder',
      body: 'Please contribute',
      dataJson: null,
      status: NotificationStatus.UNREAD,
      createdAt: new Date(),
      readAt: null,
    });

    const list = await notificationsController.listNotifications(memberUser, {
      offset: 0,
      limit: 20,
      status: NotificationStatus.UNREAD,
    });

    expect(list.total).toBe(1);
    expect(list.items[0].type).toBe(NotificationType.DUE_REMINDER);
  });

  it('contribution confirmation triggers notification row for contributor', async () => {
    contributions.push({
      id: 'contribution_1',
      groupId: '00000000-0000-0000-0000-000000000101',
      cycleId: '00000000-0000-0000-0000-000000000201',
      userId: memberUser.id,
      amount: 500,
      status: ContributionStatus.SUBMITTED,
      proofFileKey: null,
      paymentRef: null,
      note: null,
      submittedAt: new Date(),
      confirmedByUserId: null,
      confirmedAt: null,
      rejectedByUserId: null,
      rejectedAt: null,
      rejectReason: null,
      createdAt: new Date(),
    });

    const confirmed = await contributionsController.confirmContribution(
      adminUser,
      'contribution_1',
      {},
    );

    expect(confirmed.status).toBe(ContributionStatus.VERIFIED);

    const contributorNotifications = notifications.filter(
      (item) => item.userId === memberUser.id,
    );
    expect(contributorNotifications).toHaveLength(1);
    expect(contributorNotifications[0].type).toBe(
      NotificationType.CONTRIBUTION_CONFIRMED,
    );
  });
});
