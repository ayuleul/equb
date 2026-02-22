import {
  ForbiddenException,
  Inject,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import {
  MemberRole,
  MemberStatus,
  NotificationStatus,
  NotificationType,
  Prisma,
} from '@prisma/client';

import { AuditService } from '../../common/audit/audit.service';
import { BullMqService } from '../../common/queues/bullmq.service';
import { PrismaService } from '../../common/prisma/prisma.service';
import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import { ListNotificationsDto } from './dto/list-notifications.dto';
import { RegisterDeviceTokenDto } from './dto/register-device-token.dto';
import { FCM_PROVIDER } from './interfaces/fcm-provider.interface';
import type { FcmProvider } from './interfaces/fcm-provider.interface';
import {
  DeviceTokenResponseDto,
  NotificationListResponseDto,
  NotificationResponseDto,
} from './entities/notifications.entities';
import { NotificationJobData } from '../../common/queues/queue.types';

export interface NotificationPayload {
  type: NotificationType;
  title: string;
  body: string;
  groupId?: string | null;
  eventId?: string;
  data?: Record<string, unknown> | null;
  dedupKey?: string;
}

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly auditService: AuditService,
    private readonly bullMqService: BullMqService,
    @Inject(FCM_PROVIDER) private readonly fcmProvider: FcmProvider,
  ) {}

  async registerDeviceToken(
    currentUser: AuthenticatedUser,
    dto: RegisterDeviceTokenDto,
  ): Promise<DeviceTokenResponseDto> {
    const now = new Date();

    const token = await this.prisma.deviceToken.upsert({
      where: {
        userId_token: {
          userId: currentUser.id,
          token: dto.token,
        },
      },
      create: {
        userId: currentUser.id,
        token: dto.token,
        platform: dto.platform,
        isActive: true,
        lastSeenAt: now,
      },
      update: {
        platform: dto.platform,
        isActive: true,
        lastSeenAt: now,
      },
    });

    await this.auditService.log('DEVICE_TOKEN_REGISTERED', currentUser.id, {
      deviceTokenId: token.id,
      platform: dto.platform,
    });

    return token;
  }

  async listNotifications(
    currentUser: AuthenticatedUser,
    dto: ListNotificationsDto,
  ): Promise<NotificationListResponseDto> {
    const where = {
      userId: currentUser.id,
      ...(dto.status ? { status: dto.status } : {}),
    };

    const [items, total] = await Promise.all([
      this.prisma.notification.findMany({
        where,
        orderBy: {
          createdAt: 'desc',
        },
        skip: dto.offset,
        take: dto.limit,
      }),
      this.prisma.notification.count({ where }),
    ]);

    return {
      items: items.map((item) => this.toNotificationResponse(item)),
      total,
      offset: dto.offset,
      limit: dto.limit,
    };
  }

  async markNotificationRead(
    currentUser: AuthenticatedUser,
    notificationId: string,
  ): Promise<NotificationResponseDto> {
    const notification = await this.prisma.notification.findUnique({
      where: { id: notificationId },
    });

    if (!notification) {
      throw new NotFoundException('Notification not found');
    }

    if (notification.userId !== currentUser.id) {
      throw new ForbiddenException('You can only read your own notifications');
    }

    const updated =
      notification.status === NotificationStatus.READ
        ? notification
        : await this.prisma.notification.update({
            where: {
              id: notification.id,
            },
            data: {
              status: NotificationStatus.READ,
              readAt: new Date(),
            },
          });

    await this.auditService.log('NOTIFICATION_READ', currentUser.id, {
      notificationId: updated.id,
    });

    return this.toNotificationResponse(updated);
  }

  async notifyUser(
    userId: string,
    payload: NotificationPayload,
  ): Promise<void> {
    try {
      const dedupKey = payload.dedupKey ?? payload.eventId;
      const dataWithDedup = this.attachDedupKey(payload.data, dedupKey);
      const jobData: NotificationJobData = {
        userId,
        groupId: payload.groupId ?? null,
        eventId: payload.eventId ?? null,
        type: payload.type,
        title: payload.title,
        body: payload.body,
        data: dataWithDedup,
        dedupKey,
      };

      if (
        payload.eventId &&
        (await this.existsForEventId(userId, payload.eventId))
      ) {
        return;
      }

      if (
        dedupKey &&
        (await this.existsForDedup(userId, payload.type, dedupKey))
      ) {
        return;
      }

      const queued = await this.bullMqService.enqueueNotification(jobData, {
        jobId: dedupKey ? `notification:${dedupKey}` : undefined,
      });

      if (!queued) {
        await this.deliverNotification(jobData);
      }
    } catch (error) {
      this.logger.error(
        `Failed to notify userId=${userId}`,
        error instanceof Error ? error.stack : undefined,
      );
    }
  }

  async notifyGroupAdmins(
    groupId: string,
    payload: NotificationPayload,
    options?: { excludeUserId?: string },
  ): Promise<void> {
    try {
      const admins =
        (await this.prisma.equbMember?.findMany?.({
          where: {
            groupId,
            status: MemberStatus.ACTIVE,
            role: MemberRole.ADMIN,
            ...(options?.excludeUserId
              ? {
                  userId: {
                    not: options.excludeUserId,
                  },
                }
              : {}),
          },
          select: {
            userId: true,
          },
        })) ?? [];

      await Promise.all(
        admins.map((admin) =>
          this.notifyUser(admin.userId, {
            ...payload,
            groupId,
          }),
        ),
      );
    } catch (error) {
      this.logger.error(
        `Failed to notify admins for groupId=${groupId}`,
        error instanceof Error ? error.stack : undefined,
      );
    }
  }

  async notifyGroupMembers(
    groupId: string,
    payload: NotificationPayload,
    options?: { excludeUserId?: string },
  ): Promise<void> {
    try {
      const members =
        (await this.prisma.equbMember?.findMany?.({
          where: {
            groupId,
            status: MemberStatus.ACTIVE,
            ...(options?.excludeUserId
              ? {
                  userId: {
                    not: options.excludeUserId,
                  },
                }
              : {}),
          },
          select: {
            userId: true,
          },
        })) ?? [];

      await Promise.all(
        members.map((member) =>
          this.notifyUser(member.userId, {
            ...payload,
            groupId,
          }),
        ),
      );
    } catch (error) {
      this.logger.error(
        `Failed to notify members for groupId=${groupId}`,
        error instanceof Error ? error.stack : undefined,
      );
    }
  }

  async deliverNotification(jobData: NotificationJobData): Promise<void> {
    const dedupKey = jobData.dedupKey ?? jobData.eventId ?? undefined;

    if (
      jobData.eventId &&
      (await this.existsForEventId(jobData.userId, jobData.eventId))
    ) {
      return;
    }

    if (
      dedupKey &&
      (await this.existsForDedup(jobData.userId, jobData.type, dedupKey))
    ) {
      return;
    }

    let notification:
      | {
          id: string;
          userId: string;
          groupId: string | null;
          type: NotificationType;
        }
      | null
      | undefined = null;
    try {
      notification = await this.prisma.notification?.create?.({
        data: {
          userId: jobData.userId,
          groupId: jobData.groupId ?? null,
          eventId: jobData.eventId ?? null,
          type: jobData.type,
          title: jobData.title,
          body: jobData.body,
          dataJson: jobData.data
            ? (jobData.data as Prisma.InputJsonValue)
            : undefined,
        },
      });
    } catch (error) {
      if (this.isUniqueConstraintViolation(error)) {
        return;
      }
      this.logger.error(
        `Notification persistence failed for userId=${jobData.userId}`,
        error instanceof Error ? error.stack : undefined,
      );
      return;
    }

    if (!notification) {
      return;
    }

    await this.sendPushToUser(
      jobData.userId,
      jobData.title,
      jobData.body,
      jobData.data,
    );

    await this.auditService.log(
      'NOTIFICATION_CREATED',
      null,
      {
        notificationId: notification.id,
        userId: notification.userId,
        type: notification.type,
        dedupKey,
        eventId: jobData.eventId ?? null,
      },
      notification.groupId,
    );
  }

  async sendPushToUser(
    userId: string,
    title: string,
    body: string,
    data?: Record<string, unknown> | null,
  ): Promise<void> {
    const activeTokens =
      (await this.prisma.deviceToken?.findMany?.({
        where: {
          userId,
          isActive: true,
        },
        select: {
          token: true,
        },
      })) ?? [];

    try {
      await this.fcmProvider.sendToTokens(
        activeTokens.map((item) => item.token),
        title,
        body,
        data,
      );
    } catch (error) {
      this.logger.error(
        `Push delivery failed for userId=${userId}`,
        error instanceof Error ? error.stack : undefined,
      );
    }
  }

  private attachDedupKey(
    data: Record<string, unknown> | null | undefined,
    dedupKey: string | undefined,
  ): Record<string, unknown> | null {
    const payload: Record<string, unknown> = {
      ...(data ?? {}),
    };

    if (dedupKey) {
      payload.dedupKey = dedupKey;
    }

    return Object.keys(payload).length > 0 ? payload : null;
  }

  private async existsForDedup(
    userId: string,
    type: NotificationType,
    dedupKey: string,
  ): Promise<boolean> {
    const existing = await this.prisma.notification?.findFirst?.({
      where: {
        userId,
        type,
        dataJson: {
          path: ['dedupKey'],
          equals: dedupKey,
        },
      },
      select: {
        id: true,
      },
    });

    return Boolean(existing);
  }

  private async existsForEventId(
    userId: string,
    eventId: string,
  ): Promise<boolean> {
    const existing = await this.prisma.notification?.findFirst?.({
      where: {
        userId,
        eventId,
      },
      select: {
        id: true,
      },
    });

    return Boolean(existing);
  }

  private isUniqueConstraintViolation(error: unknown): boolean {
    return (
      error instanceof Prisma.PrismaClientKnownRequestError &&
      error.code === 'P2002'
    );
  }

  private toNotificationResponse(value: {
    id: string;
    userId: string;
    groupId: string | null;
    type: NotificationType;
    title: string;
    body: string;
    dataJson: Prisma.JsonValue | null;
    status: NotificationStatus;
    createdAt: Date;
    readAt: Date | null;
  }): NotificationResponseDto {
    return {
      ...value,
      dataJson: (value.dataJson as Record<string, unknown> | null) ?? null,
    };
  }
}
