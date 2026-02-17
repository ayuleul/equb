import { Test, TestingModule } from '@nestjs/testing';

import { PrismaService } from '../src/common/prisma/prisma.service';
import { AuthController } from '../src/modules/auth/auth.controller';
import { SMS_PROVIDER } from '../src/modules/auth/interfaces/sms-provider.interface';
import { AppModule } from '../src/app.module';

type UserRecord = {
  id: string;
  phone: string;
  fullName: string | null;
  createdAt: Date;
};

type OtpRecord = {
  id: string;
  phone: string;
  codeHash: string;
  expiresAt: Date;
  attempts: number;
  createdAt: Date;
};

type RefreshTokenRecord = {
  id: string;
  userId: string;
  tokenHash: string;
  expiresAt: Date;
  revokedAt: Date | null;
  createdAt: Date;
};

class FakeSmsProvider {
  private readonly otpByPhone = new Map<string, string>();

  sendOtp(phone: string, code: string): Promise<void> {
    this.otpByPhone.set(phone, code);
    return Promise.resolve();
  }

  getCode(phone: string): string | undefined {
    return this.otpByPhone.get(phone);
  }

  reset(): void {
    this.otpByPhone.clear();
  }
}

describe('Auth (e2e)', () => {
  let authController: AuthController;

  const users: UserRecord[] = [];
  const otpCodes: OtpRecord[] = [];
  const refreshTokens: RefreshTokenRecord[] = [];

  const prismaMock = {
    otpCode: {
      deleteMany: jest.fn(({ where }: { where: { phone?: string } }) => {
        if (!where.phone) {
          otpCodes.splice(0, otpCodes.length);
          return { count: 0 };
        }

        const originalLength = otpCodes.length;
        for (let i = otpCodes.length - 1; i >= 0; i -= 1) {
          if (otpCodes[i].phone === where.phone) {
            otpCodes.splice(i, 1);
          }
        }

        return { count: originalLength - otpCodes.length };
      }),
      create: jest.fn(
        ({
          data,
        }: {
          data: {
            phone: string;
            codeHash: string;
            expiresAt: Date;
          };
        }) => {
          const record: OtpRecord = {
            id: `otp_${otpCodes.length + 1}`,
            phone: data.phone,
            codeHash: data.codeHash,
            expiresAt: data.expiresAt,
            attempts: 0,
            createdAt: new Date(),
          };
          otpCodes.push(record);
          return record;
        },
      ),
      findFirst: jest.fn(({ where }: { where: { phone: string } }) => {
        const match = otpCodes
          .filter((otp) => otp.phone === where.phone)
          .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime())[0];

        return match ?? null;
      }),
      update: jest.fn(
        ({
          where,
          data,
        }: {
          where: { id: string };
          data: { attempts: { increment: number } };
        }) => {
          const match = otpCodes.find((otp) => otp.id === where.id);
          if (!match) {
            throw new Error('OTP not found');
          }
          match.attempts += data.attempts.increment;
          return match;
        },
      ),
      delete: jest.fn(({ where }: { where: { id: string } }) => {
        const index = otpCodes.findIndex((otp) => otp.id === where.id);
        if (index >= 0) {
          const [deleted] = otpCodes.splice(index, 1);
          return deleted;
        }
        throw new Error('OTP not found');
      }),
    },
    user: {
      upsert: jest.fn(
        ({
          where,
          create,
        }: {
          where: { phone: string };
          create: { phone: string };
        }) => {
          const existingUser = users.find((user) => user.phone === where.phone);
          if (existingUser) {
            return existingUser;
          }

          const user: UserRecord = {
            id: `user_${users.length + 1}`,
            phone: create.phone,
            fullName: null,
            createdAt: new Date(),
          };
          users.push(user);
          return user;
        },
      ),
    },
    refreshToken: {
      create: jest.fn(
        ({
          data,
        }: {
          data: {
            id: string;
            userId: string;
            tokenHash: string;
            expiresAt: Date;
          };
        }) => {
          const token: RefreshTokenRecord = {
            id: data.id,
            userId: data.userId,
            tokenHash: data.tokenHash,
            expiresAt: data.expiresAt,
            revokedAt: null,
            createdAt: new Date(),
          };
          refreshTokens.push(token);
          return token;
        },
      ),
      findUnique: jest.fn(
        ({
          where,
          include,
        }: {
          where: { id: string };
          include?: { user?: boolean };
        }) => {
          const token = refreshTokens.find((item) => item.id === where.id);
          if (!token) {
            return null;
          }

          if (include?.user) {
            return {
              ...token,
              user: users.find((user) => user.id === token.userId) ?? null,
            };
          }

          return token;
        },
      ),
      updateMany: jest.fn(
        ({
          where,
          data,
        }: {
          where: { id: string; revokedAt: null };
          data: { revokedAt: Date };
        }) => {
          const token = refreshTokens.find(
            (item) =>
              item.id === where.id && item.revokedAt === where.revokedAt,
          );

          if (!token) {
            return { count: 0 };
          }

          token.revokedAt = data.revokedAt;
          return { count: 1 };
        },
      ),
      update: jest.fn(
        ({
          where,
          data,
        }: {
          where: { id: string };
          data: { revokedAt: Date };
        }) => {
          const token = refreshTokens.find((item) => item.id === where.id);
          if (!token) {
            throw new Error('Refresh token not found');
          }
          token.revokedAt = data.revokedAt;
          return token;
        },
      ),
    },
    auditLog: {
      create: jest.fn(() => ({ id: `audit_${Date.now()}` })),
    },
    $transaction: jest.fn(
      (
        arg:
          | ((tx: PrismaService) => Promise<unknown>)
          | Array<Promise<unknown>>,
      ) => {
        if (typeof arg === 'function') {
          return arg(prismaMock);
        }

        return Promise.all(arg);
      },
    ),
  } as unknown as PrismaService;

  const fakeSmsProvider = new FakeSmsProvider();

  beforeAll(async () => {
    process.env.JWT_ACCESS_SECRET = 'test-access-secret';
    process.env.JWT_REFRESH_SECRET = 'test-refresh-secret';
    process.env.JWT_ACCESS_TTL = '15m';
    process.env.JWT_REFRESH_TTL_DAYS = '30';
    process.env.OTP_TTL_SECONDS = '300';
    process.env.OTP_MAX_ATTEMPTS = '5';

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(PrismaService)
      .useValue(prismaMock)
      .overrideProvider(SMS_PROVIDER)
      .useValue(fakeSmsProvider)
      .compile();

    authController = moduleFixture.get<AuthController>(AuthController);
  });

  beforeEach(() => {
    users.splice(0, users.length);
    otpCodes.splice(0, otpCodes.length);
    refreshTokens.splice(0, refreshTokens.length);
    fakeSmsProvider.reset();
    jest.clearAllMocks();
  });

  it('request-otp + verify-otp happy path', async () => {
    const phone = '+251911223344';

    await expect(authController.requestOtp({ phone })).resolves.toEqual({
      message: 'OTP sent',
    });

    const otpCode = fakeSmsProvider.getCode(phone);
    expect(otpCode).toBeDefined();

    const response = await authController.verifyOtp({
      phone,
      code: otpCode as string,
    });

    expect(response).toHaveProperty('accessToken');
    expect(response).toHaveProperty('refreshToken');
    expect(response.user.phone).toBe(phone);
  });
});
