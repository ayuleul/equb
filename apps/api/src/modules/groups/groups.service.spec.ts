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
  const reputationService = {
    assertCanHostPublicGroup: jest.fn(),
    assertCanCreatePublicEqub: jest.fn(),
    assertCanJoinHighValuePublicGroup: jest.fn(),
    applyEvent: jest.fn(),
    getReliabilitySummaries: jest.fn().mockResolvedValue(new Map()),
    getHostSummary: jest.fn(),
    getGroupTrustSummary: jest.fn(),
  };
  const realtimeService = { emitGroupEvent: jest.fn() };
  const discoverMetricsService = { refreshMetricsForGroups: jest.fn() };

  const createService = (overrides?: Record<string, unknown>) => {
    const prisma = {
      $transaction: jest.fn(async (callback: (tx: any) => unknown) =>
        callback(prisma),
      ),
      equbGroup: {
        findUnique: jest.fn(),
        findMany: jest.fn(),
        create: jest.fn(),
        count: jest.fn(),
        update: jest.fn(),
      },
      groupRules: {
        create: jest.fn(),
        upsert: jest.fn(),
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
      reputationService as never,
      realtimeService as never,
      discoverMetricsService as never,
    );

    return { service, prisma };
  };

  beforeEach(() => {
    jest.clearAllMocks();
    reputationService.assertCanCreatePublicEqub.mockResolvedValue({
      trustScore: 50,
      trustLevel: 'New',
      hostTier: 'starter',
      allowedPublicEqubLimits: {
        maxMembers: 10,
        maxContributionAmount: 1000,
        maxDurationDays: 30,
        maxActivePublicEqubs: 1,
      },
    });
    reputationService.getReliabilitySummaries.mockResolvedValue(new Map());
    reputationService.getHostSummary.mockResolvedValue({
      userId: 'user-1',
      trustScore: 50,
      trustLevel: 'New',
      summaryLabel: null,
      level: null,
      icon: null,
      displayLabel: null,
      hostTitle: null,
      equbsHosted: 0,
      hostedEqubsCompleted: 0,
      turnsParticipated: 0,
      hostedCompletionRate: null,
      cancelledGroupsCount: 0,
      hostDisputesCount: 0,
    });
    reputationService.getGroupTrustSummary.mockResolvedValue({
      groupId: 'group-1',
      hostScore: 50,
      averageMemberScore: 50,
      verifiedMembersPercent: null,
      groupTrustLevel: 'Medium',
      host: {
        userId: 'user-1',
        trustScore: 50,
        trustLevel: 'New',
        summaryLabel: null,
        level: null,
        icon: null,
        displayLabel: null,
        hostTitle: null,
        equbsHosted: 0,
        hostedEqubsCompleted: 0,
        turnsParticipated: 0,
        hostedCompletionRate: null,
        cancelledGroupsCount: 0,
        hostDisputesCount: 0,
      },
    });
    discoverMetricsService.refreshMetricsForGroups.mockResolvedValue(undefined);
  });

  it('allows a new user to create a starter public Equb', async () => {
    const { service, prisma } = createService();
    jest.spyOn(service, 'getGroupDetails').mockResolvedValue({
      id: 'group-1',
      name: 'Starter',
      description: null,
      currency: 'ETB',
      contributionAmount: 500,
      frequency: GroupFrequency.MONTHLY,
      startDate: new Date('2026-03-12T00:00:00.000Z'),
      status: GroupStatus.ACTIVE,
      visibility: GroupVisibility.PUBLIC,
      rulesetConfigured: false,
      canInviteMembers: false,
      canStartCycle: false,
      hostTier: 'starter',
      hostReputationAtCreation: 50,
      hostReputationLevel: 'New',
      createdByUserId: actor.id,
      createdAt: new Date('2026-03-12T00:00:00.000Z'),
      strictPayout: false,
      timezone: 'Africa/Addis_Ababa',
      membership: {
        role: MemberRole.ADMIN,
        status: MemberStatus.VERIFIED,
      },
      trustSummary: {} as never,
    } as never);
    prisma.equbGroup.create.mockResolvedValue({
      id: 'group-1',
      visibility: GroupVisibility.PUBLIC,
    });
    prisma.equbMember.create.mockResolvedValue({});
    prisma.equbGroup.count.mockResolvedValue(0);

    await service.createGroup(actor, {
      name: 'Starter',
      visibility: GroupVisibility.PUBLIC,
      contributionAmount: 500,
      frequency: GroupFrequency.MONTHLY,
      startDate: '2026-03-12',
    });

    expect(reputationService.assertCanCreatePublicEqub).toHaveBeenCalledWith(
      actor.id,
      expect.objectContaining({
        contributionAmount: 500,
      }),
    );
    expect(prisma.equbGroup.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          hostTier: 'starter',
          hostReputationAtCreation: 50,
        }),
      }),
    );
  });

  it('keeps a score-55 user limited to starter public Equb rules', async () => {
    const { service, prisma } = createService();
    reputationService.assertCanCreatePublicEqub.mockRejectedValue(
      new Error(
        'Your trust score allows only starter public Equbs with up to 10 members.',
      ),
    );
    prisma.equbGroup.findUnique.mockResolvedValue({
      id: 'group-1',
      frequency: GroupFrequency.MONTHLY,
      visibility: GroupVisibility.PUBLIC,
      createdByUserId: actor.id,
    });

    await expect(
      service.updateGroupRules(actor, 'group-1', {
        contributionAmount: 500,
        frequency: 'MONTHLY' as never,
        graceDays: 0,
        fineType: 'NONE' as never,
        fineAmount: 0,
        payoutMode: 'LOTTERY' as never,
        winnerSelectionTiming: 'BEFORE_COLLECTION' as never,
        paymentMethods: ['CASH_ACK'] as never,
        requiresMemberVerification: false,
        strictCollection: false,
        roundSize: 12,
        startPolicy: 'WHEN_FULL' as never,
      }),
    ).rejects.toThrow(
      'Your trust score allows only starter public Equbs with up to 10 members.',
    );
  });

  it('allows a score-65 user to create a standard public Equb', async () => {
    const { service, prisma } = createService();
    reputationService.assertCanCreatePublicEqub.mockResolvedValue({
      trustScore: 65,
      trustLevel: 'Reliable',
      hostTier: 'standard',
      allowedPublicEqubLimits: {
        maxMembers: null,
        maxContributionAmount: null,
        maxDurationDays: null,
        maxActivePublicEqubs: null,
      },
    });
    jest.spyOn(service, 'getGroupDetails').mockResolvedValue({} as never);
    prisma.equbGroup.create.mockResolvedValue({
      id: 'group-2',
      visibility: GroupVisibility.PUBLIC,
    });
    prisma.equbMember.create.mockResolvedValue({});
    prisma.equbGroup.count.mockResolvedValue(0);

    await service.createGroup(actor, {
      name: 'Standard',
      visibility: GroupVisibility.PUBLIC,
    });

    expect(prisma.equbGroup.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          hostTier: 'standard',
          hostReputationAtCreation: 65,
        }),
      }),
    );
  });

  it('allows a score-80 user to create a high value public Equb', async () => {
    const { service, prisma } = createService();
    reputationService.assertCanCreatePublicEqub.mockResolvedValue({
      trustScore: 80,
      trustLevel: 'Trusted',
      hostTier: 'high_value',
      allowedPublicEqubLimits: {
        maxMembers: null,
        maxContributionAmount: null,
        maxDurationDays: null,
        maxActivePublicEqubs: null,
      },
    });
    jest.spyOn(service, 'getGroupDetails').mockResolvedValue({} as never);
    prisma.equbGroup.create.mockResolvedValue({
      id: 'group-3',
      visibility: GroupVisibility.PUBLIC,
    });
    prisma.equbMember.create.mockResolvedValue({});
    prisma.equbGroup.count.mockResolvedValue(0);

    await service.createGroup(actor, {
      name: 'High Value',
      visibility: GroupVisibility.PUBLIC,
    });

    expect(prisma.equbGroup.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          hostTier: 'high_value',
          hostReputationAtCreation: 80,
        }),
      }),
    );
  });

  it('rejects public starter hosts when starter limits are exceeded', async () => {
    const { service, prisma } = createService();
    reputationService.assertCanCreatePublicEqub.mockRejectedValue(
      new Error(
        'Your trust score allows only starter public Equbs with up to 10 members.',
      ),
    );
    prisma.equbGroup.count.mockResolvedValue(0);

    await expect(
      service.createGroup(actor, {
        name: 'Too Large',
        visibility: GroupVisibility.PUBLIC,
      }),
    ).rejects.toThrow(
      'Your trust score allows only starter public Equbs with up to 10 members.',
    );
  });

  it('keeps private Equb creation unaffected by hosting tiers', async () => {
    const { service, prisma } = createService();
    jest.spyOn(service, 'getGroupDetails').mockResolvedValue({} as never);
    prisma.equbGroup.create.mockResolvedValue({
      id: 'group-private',
      visibility: GroupVisibility.PRIVATE,
    });
    prisma.equbMember.create.mockResolvedValue({});

    await service.createGroup(actor, {
      name: 'Private',
      visibility: GroupVisibility.PRIVATE,
    });

    expect(reputationService.assertCanCreatePublicEqub).not.toHaveBeenCalled();
    expect(prisma.equbGroup.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          visibility: GroupVisibility.PRIVATE,
          hostTier: null,
          hostReputationAtCreation: null,
        }),
      }),
    );
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
    expect(reputationService.applyEvent).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({
        userId: 'user-2',
        eventType: 'MEMBER_JOINED',
      }),
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
        createdByUser: {
          id: 'user-1',
        },
      },
    ]);

    const result = await service.listPublicGroups(actor);

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
          createdByUserId: {
            not: actor.id,
          },
          joinRequests: {
            none: {
              userId: actor.id,
              status: {
                in: [JoinRequestStatus.REQUESTED, JoinRequestStatus.APPROVED],
              },
            },
          },
        }),
      }),
    );
  });
});
