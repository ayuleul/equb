import { Module } from '@nestjs/common';

import { AuditModule } from '../../common/audit/audit.module';
import { RoundEligibilityService } from '../../common/cycles/round-eligibility.service';
import { WinnerSelectionService } from '../../common/cycles/winner-selection.service';
import { GroupsModule } from '../groups/groups.module';
import { NotificationsModule } from '../notifications/notifications.module';
import { RealtimeModule } from '../realtime/realtime.module';
import { PayoutsController } from './payouts.controller';
import { PayoutsService } from './payouts.service';

@Module({
  imports: [AuditModule, NotificationsModule, GroupsModule, RealtimeModule],
  controllers: [PayoutsController],
  providers: [PayoutsService, RoundEligibilityService, WinnerSelectionService],
  exports: [PayoutsService],
})
export class PayoutsModule {}
