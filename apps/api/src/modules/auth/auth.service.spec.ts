import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Test, TestingModule } from '@nestjs/testing';
import * as bcrypt from 'bcrypt';

import { AuditService } from '../../common/audit/audit.service';
import { PrismaService } from '../../common/prisma/prisma.service';
import { AuthService } from './auth.service';
import { SMS_PROVIDER } from './interfaces/sms-provider.interface';

describe('AuthService', () => {
  let service: AuthService;

  const otpCreate = jest.fn();
  const otpDeleteMany = jest.fn();
  const prismaMock = {
    otpCode: {
      create: otpCreate,
      deleteMany: otpDeleteMany,
    },
    $transaction: async <T>(callback: (tx: typeof prismaMock) => Promise<T>) =>
      callback(prismaMock),
  } as unknown as PrismaService;

  const smsProviderMock = {
    sendOtp: jest.fn(),
  };

  const auditServiceMock = {
    log: jest.fn(),
  };

  const configServiceMock = {
    get: (key: string): string | undefined => {
      const values: Record<string, string> = {
        OTP_TTL_SECONDS: '300',
      };
      return values[key];
    },
  };

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        JwtService,
        {
          provide: PrismaService,
          useValue: prismaMock,
        },
        {
          provide: ConfigService,
          useValue: configServiceMock,
        },
        {
          provide: AuditService,
          useValue: auditServiceMock,
        },
        {
          provide: SMS_PROVIDER,
          useValue: smsProviderMock,
        },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
  });

  it('hashes OTP before persisting and sends it via SMS provider', async () => {
    await service.requestOtp({ phone: '+251911223344' });

    expect(otpDeleteMany).toHaveBeenCalledWith({
      where: { phone: '+251911223344' },
    });

    expect(otpCreate).toHaveBeenCalledTimes(1);
    const createCall = otpCreate.mock.calls[0] as [
      {
        data: { codeHash: string };
      },
    ];
    const createPayload = createCall[0] as {
      data: { codeHash: string };
    };

    expect(smsProviderMock.sendOtp).toHaveBeenCalledTimes(1);
    const smsCall = smsProviderMock.sendOtp.mock.calls[0] as [string, string];
    const sentOtp = smsCall[1];

    expect(createPayload.data.codeHash).not.toBe(sentOtp);
    await expect(
      bcrypt.compare(sentOtp, createPayload.data.codeHash),
    ).resolves.toBe(true);
  });
});
