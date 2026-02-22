import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_GUARD } from '@nestjs/core';
import { ScheduleModule } from '@nestjs/schedule';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';

import { AuditModule } from './common/audit/audit.module';
import { PrismaModule } from './common/prisma/prisma.module';
import { BullMqModule } from './common/queues/bullmq.module';
import { AuthModule } from './modules/auth/auth.module';
import { AuctionsModule } from './modules/auctions/auctions.module';
import { ContributionsModule } from './modules/contributions/contributions.module';
import { FilesModule } from './modules/files/files.module';
import { GroupsModule } from './modules/groups/groups.module';
import { MeModule } from './modules/me/me.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { PayoutsModule } from './modules/payouts/payouts.module';
import { SystemModule } from './modules/system/system.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    ScheduleModule.forRoot(),
    ThrottlerModule.forRoot([
      {
        name: 'default',
        ttl: 60_000,
        limit: 60,
      },
      {
        name: 'otp',
        ttl: 60_000,
        limit: 5,
      },
    ]),
    PrismaModule,
    AuditModule,
    BullMqModule,
    NotificationsModule,
    SystemModule,
    AuthModule,
    AuctionsModule,
    MeModule,
    GroupsModule,
    FilesModule,
    ContributionsModule,
    PayoutsModule,
  ],
  providers: [
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
  ],
})
export class AppModule {}
