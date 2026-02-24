import { Test, TestingModule } from '@nestjs/testing';
import {
  ContributionStatus,
  CycleStatus,
  GroupFrequency,
  GroupStatus,
  MemberRole,
  MemberStatus,
} from '@prisma/client';

import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/common/prisma/prisma.service';
import type { AuthenticatedUser } from '../src/common/types/authenticated-user.type';
import { ContributionsController } from '../src/modules/contributions/contributions.controller';

type UserRecord = {
  id: string;
  fullName: string | null;
  phone: string;
};

type GroupRecord = {
  id: string;
  frequency: GroupFrequency;
  status: GroupStatus;
  contributionAmount: number;
};

type CycleRecord = {
  id: string;
  groupId: string;
  status: CycleStatus;
  contributionsSubmittedCount: number;
  contributionsConfirmedCount: number;
};

type MemberRecord = {
  groupId: string;
  userId: string;
  role: MemberRole;
  status: MemberStatus;
};

type ContributionRecord = {
  id: string;
  groupId: string;
  cycleId: string;
  userId: string;
  amount: number;
  status: ContributionStatus;
  proofFileKey: string | null;
  paymentRef: string | null;
  note: string | null;
  submittedAt: Date | null;
  confirmedByUserId: string | null;
  confirmedAt: Date | null;
  rejectedByUserId: string | null;
  rejectedAt: Date | null;
  rejectReason: string | null;
  createdAt: Date;
};

