import type { ExecutionContext } from '@nestjs/common';
import { MemberRole, MemberStatus } from '@prisma/client';

import type { PrismaService } from '../prisma/prisma.service';
import { GroupAdminGuard } from './group-admin.guard';
import { GroupMemberGuard } from './group-member.guard';

type RequestShape = {
  user?: { id: string; phone: string };
  params?: Record<string, string | undefined>;
  path: string;
};

function createExecutionContext(request: RequestShape): ExecutionContext {
  return {
    switchToHttp: () => ({
      getRequest: () => request,
    }),
  } as ExecutionContext;
}

describe('Group route param resolution', () => {
  const prismaMock = {
    equbCycle: {
      findUnique: jest.fn().mockResolvedValue({
        groupId: 'group-1',
      }),
    },
    equbMember: {
      findUnique: jest.fn().mockResolvedValue({
        role: MemberRole.ADMIN,
        status: MemberStatus.ACTIVE,
      }),
    },
  } as unknown as PrismaService;

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('GroupAdminGuard resolves turnId via cycle lookup', async () => {
    const guard = new GroupAdminGuard(prismaMock);

    await expect(
      guard.canActivate(
        createExecutionContext({
          user: { id: 'user-1', phone: '+251911111111' },
          params: { turnId: 'cycle-1' },
          path: '/turns/cycle-1/payout/send',
        }),
      ),
    ).resolves.toBe(true);

    expect(prismaMock.equbCycle.findUnique).toHaveBeenCalledWith({
      where: { id: 'cycle-1' },
      select: { groupId: true },
    });
    expect(prismaMock.equbMember.findUnique).toHaveBeenCalledWith({
      where: {
        groupId_userId: {
          groupId: 'group-1',
          userId: 'user-1',
        },
      },
      select: {
        status: true,
        role: true,
      },
    });
  });

  it('GroupMemberGuard resolves turnId via cycle lookup', async () => {
    const guard = new GroupMemberGuard(prismaMock);

    await expect(
      guard.canActivate(
        createExecutionContext({
          user: { id: 'user-2', phone: '+251922222222' },
          params: { turnId: 'cycle-1' },
          path: '/turns/cycle-1/payout/confirm-received',
        }),
      ),
    ).resolves.toBe(true);

    expect(prismaMock.equbCycle.findUnique).toHaveBeenCalledWith({
      where: { id: 'cycle-1' },
      select: { groupId: true },
    });
    expect(prismaMock.equbMember.findUnique).toHaveBeenCalledWith({
      where: {
        groupId_userId: {
          groupId: 'group-1',
          userId: 'user-2',
        },
      },
      select: {
        status: true,
      },
    });
  });
});
