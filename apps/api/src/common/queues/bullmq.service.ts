import {
  Injectable,
  Logger,
  OnModuleDestroy,
  OnModuleInit,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ConnectionOptions, JobsOptions, Queue } from 'bullmq';

import {
  NOTIFICATION_DELIVERY_JOB,
  NOTIFICATIONS_QUEUE,
  REMINDER_SCAN_JOB,
  REMINDERS_QUEUE,
} from './queue.constants';
import { NotificationJobData, ReminderJobData } from './queue.types';

const DEFAULT_REDIS_URL = 'redis://redis:6379';

@Injectable()
export class BullMqService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(BullMqService.name);
  private readonly jobsDisabled: boolean;
  private readonly connectionOptions: ConnectionOptions;

  private notificationsQueue: Queue<NotificationJobData> | null = null;
  private remindersQueue: Queue<ReminderJobData> | null = null;

  constructor(private readonly configService: ConfigService) {
    const configuredJobsDisabled =
      this.configService.get<string>('JOBS_DISABLED') ??
      (process.env.NODE_ENV === 'test' ? 'true' : 'false');

    this.jobsDisabled = configuredJobsDisabled.toLowerCase() === 'true';
    this.connectionOptions = this.parseRedisUrl(
      this.configService.get<string>('REDIS_URL') ?? DEFAULT_REDIS_URL,
    );
  }

  onModuleInit(): void {
    if (this.jobsDisabled) {
      this.logger.log('Background jobs are disabled (JOBS_DISABLED=true)');
      return;
    }

    this.notificationsQueue = new Queue<NotificationJobData>(
      NOTIFICATIONS_QUEUE,
      {
        connection: this.connectionOptions,
      },
    );

    this.remindersQueue = new Queue<ReminderJobData>(REMINDERS_QUEUE, {
      connection: this.connectionOptions,
    });
  }

  async onModuleDestroy(): Promise<void> {
    await Promise.all([
      this.notificationsQueue?.close(),
      this.remindersQueue?.close(),
    ]);
  }

  isEnabled(): boolean {
    return !this.jobsDisabled;
  }

  getConnectionOptions(): ConnectionOptions {
    return this.connectionOptions;
  }

  async enqueueNotification(
    data: NotificationJobData,
    options?: Pick<JobsOptions, 'jobId'>,
  ): Promise<boolean> {
    if (!this.notificationsQueue) {
      return false;
    }

    try {
      await this.notificationsQueue.add(NOTIFICATION_DELIVERY_JOB, data, {
        jobId: options?.jobId,
        removeOnComplete: 500,
        removeOnFail: 500,
      });
      return true;
    } catch (error) {
      this.logger.error(
        `Failed to enqueue notification job for userId=${data.userId}`,
        error instanceof Error ? error.stack : undefined,
      );
      return false;
    }
  }

  async enqueueReminderScan(
    data: ReminderJobData,
    options?: Pick<JobsOptions, 'jobId'>,
  ): Promise<boolean> {
    if (!this.remindersQueue) {
      return false;
    }

    try {
      await this.remindersQueue.add(REMINDER_SCAN_JOB, data, {
        jobId: options?.jobId,
        removeOnComplete: 100,
        removeOnFail: 100,
      });
      return true;
    } catch (error) {
      this.logger.error(
        'Failed to enqueue reminder scan job',
        error instanceof Error ? error.stack : undefined,
      );
      return false;
    }
  }

  async pingRedis(): Promise<'up' | 'down' | 'disabled'> {
    if (this.jobsDisabled) {
      return 'disabled';
    }

    if (!this.notificationsQueue) {
      return 'down';
    }

    try {
      const client = await this.notificationsQueue.client;
      await client.ping();
      return 'up';
    } catch {
      return 'down';
    }
  }

  private parseRedisUrl(redisUrl: string): ConnectionOptions {
    const parsed = new URL(redisUrl);
    const dbPath = parsed.pathname.replace('/', '').trim();
    const db = dbPath ? Number(dbPath) : 0;

    return {
      host: parsed.hostname,
      port: parsed.port ? Number(parsed.port) : 6379,
      username: parsed.username || undefined,
      password: parsed.password || undefined,
      db: Number.isFinite(db) ? db : 0,
      tls: parsed.protocol === 'rediss:' ? {} : undefined,
      maxRetriesPerRequest: null,
    };
  }
}
