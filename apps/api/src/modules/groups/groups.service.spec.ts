import {
  CycleStatus,
  GroupFrequency,
  GroupStatus,
  GroupVisibility,
  JoinRequestStatus,
  MemberRole,
  MemberStatus,
} from '@prisma/client';

import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import { GroupsService } from './groups.service';
import {
  GROUP_JOIN_REQUEST_COOLDOWN_MESSAGE,
  GROUP_JOIN_REQUESTS_BLOCKED_MESSAGE,
} from './groups.constants';

describe('GroupsService', () => {
  const actor: AuthenticatedUser = {
    id: 'user-1',
    phone: '+251911111111',
  };

  const auditService = { log: jest.fn() };
  const configService = { get: jest.fn() };
  const dateService = {
    normalizeGroupDate: jest.fn((date: Date) => date),
  };
  const notificationsService = { notifyGroupAdmins: jest.fn() };
  const roundEligibilityService = {};
  const winnerSelectionService = {};
  const realtimeService = { emitGroupEvent: jest.fn() };

  const createService = (overrides?: Record<string, unknown>) => {
    const prisma = {
      $transaction: jest.fn(async (callback: (tx: any) => unknown) =>
        callback(prisma),
      ),
      equbGroup: {
        findUnique: jest.fn(),
        findMany: jest.fn(),
      },
      equbCycle: {
        findFirst: jest.fn(),
      },
      equbMember: {
        findUnique: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
      },
      joinRequest: {
        findFirst: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
        findMany: jest.fn(),
        count: jest.fn(),
      },
      ...(overrides ?? {}),
    };

    const service = new GroupsService(
      prisma as never,
      auditService as never,
      configService as never,
      dateService as never,
      notificationsService as never,
      roundEligibilityService as never,
      winnerSelectionService as never,
      realtimeService as never,
    );

    return { service, prisma };
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('creates a join request for a public group', async () => {
    const { service, prisma } = createService();

    prisma.equbGroup.findUnique.mockResolvedValue({
      id: 'group-1',
      visibility: GroupVisibility.PUBLIC,
    });
    prisma.equbCycle.findFirst.mockResolvedValue(null);
    prisma.equbMember.findUnique.mockResolvedValue(null);
    prisma.joinRequest.findFirst.mockResolvedValue(null);
    prisma.joinRequest.create.mockResolvedValue({
      id: 'request-1',
      groupId: 'group-1',
      userId: actor.id,
      status: JoinRequestStatus.REQUESTED,
      message: 'Please add me',
      createdAt: new Date('2026-03-11T09:00:00.000Z'),
      reviewedAt: null,
      reviewedByUserId: null,
      user: {
        id: actor.id,
        phone: actor.phone,
        fullName: 'Requester',
      },
    });

    const result = await service.createJoinRequest(actor, 'group-1', {
      message: 'Please add me',
    });

    expect(result.status).toBe(JoinRequestStatus.REQUESTED);
    expect(result.groupId).toBe('group-1');
    expect(prisma.joinRequest.create).toHaveBeenCalled();
    expect(auditService.log).toHaveBeenCalledWith(
      'GROUP_JOIN_REQUEST_CREATED',
      actor.id,
      expect.objectContaining({ joinRequestId: 'request-1' }),
      'group-1',
    );
  });

  it('blocks join requests while a cycle is open', async () => {
    const { service, prisma } = createService();

    prisma.equbGroup.findUnique.mockResolvedValue({
      id: 'group-1',
      visibility: GroupVisibility.PUBLIC,
    });
    prisma.equbCycle.findFirst.mockResolvedValue({
      id: 'cycle-1',
      status: CycleStatus.OPEN,
    });

    await expect(
      service.createJoinRequest(actor, 'group-1', {}),
    ).rejects.toMatchObject({
      response: expect.objectContaining({
        message: GROUP_JOIN_REQUESTS_BLOCKED_MESSAGE,
        reasonCode: 'GROUP_JOIN_REQUESTS_BLOCKED_ACTIVE_CYCLE',
      }),
    });
  });

  it('blocks a retry during the rejection cooldown window', async () => {
    const { service, prisma } = createService();

    prisma.equbGroup.findUnique.mockResolvedValue({
      id: 'group-1',
      visibility: GroupVisibility.PUBLIC,
    });
    prisma.equbCycle.findFirst.mockResolvedValue(null);
    prisma.equbMember.findUnique.mockResolvedValue(null);
    prisma.joinRequest.findFirst.mockResolvedValue(null);
    prisma.joinRequest.findFirst.mockResolvedValueOnce(null);
    prisma.joinRequest.findFirst.mockResolvedValueOnce({
      reviewedAt: new Date('2026-03-11T10:00:00.000Z'),
      createdAt: new Date('2026-03-11T09:00:00.000Z'),
    });

    await expect(
      service.createJoinRequest(actor, 'group-1', {}),
    ).rejects.toMatchObject({
      response: expect.objectContaining({
        message: GROUP_JOIN_REQUEST_COOLDOWN_MESSAGE,
        reasonCode: 'GROUP_JOIN_REQUEST_COOLDOWN',
      }),
    });
  });

  it('approves a join request and creates joined membership', async () => {
    const { service, prisma } = createService();

    prisma.joinRequest.findFirst.mockResolvedValue({
      id: 'request-1',
      groupId: 'group-1',
      userId: 'user-2',
      status: JoinRequestStatus.REQUESTED,
      message: 'Let me in',
      createdAt: new Date('2026-03-11T08:00:00.000Z'),
      reviewedAt: null,
      reviewedByUserId: null,
      user: {
        id: 'user-2',
        phone: '+251922222222',
        fullName: 'Joiner',
      },
    });
    prisma.equbCycle.findFirst.mockResolvedValue(null);
    prisma.equbMember.findUnique.mockResolvedValueOnce(null);
    prisma.equbMember.create.mockResolvedValue({
      id: 'member-1',
      groupId: 'group-1',
      userId: 'user-2',
      role: MemberRole.MEMBER,
      status: MemberStatus.JOINED,
      joinedAt: new Date('2026-03-11T10:00:00.000Z'),
    });
    prisma.joinRequest.update.mockResolvedValue({
      id: 'request-1',
      groupId: 'group-1',
      userId: 'user-2',
      status: JoinRequestStatus.APPROVED,
      message: 'Let me in',
      createdAt: new Date('2026-03-11T08:00:00.000Z'),
      reviewedAt: new Date('2026-03-11T10:00:00.000Z'),
      reviewedByUserId: actor.id,
      user: {
        id: 'user-2',
        phone: '+251922222222',
        fullName: 'Joiner',
      },
    });
    const result = await service.approveJoinRequest(
      actor,
      'group-1',
      'request-1',
    );

    expect(result.status).toBe(JoinRequestStatus.APPROVED);
    expect(prisma.equbMember.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          groupId: 'group-1',
          userId: 'user-2',
          status: MemberStatus.JOINED,
        }),
      }),
    );
    expect(auditService.log).toHaveBeenCalledWith(
      'GROUP_JOIN_REQUEST_APPROVED',
      actor.id,
      { joinRequestId: 'request-1' },
      'group-1',
    );
  });

  it('lists only public groups in discovery summaries', async () => {
    const { service, prisma } = createService();

    prisma.equbGroup.findMany.mockResolvedValue([
      {
        id: 'group-1',
        name: 'Open Equb',
        description: 'Public',
        currency: 'ETB',
        contributionAmount: 500,
        frequency: GroupFrequency.MONTHLY,
        status: GroupStatus.ACTIVE,
        visibility: GroupVisibility.PUBLIC,
        rules: null,
        _count: {
          members: 3,
          cycles: 1,
        },
      },
    ]);

    const result = await service.listPublicGroups();

    expect(result).toEqual([
      expect.objectContaining({
        id: 'group-1',
        name: 'Open Equb',
        memberCount: 3,
        alreadyStarted: true,
      }),
    ]);
    expect(prisma.equbGroup.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({
          visibility: GroupVisibility.PUBLIC,
          status: GroupStatus.ACTIVE,
        }),
      }),
    );
  });
});
