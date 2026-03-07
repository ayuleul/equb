import { Module } from '@nestjs/common';

import { AuditModule } from '../../common/audit/audit.module';
import { WinnerSelectionService } from '../../common/cycles/winner-selection.service';
import { GroupsModule } from '../groups/groups.module';
import { NotificationsModule } from '../notifications/notifications.module';
import { PayoutsController } from './payouts.controller';
import { PayoutsService } from './payouts.service';

@Module({
  imports: [AuditModule, NotificationsModule, GroupsModule],
  controllers: [PayoutsController],
  providers: [PayoutsService, WinnerSelectionService],
  exports: [PayoutsService],
})
export class PayoutsModule {}
