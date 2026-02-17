import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';

import { AuditModule } from '../../common/audit/audit.module';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { SMS_PROVIDER } from './interfaces/sms-provider.interface';
import { DevSmsProvider } from './providers/dev-sms.provider';
import { JwtStrategy } from './strategies/jwt.strategy';

@Module({
  imports: [
    PassportModule.register({ defaultStrategy: 'jwt' }),
    JwtModule,
    AuditModule,
  ],
  controllers: [AuthController],
  providers: [
    AuthService,
    JwtStrategy,
    {
      provide: SMS_PROVIDER,
      useClass: DevSmsProvider,
    },
  ],
  exports: [AuthService],
})
export class AuthModule {}
