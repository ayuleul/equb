import { Test, TestingModule } from '@nestjs/testing';
import { NotificationType } from '@prisma/client';

import { AuditService } from '../../common/audit/audit.service';
import { PrismaService } from '../../common/prisma/prisma.service';
import { BullMqService } from '../../common/queues/bullmq.service';
import { FCM_PROVIDER, FcmProvider } from './interfaces/fcm-provider.interface';
import { NotificationsService } from './notifications.service';

describe('NotificationsService', () => {
  let service: NotificationsService;

  const prismaMock = {
    notification: {
      findFirst: jest.fn(),
      create: jest.fn(),
    },
    deviceToken: {
      findMany: jest.fn(),
    },
    auditLog: {
      create: jest.fn(() => ({ id: 'audit_1' })),
    },
  } as unknown as PrismaService;

  const bullMqMock = {
    enqueueNotification: jest.fn(),
  } as unknown as BullMqService;

  const fcmProviderMock: FcmProvider = {
    sendToTokens: jest.fn(() =>
      Promise.resolve({
        sentCount: 0,
        failedCount: 0,
      }),
    ),
  };

  beforeEach(async () => {
    const moduleRef: TestingModule = await Test.createTestingModule({
      providers: [
        NotificationsService,
        AuditService,
        {
          provide: PrismaService,
          useValue: prismaMock,
        },
        {
          provide: BullMqService,
          useValue: bullMqMock,
        },
        {
          provide: FCM_PROVIDER,
          useValue: fcmProviderMock,
        },
      ],
    }).compile();

    service = moduleRef.get(NotificationsService);
    jest.clearAllMocks();
  });

  it('enqueues notification job with dedup jobId', async () => {
    prismaMock.notification.findFirst = jest.fn().mockResolvedValue(null);
    bullMqMock.enqueueNotification = jest.fn().mockResolvedValue(true);

    await service.notifyUser('user_1', {
      type: NotificationType.CONTRIBUTION_CONFIRMED,
      title: 'Contribution confirmed',
      body: 'Done',
      dedupKey: 'dedup-1',
    });

    const enqueueCalls = (bullMqMock.enqueueNotification as jest.Mock).mock
      .calls;
    expect(enqueueCalls).toHaveLength(1);
    expect(enqueueCalls[0]).toEqual([
      expect.objectContaining({
        userId: 'user_1',
        type: NotificationType.CONTRIBUTION_CONFIRMED,
      }),
      { jobId: 'notification:dedup-1' },
    ]);
    expect(
      (prismaMock.notification.create as jest.Mock).mock.calls,
    ).toHaveLength(0);
  });

  it('falls back to direct delivery when queueing is unavailable', async () => {
    prismaMock.notification.findFirst = jest.fn().mockResolvedValue(null);
    prismaMock.deviceToken.findMany = jest.fn().mockResolvedValue([]);
    prismaMock.notification.create = jest.fn().mockResolvedValue({
      id: 'notification_1',
      userId: 'user_2',
      groupId: null,
      type: NotificationType.PAYOUT_CONFIRMED,
    });
    bullMqMock.enqueueNotification = jest.fn().mockResolvedValue(false);

    await service.notifyUser('user_2', {
      type: NotificationType.PAYOUT_CONFIRMED,
      title: 'Payout confirmed',
      body: 'Done',
    });

    expect(
      (prismaMock.notification.create as jest.Mock).mock.calls.length,
    ).toBe(1);
  });
});
