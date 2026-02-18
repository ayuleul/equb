import {
  Injectable,
  Logger,
  OnModuleDestroy,
  OnModuleInit,
} from '@nestjs/common';
import { Job, Worker } from 'bullmq';

import { BullMqService } from '../../../common/queues/bullmq.service';
import { NOTIFICATIONS_QUEUE } from '../../../common/queues/queue.constants';
import { NotificationJobData } from '../../../common/queues/queue.types';
import { NotificationsService } from '../notifications.service';

@Injectable()
export class NotificationProcessor implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(NotificationProcessor.name);
  private worker: Worker<NotificationJobData> | null = null;

  constructor(
    private readonly bullMqService: BullMqService,
    private readonly notificationsService: NotificationsService,
  ) {}

  onModuleInit(): void {
    if (!this.bullMqService.isEnabled()) {
      return;
    }

    this.worker = new Worker<NotificationJobData>(
      NOTIFICATIONS_QUEUE,
      async (job) => this.process(job),
      {
        connection: this.bullMqService.getConnectionOptions(),
        concurrency: 10,
      },
    );

    this.worker.on('failed', (job, error) => {
      this.logger.error(
        `Notification job failed id=${job?.id ?? 'unknown'}`,
        error.stack,
      );
    });
  }

  async onModuleDestroy(): Promise<void> {
    await this.worker?.close();
  }

  private async process(job: Job<NotificationJobData>): Promise<void> {
    await this.notificationsService.deliverNotification(job.data);
  }
}
