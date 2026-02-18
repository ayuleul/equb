import { Module } from '@nestjs/common';

import { AuditModule } from '../../common/audit/audit.module';
import { NotificationsModule } from '../notifications/notifications.module';
import { ContributionsController } from './contributions.controller';
import { ContributionsService } from './contributions.service';

@Module({
  imports: [AuditModule, NotificationsModule],
  controllers: [ContributionsController],
  providers: [ContributionsService],
  exports: [ContributionsService],
})
export class ContributionsModule {}
