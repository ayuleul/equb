import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';

import { DateService } from '../../common/date/date.service';
import { BullMqService } from '../../common/queues/bullmq.service';

const ADDIS_ABABA_TIMEZONE = 'Africa/Addis_Ababa';

@Injectable()
export class ReminderScheduler {
  private readonly logger = new Logger(ReminderScheduler.name);

  constructor(
    private readonly bullMqService: BullMqService,
    private readonly dateService: DateService,
  ) {}

  @Cron('0 9 * * *', {
    timeZone: ADDIS_ABABA_TIMEZONE,
  })
  async enqueueDailyReminderScan(): Promise<void> {
    const now = new Date();
    const dateKey = this.dateService.dateKey(now, ADDIS_ABABA_TIMEZONE);

    const enqueued = await this.bullMqService.enqueueReminderScan(
      {
        triggeredAtIso: now.toISOString(),
      },
      {
        jobId: `reminder-scan:${dateKey}`,
      },
    );

    if (!enqueued) {
      this.logger.warn(
        'Reminder scan queue is unavailable; scan job not queued',
      );
    }
  }
}
