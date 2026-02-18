import { Module } from '@nestjs/common';

import { AuditModule } from '../../common/audit/audit.module';
import { DateService } from '../../common/date/date.service';
import { NotificationsController } from './notifications.controller';
import { NotificationsService } from './notifications.service';
import { FCM_PROVIDER } from './interfaces/fcm-provider.interface';
import { ReminderScheduler } from './reminder.scheduler';
import { NotificationProcessor } from './processors/notification.processor';
import { ReminderProcessor } from './processors/reminder.processor';
import { EnvFcmProvider } from './providers/env-fcm.provider';

@Module({
  imports: [AuditModule],
  controllers: [NotificationsController],
  providers: [
    NotificationsService,
    DateService,
    ReminderScheduler,
    NotificationProcessor,
    ReminderProcessor,
    {
      provide: FCM_PROVIDER,
      useClass: EnvFcmProvider,
    },
  ],
  exports: [NotificationsService],
})
export class NotificationsModule {}
