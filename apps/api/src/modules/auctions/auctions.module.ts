import { Module } from '@nestjs/common';

import { AuditModule } from '../../common/audit/audit.module';
import { AuctionsController } from './auctions.controller';
import { AuctionsService } from './auctions.service';

@Module({
  imports: [AuditModule],
  controllers: [AuctionsController],
  providers: [AuctionsService],
})
export class AuctionsModule {}