describe('Contributions (e2e)', () => {
  let contributionsController: ContributionsController;

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
      frequency: GroupFrequency.MONTHLY,
      status: GroupStatus.ACTIVE,
      contributionAmount: 500,
    },
  ];

  const cycles: CycleRecord[] = [
    {
      id: '00000000-0000-0000-0000-000000000201',
      groupId: '00000000-0000-0000-0000-000000000101',
      status: CycleStatus.OPEN,
      contributionsSubmittedCount: 0,
      contributionsConfirmedCount: 0,
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

  const adminUser: AuthenticatedUser = {
    id: '00000000-0000-0000-0000-000000000011',
    phone: '+251911111111',
  };

  const memberUser: AuthenticatedUser = {
    id: '00000000-0000-0000-0000-000000000022',
    phone: '+251922222222',
  };

  const prismaMock = {
    equbCycle: {
      findUnique: jest.fn(
        ({
          where,
          include,
          select,
        }: {
          where: { id: string };
          include?: {
            group?: { select: { id: true; contributionAmount: true } };
          };
          select?: { id: true; groupId: true };
        }) => {
          const cycle = cycles.find((item) => item.id === where.id) ?? null;
          if (!cycle) {
            return null;
          }

          if (include?.group) {
            const group =
              groups.find((item) => item.id === cycle.groupId) ?? null;
            return {
              ...cycle,
              group,
            };
          }

          if (select) {
            return {
              id: cycle.id,
              groupId: cycle.groupId,
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
          data: {
            contributionsSubmittedCount: number;
            contributionsConfirmedCount: number;
          };
        }) => {
          const cycle = cycles.find((item) => item.id === where.id);
          if (!cycle) {
            throw new Error('Cycle not found');
          }

          cycle.contributionsSubmittedCount = data.contributionsSubmittedCount;
          cycle.contributionsConfirmedCount = data.contributionsConfirmedCount;
          return cycle;
        },
      ),
    },
    equbMember: {
      findUnique: jest.fn(
        ({
          where,
          select,
        }: {
          where: { groupId_userId: { groupId: string; userId: string } };
          select?: { status?: boolean; role?: boolean };
        }) => {
          const member =
            members.find(
              (item) =>
                item.groupId === where.groupId_userId.groupId &&
                item.userId === where.groupId_userId.userId,
            ) ?? null;

          if (!member) {
            return null;
          }

          if (select) {
            return {
              ...(select.status ? { status: member.status } : {}),
              ...(select.role ? { role: member.role } : {}),
            };
          }

          return member;
        },
      ),
    },
    contribution: {
      findUnique: jest.fn(
        ({
          where,
          include,
        }: {
          where: {
            id?: string;
            cycleId_userId?: { cycleId: string; userId: string };
          };
          include?: {
            user?: { select: { id: true; fullName: true; phone: true } };
          };
        }) => {
          let contribution: ContributionRecord | null = null;

          if (where.id) {
            contribution =
              contributions.find((item) => item.id === where.id) ?? null;
          } else if (where.cycleId_userId) {
            contribution =
              contributions.find(
                (item) =>
                  item.cycleId === where.cycleId_userId?.cycleId &&
                  item.userId === where.cycleId_userId?.userId,
              ) ?? null;
          }

          if (!contribution) {
            return null;
          }

          if (include?.user) {
            return {
              ...contribution,
              user:
                users.find((user) => user.id === contribution.userId) ?? null,
            };
          }

          return contribution;
        },
      ),
      create: jest.fn(
        ({
          data,
          include,
        }: {
          data: Omit<
            ContributionRecord,
            | 'id'
            | 'createdAt'
            | 'confirmedByUserId'
            | 'confirmedAt'
            | 'rejectedByUserId'
            | 'rejectedAt'
            | 'rejectReason'
          >;
          include?: {
            user?: { select: { id: true; fullName: true; phone: true } };
          };
        }) => {
          const contribution: ContributionRecord = {
            id: `contribution_${contributions.length + 1}`,
            ...data,
            confirmedByUserId: null,
            confirmedAt: null,
            rejectedByUserId: null,
            rejectedAt: null,
            rejectReason: null,
            createdAt: new Date(),
          };

          contributions.push(contribution);

          if (include?.user) {
            return {
              ...contribution,
              user:
                users.find((user) => user.id === contribution.userId) ?? null,
            };
          }

          return contribution;
        },
      ),
      update: jest.fn(
        ({
          where,
          data,
          include,
        }: {
          where: { id: string };
          data: Partial<ContributionRecord>;
          include?: {
            user?: { select: { id: true; fullName: true; phone: true } };
          };
        }) => {
          const contribution = contributions.find(
            (item) => item.id === where.id,
          );
          if (!contribution) {
            throw new Error('Contribution not found');
          }

          Object.assign(contribution, data);

          if (include?.user) {
            return {
              ...contribution,
              user:
                users.find((user) => user.id === contribution.userId) ?? null,
            };
          }

          return contribution;
        },
      ),
      count: jest.fn(
        ({
          where,
        }: {
          where: { cycleId: string; status: ContributionStatus };
        }) => {
          return contributions.filter(
            (item) =>
              item.cycleId === where.cycleId && item.status === where.status,
          ).length;
        },
      ),
      findMany: jest.fn(
        ({ where }: { where: { groupId: string; cycleId: string } }) => {
          return contributions
            .filter(
              (item) =>
                item.groupId === where.groupId &&
                item.cycleId === where.cycleId,
            )
            .map((contribution) => ({
              ...contribution,
              user:
                users.find((user) => user.id === contribution.userId) ?? null,
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

    contributionsController = moduleFixture.get<ContributionsController>(
      ContributionsController,
    );
  });

  beforeEach(() => {
    contributions.splice(0, contributions.length);
    cycles[0].contributionsSubmittedCount = 0;
    cycles[0].contributionsConfirmedCount = 0;
    jest.clearAllMocks();
  });

  it('member submits contribution with proof key and gets SUBMITTED', async () => {
    const proofFileKey =
      'groups/00000000-0000-0000-0000-000000000101/cycles/00000000-0000-0000-0000-000000000201/users/00000000-0000-0000-0000-000000000022/uuid_receipt.jpg';

    const response = await contributionsController.submitContribution(
      memberUser,
      '00000000-0000-0000-0000-000000000201',
      {
        proofFileKey,
      },
    );

    expect(response.status).toBe(ContributionStatus.PAID_SUBMITTED);
    expect(response.proofFileKey).toBe(proofFileKey);
  });

  it('admin confirms submitted contribution', async () => {
    const submitted = await contributionsController.submitContribution(
      memberUser,
      '00000000-0000-0000-0000-000000000201',
      {
        proofFileKey:
          'groups/00000000-0000-0000-0000-000000000101/cycles/00000000-0000-0000-0000-000000000201/users/00000000-0000-0000-0000-000000000022/uuid_receipt.jpg',
      },
    );

    const confirmed = await contributionsController.confirmContribution(
      adminUser,
      submitted.id,
      {},
    );

    expect(confirmed.status).toBe(ContributionStatus.VERIFIED);
    expect(confirmed.confirmedAt).not.toBeNull();
  });

  it('admin rejects then member resubmits rejected contribution', async () => {
    const submitted = await contributionsController.submitContribution(
      memberUser,
      '00000000-0000-0000-0000-000000000201',
      {
        proofFileKey:
          'groups/00000000-0000-0000-0000-000000000101/cycles/00000000-0000-0000-0000-000000000201/users/00000000-0000-0000-0000-000000000022/uuid_receipt.jpg',
      },
    );

    const rejected = await contributionsController.rejectContribution(
      adminUser,
      submitted.id,
      {
        reason: 'Invalid proof',
      },
    );

    expect(rejected.status).toBe(ContributionStatus.REJECTED);
    expect(rejected.rejectReason).toBe('Invalid proof');

    const resubmitted = await contributionsController.submitContribution(
      memberUser,
      '00000000-0000-0000-0000-000000000201',
      {
        proofFileKey:
          'groups/00000000-0000-0000-0000-000000000101/cycles/00000000-0000-0000-0000-000000000201/users/00000000-0000-0000-0000-000000000022/uuid_new_receipt.jpg',
      },
    );

    expect(resubmitted.status).toBe(ContributionStatus.PAID_SUBMITTED);
    expect(resubmitted.rejectReason).toBeNull();
  });
});
