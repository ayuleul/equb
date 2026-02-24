import { BadRequestException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import {
  ContributionStatus,
  CycleState,
  CycleStatus,
  GroupFrequency,
  GroupStatus,
  MemberRole,
  MemberStatus,
  PayoutStatus,
} from '@prisma/client';

import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/common/prisma/prisma.service';
import type { AuthenticatedUser } from '../src/common/types/authenticated-user.type';
import { PayoutsController } from '../src/modules/payouts/payouts.controller';

type UserRecord = {
  id: string;
  fullName: string | null;
  phone: string;
};

type GroupRecord = {
  id: string;
  contributionAmount: number;
  strictPayout: boolean;
  frequency: GroupFrequency;
  status: GroupStatus;
};

type CycleRecord = {
  id: string;
  groupId: string;
  scheduledPayoutUserId: string;
  finalPayoutUserId: string;
  winningBidAmount: number | null;
  winningBidUserId: string | null;
  state: CycleState;
  status: CycleStatus;
  closedAt: Date | null;
  closedByUserId: string | null;
};

type MemberRecord = {
  groupId: string;
  userId: string;
  role: MemberRole;
  status: MemberStatus;
};

type ContributionRecord = {
  id: string;
  cycleId: string;
  userId: string;
  status: ContributionStatus;
};

type PayoutRecord = {
  id: string;
  groupId: string;
  cycleId: string;
  toUserId: string;
  amount: number;
  status: PayoutStatus;
  proofFileKey: string | null;
  paymentRef: string | null;
  note: string | null;
  metadata?: Record<string, unknown> | null;
  createdByUserId: string;
  createdAt: Date;
  confirmedByUserId: string | null;
  confirmedAt: Date | null;
};

describe('Payouts (e2e)', () => {
  let payoutsController: PayoutsController;

  const users: UserRecord[] = [
    {
      id: '00000000-0000-0000-0000-000000000011',
      fullName: 'Admin',
      phone: '+251911111111',
    },
    {
      id: '00000000-0000-0000-0000-000000000022',
      fullName: 'Member',
      phone: '+251922222222',
    },
  ];

  const groups: GroupRecord[] = [
    {
      id: '00000000-0000-0000-0000-000000000101',
      contributionAmount: 500,
      strictPayout: false,
      frequency: GroupFrequency.MONTHLY,
      status: GroupStatus.ACTIVE,
    },
  ];

  const cycles: CycleRecord[] = [
    {
      id: '00000000-0000-0000-0000-000000000201',
      groupId: '00000000-0000-0000-0000-000000000101',
      scheduledPayoutUserId: '00000000-0000-0000-0000-000000000011',
      finalPayoutUserId: '00000000-0000-0000-0000-000000000022',
      winningBidAmount: 250,
      winningBidUserId: '00000000-0000-0000-0000-000000000022',
      state: CycleState.DUE,
      status: CycleStatus.OPEN,
      closedAt: null,
      closedByUserId: null,
    },
  ];

  const members: MemberRecord[] = [
    {
      groupId: '00000000-0000-0000-0000-000000000101',
      userId: '00000000-0000-0000-0000-000000000011',
      role: MemberRole.ADMIN,
      status: MemberStatus.ACTIVE,
    },
    {
      groupId: '00000000-0000-0000-0000-000000000101',
      userId: '00000000-0000-0000-0000-000000000022',
      role: MemberRole.MEMBER,
      status: MemberStatus.ACTIVE,
    },
  ];

  const contributions: ContributionRecord[] = [];
  const payouts: PayoutRecord[] = [];

  const adminUser: AuthenticatedUser = {
    id: '00000000-0000-0000-0000-000000000011',
    phone: '+251911111111',
  };

  const prismaMock = {
    equbCycle: {
      findUnique: jest.fn(
        ({
          where,
          include,
        }: {
          where: { id: string };
          include?: {
            group?: { select: { contributionAmount: true } };
            payout?:
              | true
              | {
                  include: {
                    toUser: {
                      select: { id: true; fullName: true; phone: true };
                    };
                  };
                };
          };
        }) => {
          const cycle = cycles.find((item) => item.id === where.id) ?? null;

          if (!cycle) {
            return null;
          }

          if (include?.group) {
            const group = groups.find((item) => item.id === cycle.groupId);
            return {
              ...cycle,
              group: {
                contributionAmount: group?.contributionAmount ?? 0,
              },
            };
          }

          if (include?.payout) {
            const payout = payouts.find((item) => item.cycleId === cycle.id);

            if (include.payout === true) {
              return {
                ...cycle,
                payout: payout ?? null,
              };
            }

            return {
              ...cycle,
              payout: payout
                ? {
                    ...payout,
                    toUser: users.find((item) => item.id === payout.toUserId),
                  }
                : null,
            };
          }

          return cycle;
        },
      ),
      update: jest.fn(
        ({
          where,
          data,
        }: {
          where: { id: string };
          data: Partial<{
            status: CycleStatus;
            state: CycleState;
            closedAt: Date;
            closedByUserId: string;
          }>;
        }) => {
          const cycle = cycles.find((item) => item.id === where.id);
          if (!cycle) {
            throw new Error('Cycle not found');
          }

          if (data.status !== undefined) {
            cycle.status = data.status;
          }
          if (data.state !== undefined) {
            cycle.state = data.state;
          }
          if (data.closedAt !== undefined) {
            cycle.closedAt = data.closedAt;
          }
          if (data.closedByUserId !== undefined) {
            cycle.closedByUserId = data.closedByUserId;
          }

          return cycle;
        },
      ),
    },
    payout: {
      findUnique: jest.fn(
        ({
          where,
          select,
          include,
        }: {
          where: { id?: string; cycleId?: string };
          select?: { id: true };
          include?: {
            toUser?: {
              select: { id: true; fullName: true; phone: true };
            };
            cycle?: {
              select: { id: true; groupId: true; status: true };
            };
            group?: {
              select: { strictPayout: true };
            };
          };
        }) => {
          const payout = payouts.find((item) =>
            where.id ? item.id === where.id : item.cycleId === where.cycleId,
          );

          if (!payout) {
            return null;
          }

          if (select?.id) {
            return {
              id: payout.id,
            };
          }

          if (include) {
            return {
              ...payout,
              ...(include.toUser
                ? {
                    toUser: users.find((item) => item.id === payout.toUserId),
                  }
                : {}),
              ...(include.cycle
                ? {
                    cycle: cycles.find((item) => item.id === payout.cycleId),
                  }
                : {}),
              ...(include.group
                ? {
                    group: groups.find((item) => item.id === payout.groupId),
                  }
                : {}),
            };
          }

          return payout;
        },
      ),
      create: jest.fn(
        ({
          data,
          include,
        }: {
          data: {
            groupId: string;
            cycleId: string;
            toUserId: string;
            amount: number;
            status: PayoutStatus;
            proofFileKey: string | null;
            paymentRef: string | null;
            note: string | null;
            metadata?: Record<string, unknown> | null;
            createdByUserId: string;
          };
          include?: {
            toUser?: {
              select: { id: true; fullName: true; phone: true };
            };
          };
        }) => {
          const payout: PayoutRecord = {
            id: `payout_${payouts.length + 1}`,
            ...data,
            createdAt: new Date(),
            confirmedByUserId: null,
            confirmedAt: null,
          };

          payouts.push(payout);

          if (include?.toUser) {
            return {
              ...payout,
              toUser: users.find((item) => item.id === payout.toUserId),
            };
          }

          return payout;
        },
      ),
      update: jest.fn(
        ({
          where,
          data,
          include,
        }: {
          where: { id: string };
          data: Partial<PayoutRecord>;
          include?: {
            toUser?: {
              select: { id: true; fullName: true; phone: true };
            };
          };
        }) => {
          const payout = payouts.find((item) => item.id === where.id);
          if (!payout) {
            throw new Error('Payout not found');
          }

          Object.assign(payout, data);

          if (include?.toUser) {
            return {
              ...payout,
              toUser: users.find((item) => item.id === payout.toUserId),
            };
          }

          return payout;
        },
      ),
    },
    equbMember: {
      findMany: jest.fn(
        ({
          where,
          select,
        }: {
          where: { groupId: string; status: MemberStatus | { in: MemberStatus[] } };
          select: { userId: true };
        }) => {
          const allowedStatuses =
            typeof where.status === 'object' && where.status != null && 'in' in where.status
              ? where.status.in
              : [where.status as MemberStatus];
          return members
            .filter(
              (item) =>
                item.groupId === where.groupId &&
                allowedStatuses.includes(item.status),
            )
            .map((item) => ({
              ...(select.userId ? { userId: item.userId } : {}),
            }));
        },
      ),
    },
    contribution: {
      findMany: jest.fn(
        ({
          where,
          select,
        }: {
          where: {
            cycleId: string;
            status:
              | ContributionStatus
              | {
                  in: ContributionStatus[];
                };
          };
          select: { userId: true };
        }) => {
          const allowedStatuses =
            typeof where.status === 'object' && where.status != null && 'in' in where.status
              ? where.status.in
              : [where.status as ContributionStatus];
          return contributions
            .filter(
              (item) =>
                item.cycleId === where.cycleId &&
                allowedStatuses.includes(item.status),
            )
            .map((item) => ({
              ...(select.userId ? { userId: item.userId } : {}),
            }));
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

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(PrismaService)
      .useValue(prismaMock)
      .compile();

    payoutsController = moduleFixture.get<PayoutsController>(PayoutsController);
  });

  beforeEach(() => {
    payouts.splice(0, payouts.length);
    contributions.splice(0, contributions.length);
    groups[0].strictPayout = false;
    cycles[0].scheduledPayoutUserId = '00000000-0000-0000-0000-000000000011';
    cycles[0].finalPayoutUserId = '00000000-0000-0000-0000-000000000022';
    cycles[0].winningBidAmount = 250;
    cycles[0].winningBidUserId = '00000000-0000-0000-0000-000000000022';
    cycles[0].state = CycleState.DUE;
    cycles[0].status = CycleStatus.OPEN;
    cycles[0].closedAt = null;
    cycles[0].closedByUserId = null;
    jest.clearAllMocks();
  });

  it('admin creates payout for final recipient, confirms payout in non-strict mode, then closes cycle', async () => {
    const created = await payoutsController.createPayout(
      adminUser,
      '00000000-0000-0000-0000-000000000201',
      {
        proofFileKey:
          'groups/00000000-0000-0000-0000-000000000101/cycles/00000000-0000-0000-0000-000000000201/payouts/uuid_proof.jpg',
      },
    );

    expect(created.status).toBe(PayoutStatus.PENDING);
    expect(created.toUserId).toBe('00000000-0000-0000-0000-000000000022');

    const confirmed = await payoutsController.confirmPayout(
      adminUser,
      created.id,
      {
        paymentRef: 'tx-001',
      },
    );

    expect(confirmed.status).toBe(PayoutStatus.CONFIRMED);
    expect(confirmed.confirmedAt).not.toBeNull();

    const closed = await payoutsController.closeCycle(
      adminUser,
      '00000000-0000-0000-0000-000000000201',
      {},
    );

    expect(closed).toEqual({
      success: true,
      nextCycleId: null,
      nextCycle: null,
    });
    expect(cycles[0].status).toBe(CycleStatus.CLOSED);
  });

  it('strict payout mode blocks confirmation when confirmed contributions are missing', async () => {
    groups[0].strictPayout = true;

    const created = await payoutsController.createPayout(
      adminUser,
      '00000000-0000-0000-0000-000000000201',
      {},
    );

    await expect(
      payoutsController.confirmPayout(adminUser, created.id, {}),
    ).rejects.toThrow(BadRequestException);
  });
});
