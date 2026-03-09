import { Module } from '@nestjs/common';

import { AuditModule } from '../../common/audit/audit.module';
import { RoundEligibilityService } from '../../common/cycles/round-eligibility.service';
import { WinnerSelectionService } from '../../common/cycles/winner-selection.service';
import { DateService } from '../../common/date/date.service';
import { NotificationsModule } from '../notifications/notifications.module';
import { GroupsController } from './groups.controller';
import { GroupsService } from './groups.service';

@Module({
  imports: [AuditModule, NotificationsModule],
  controllers: [GroupsController],
  providers: [
    GroupsService,
    DateService,
    RoundEligibilityService,
    WinnerSelectionService,
  ],
  exports: [GroupsService],
})
export class GroupsModule {}
