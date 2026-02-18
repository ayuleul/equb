import { Module } from '@nestjs/common';

import { AuditModule } from '../../common/audit/audit.module';
import { DateService } from '../../common/date/date.service';
import { NotificationsModule } from '../notifications/notifications.module';
import { GroupsController } from './groups.controller';
import { GroupsService } from './groups.service';

@Module({
  imports: [AuditModule, NotificationsModule],
  controllers: [GroupsController],
  providers: [GroupsService, DateService],
  exports: [GroupsService],
})
export class GroupsModule {}
