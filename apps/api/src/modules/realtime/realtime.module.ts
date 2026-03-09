import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';

import {
  RealtimeAccessService,
  RealtimeGateway,
  RealtimeSocketAuthService,
  WsJwtAuthGuard,
} from './realtime.gateway';
import { RealtimeService } from './realtime.service';

@Module({
  imports: [JwtModule],
  providers: [
    RealtimeGateway,
    RealtimeService,
    RealtimeSocketAuthService,
    RealtimeAccessService,
    WsJwtAuthGuard,
  ],
  exports: [RealtimeService],
})
export class RealtimeModule {}
