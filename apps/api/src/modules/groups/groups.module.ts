import { Module } from '@nestjs/common';

import { AuditModule } from '../../common/audit/audit.module';
import { DateService } from '../../common/date/date.service';
import { GroupsController } from './groups.controller';
import { GroupsService } from './groups.service';

@Module({
  imports: [AuditModule],
  controllers: [GroupsController],
  providers: [GroupsService, DateService],
  exports: [GroupsService],
})
export class GroupsModule {}
