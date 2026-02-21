import {
  BadRequestException,
  Inject,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Prisma, User } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { randomInt, randomUUID } from 'crypto';
import { StringValue } from 'ms';

import { AuditService } from '../../common/audit/audit.service';
import { isProfileComplete } from '../../common/profile/profile.utils';
import { PrismaService } from '../../common/prisma/prisma.service';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { RequestOtpDto } from './dto/request-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { SMS_PROVIDER } from './interfaces/sms-provider.interface';
import type { SmsProvider } from './interfaces/sms-provider.interface';

interface TokenPair {
  accessToken: string;
  refreshToken: string;
}

interface AuthUserPayload {
  id: string;
  phone: string;
  firstName: string | null;
  middleName: string | null;
  lastName: string | null;
  fullName: string | null;
  profileComplete: boolean;
}

interface RefreshTokenPayload {
  sub: string;
  tokenId: string;
  type: 'refresh';
}

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly auditService: AuditService,
    @Inject(SMS_PROVIDER) private readonly smsProvider: SmsProvider,
  ) {}

  async requestOtp({ phone }: RequestOtpDto): Promise<{ message: string }> {
    const normalizedPhone = this.normalizePhone(phone);
    const otpCode = this.generateOtpCode();
    const codeHash = await bcrypt.hash(otpCode, 10);
    const expiresAt = new Date(Date.now() + this.otpTtlSeconds * 1_000);

    await this.prisma.$transaction(async (tx) => {
      await tx.otpCode.deleteMany({ where: { phone: normalizedPhone } });
      await tx.otpCode.create({
        data: {
          phone: normalizedPhone,
          codeHash,
          expiresAt,
        },
      });
    });

    await this.smsProvider.sendOtp(normalizedPhone, otpCode);
    await this.auditService.log('AUTH_REQUEST_OTP', null, {
      phone: normalizedPhone,
    });

    return { message: 'OTP sent' };
  }

  async verifyOtp(
    dto: VerifyOtpDto,
  ): Promise<TokenPair & { user: AuthUserPayload }> {
    const normalizedPhone = this.normalizePhone(dto.phone);

    const otpRecord = await this.prisma.otpCode.findFirst({
      where: { phone: normalizedPhone },
      orderBy: { createdAt: 'desc' },
    });

    if (!otpRecord) {
      throw new UnauthorizedException('OTP not found');
    }

    if (otpRecord.expiresAt < new Date()) {
      await this.prisma.otpCode.delete({ where: { id: otpRecord.id } });
      throw new UnauthorizedException('OTP expired');
    }

    if (otpRecord.attempts >= this.otpMaxAttempts) {
      throw new UnauthorizedException('OTP attempts exceeded');
    }

    const isValidOtp = await bcrypt.compare(dto.code, otpRecord.codeHash);

    if (!isValidOtp) {
      await this.prisma.otpCode.update({
        where: { id: otpRecord.id },
        data: { attempts: { increment: 1 } },
      });
      await this.auditService.log('AUTH_VERIFY_OTP_FAILED', null, {
        phone: normalizedPhone,
      });
      throw new UnauthorizedException('Invalid OTP');
    }

    const user = await this.prisma.$transaction(async (tx) => {
      await tx.otpCode.deleteMany({ where: { phone: normalizedPhone } });
      return tx.user.upsert({
        where: { phone: normalizedPhone },
        update: {},
        create: { phone: normalizedPhone },
      });
    });

    const tokens = await this.issueTokenPair(this.prisma, user);
    await this.auditService.log('AUTH_VERIFY_OTP_SUCCESS', user.id, {
      phone: normalizedPhone,
    });

    return {
      ...tokens,
      user: this.toAuthUser(user),
    };
  }

  async refresh({
    refreshToken,
  }: RefreshTokenDto): Promise<TokenPair & { user: AuthUserPayload }> {
    const parsedToken = await this.verifyRefreshToken(refreshToken);
    const existingToken = await this.prisma.refreshToken.findUnique({
      where: { id: parsedToken.tokenId },
      include: { user: true },
    });

    if (!existingToken) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    if (existingToken.revokedAt || existingToken.expiresAt < new Date()) {
      throw new UnauthorizedException('Refresh token is no longer valid');
    }

    const isTokenValid = await bcrypt.compare(
      refreshToken,
      existingToken.tokenHash,
    );

    if (!isTokenValid || existingToken.userId !== parsedToken.sub) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    const tokens = await this.prisma.$transaction(async (tx) => {
      const revokeResult = await tx.refreshToken.updateMany({
        where: {
          id: existingToken.id,
          revokedAt: null,
        },
        data: {
          revokedAt: new Date(),
        },
      });

      if (revokeResult.count === 0) {
        throw new UnauthorizedException('Refresh token already rotated');
      }

      return this.issueTokenPair(tx, existingToken.user);
    });

    await this.auditService.log('AUTH_REFRESH_SUCCESS', existingToken.user.id, {
      refreshTokenId: existingToken.id,
    });

    return {
      ...tokens,
      user: this.toAuthUser(existingToken.user),
    };
  }

  async logout({
    refreshToken,
  }: RefreshTokenDto): Promise<{ success: boolean }> {
    const parsedToken = await this.verifyRefreshToken(refreshToken).catch(
      () => null,
    );

    if (!parsedToken) {
      return { success: true };
    }

    const existingToken = await this.prisma.refreshToken.findUnique({
      where: { id: parsedToken.tokenId },
    });

    if (!existingToken) {
      return { success: true };
    }

    const isTokenValid = await bcrypt.compare(
      refreshToken,
      existingToken.tokenHash,
    );

    if (
      isTokenValid &&
      !existingToken.revokedAt &&
      existingToken.userId === parsedToken.sub
    ) {
      await this.prisma.refreshToken.update({
        where: { id: existingToken.id },
        data: { revokedAt: new Date() },
      });

      await this.auditService.log('AUTH_LOGOUT', existingToken.userId, {
        refreshTokenId: existingToken.id,
      });
    }

    return { success: true };
  }

  private async issueTokenPair(
    client: Prisma.TransactionClient | PrismaService,
    user: Pick<User, 'id' | 'phone'>,
  ): Promise<TokenPair> {
    const accessTokenTtl =
      this.configService.get<number | StringValue>('JWT_ACCESS_TTL') ?? '15m';

    const accessToken = await this.jwtService.signAsync(
      { sub: user.id, phone: user.phone },
      {
        secret:
          this.configService.get<string>('JWT_ACCESS_SECRET') ??
          'change-me-access-secret',
        expiresIn: accessTokenTtl,
      },
    );

    const refreshTokenId = randomUUID();
    const refreshTokenExpiresIn = `${this.refreshTokenTtlDays}d` as StringValue;

    const refreshToken = await this.jwtService.signAsync(
      {
        sub: user.id,
        tokenId: refreshTokenId,
        type: 'refresh',
      } satisfies RefreshTokenPayload,
      {
        secret:
          this.configService.get<string>('JWT_REFRESH_SECRET') ??
          'change-me-refresh-secret',
        expiresIn: refreshTokenExpiresIn,
      },
    );

    const tokenHash = await bcrypt.hash(refreshToken, 10);
    const refreshTokenExpiresAt = new Date(
      Date.now() + this.refreshTokenTtlDays * 24 * 60 * 60 * 1_000,
    );

    await client.refreshToken.create({
      data: {
        id: refreshTokenId,
        userId: user.id,
        tokenHash,
        expiresAt: refreshTokenExpiresAt,
      },
    });

    return {
      accessToken,
      refreshToken,
    };
  }

  private normalizePhone(phone: string): string {
    const normalizedPhone = phone.trim();

    if (!normalizedPhone) {
      throw new BadRequestException('Phone is required');
    }

    return normalizedPhone;
  }

  private generateOtpCode(): string {
    return String(randomInt(100_000, 1_000_000));
  }

  private async verifyRefreshToken(
    refreshToken: string,
  ): Promise<RefreshTokenPayload> {
    try {
      const payload = await this.jwtService.verifyAsync<RefreshTokenPayload>(
        refreshToken,
        {
          secret:
            this.configService.get<string>('JWT_REFRESH_SECRET') ??
            'change-me-refresh-secret',
        },
      );

      if (payload.type !== 'refresh' || !payload.tokenId || !payload.sub) {
        throw new UnauthorizedException('Malformed refresh token');
      }

      return payload;
    } catch {
      throw new UnauthorizedException('Malformed refresh token');
    }
  }

  private get otpTtlSeconds(): number {
    return Number(this.configService.get<string>('OTP_TTL_SECONDS') ?? '300');
  }

  private get otpMaxAttempts(): number {
    return Number(this.configService.get<string>('OTP_MAX_ATTEMPTS') ?? '5');
  }

  private get refreshTokenTtlDays(): number {
    return Number(
      this.configService.get<string>('JWT_REFRESH_TTL_DAYS') ?? '30',
    );
  }

  private toAuthUser(
    user: Pick<
      User,
      'id' | 'phone' | 'firstName' | 'middleName' | 'lastName' | 'fullName'
    >,
  ): AuthUserPayload {
    return {
      id: user.id,
      phone: user.phone,
      firstName: user.firstName,
      middleName: user.middleName,
      lastName: user.lastName,
      fullName: user.fullName,
      profileComplete: isProfileComplete(user),
    };
  }
}
