import { Test, TestingModule } from '@nestjs/testing';
import {
  AuctionStatus,
  CycleStatus,
  MemberRole,
  MemberStatus,
} from '@prisma/client';

import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/common/prisma/prisma.service';
import type { AuthenticatedUser } from '../src/common/types/authenticated-user.type';
import { AuctionsController } from '../src/modules/auctions/auctions.controller';

type UserRecord = {
  id: string;
  phone: string;
  fullName: string | null;
};

type MembershipRecord = {
  groupId: string;
  userId: string;
  role: MemberRole;
  status: MemberStatus;
};

type CycleRecord = {
  id: string;
  groupId: string;
  status: CycleStatus;
  auctionStatus: AuctionStatus;
  scheduledPayoutUserId: string;
  finalPayoutUserId: string;
  winningBidAmount: number | null;
  winningBidUserId: string | null;
};

type AuctionRecord = {
  id: string;
  cycleId: string;
  openedByUserId: string;
  status: AuctionStatus;
  openedAt: Date;
  closedAt: Date | null;
};

type BidRecord = {
  id: string;
  cycleId: string;
  userId: string;
  amount: number;
  createdAt: Date;
  updatedAt: Date;
};

describe('Auctions (e2e)', () => {
  let auctionsController: AuctionsController;

  const users: UserRecord[] = [
    {
      id: '00000000-0000-0000-0000-000000000011',
      fullName: 'Admin',
      phone: '+251911111111',
    },
    {
      id: '00000000-0000-0000-0000-000000000022',
      fullName: 'Scheduled Recipient',
      phone: '+251922222222',
    },
    {
      id: '00000000-0000-0000-0000-000000000033',
      fullName: 'Bidder',
      phone: '+251933333333',
    },
  ];

  const memberships: MembershipRecord[] = [
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
    {
      groupId: '00000000-0000-0000-0000-000000000101',
      userId: '00000000-0000-0000-0000-000000000033',
      role: MemberRole.MEMBER,
      status: MemberStatus.ACTIVE,
    },
  ];

  const cycles: CycleRecord[] = [];
  const auctions: AuctionRecord[] = [];
  const bids: BidRecord[] = [];

  const adminUser: AuthenticatedUser = {
    id: '00000000-0000-0000-0000-000000000011',
    phone: '+251911111111',
  };
  const scheduledUser: AuthenticatedUser = {
    id: '00000000-0000-0000-0000-000000000022',
    phone: '+251922222222',
  };
  const bidderUser: AuthenticatedUser = {
    id: '00000000-0000-0000-0000-000000000033',
    phone: '+251933333333',
  };

  const findUser = (id: string) => users.find((user) => user.id === id) ?? null;

  const prismaMock = {
    equbCycle: {
      findUnique: jest.fn(
        ({
          where,
          select,
        }: {
          where: { id: string };
          select: Record<string, boolean>;
        }) => {
          const cycle = cycles.find((item) => item.id === where.id) ?? null;
          if (!cycle) {
            return null;
          }

          return {
            ...(select.id ? { id: cycle.id } : {}),
            ...(select.groupId ? { groupId: cycle.groupId } : {}),
            ...(select.status ? { status: cycle.status } : {}),
            ...(select.auctionStatus
              ? { auctionStatus: cycle.auctionStatus }
              : {}),
            ...(select.scheduledPayoutUserId
              ? { scheduledPayoutUserId: cycle.scheduledPayoutUserId }
              : {}),
            ...(select.finalPayoutUserId
              ? { finalPayoutUserId: cycle.finalPayoutUserId }
              : {}),
            ...(select.winningBidAmount
              ? { winningBidAmount: cycle.winningBidAmount }
              : {}),
            ...(select.winningBidUserId
              ? { winningBidUserId: cycle.winningBidUserId }
              : {}),
          };
        },
      ),
      update: jest.fn(
        ({
          where,
          data,
          select,
        }: {
          where: { id: string };
          data: Partial<CycleRecord>;
          select: Record<string, boolean>;
        }) => {
          const cycle = cycles.find((item) => item.id === where.id);
          if (!cycle) {
            throw new Error('Cycle not found');
          }
          Object.assign(cycle, data);
          return {
            ...(select.id ? { id: cycle.id } : {}),
            ...(select.auctionStatus
              ? { auctionStatus: cycle.auctionStatus }
              : {}),
            ...(select.scheduledPayoutUserId
              ? { scheduledPayoutUserId: cycle.scheduledPayoutUserId }
              : {}),
            ...(select.finalPayoutUserId
              ? { finalPayoutUserId: cycle.finalPayoutUserId }
              : {}),
            ...(select.winningBidAmount
              ? { winningBidAmount: cycle.winningBidAmount }
              : {}),
            ...(select.winningBidUserId
              ? { winningBidUserId: cycle.winningBidUserId }
              : {}),
          };
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
          select: { status: true; role: true };
        }) => {
          const membership =
            memberships.find(
              (item) =>
                item.groupId === where.groupId_userId.groupId &&
                item.userId === where.groupId_userId.userId,
            ) ?? null;
          if (!membership) {
            return null;
          }
          return {
            ...(select.status ? { status: membership.status } : {}),
            ...(select.role ? { role: membership.role } : {}),
          };
        },
      ),
    },
    cycleAuction: {
      create: jest.fn(
        ({
          data,
        }: {
          data: {
            cycleId: string;
            openedByUserId: string;
            status: AuctionStatus;
            openedAt: Date;
          };
        }) => {
          const record: AuctionRecord = {
            id: `auction_${auctions.length + 1}`,
            cycleId: data.cycleId,
            openedByUserId: data.openedByUserId,
            status: data.status,
            openedAt: data.openedAt,
            closedAt: null,
          };
          auctions.push(record);
          return record;
        },
      ),
      findUnique: jest.fn(
        ({
          where,
          select,
        }: {
          where: { cycleId: string };
          select: { id: true; status: true };
        }) => {
          const auction =
            auctions.find((item) => item.cycleId === where.cycleId) ?? null;
          if (!auction) {
            return null;
          }
          return {
            ...(select.id ? { id: auction.id } : {}),
            ...(select.status ? { status: auction.status } : {}),
          };
        },
      ),
      update: jest.fn(
        ({
          where,
          data,
        }: {
          where: { cycleId: string };
          data: { status: AuctionStatus; closedAt: Date };
        }) => {
          const auction = auctions.find(
            (item) => item.cycleId === where.cycleId,
          );
          if (!auction) {
            throw new Error('Auction not found');
          }
          auction.status = data.status;
          auction.closedAt = data.closedAt;
          return auction;
        },
      ),
    },
    cycleBid: {
      upsert: jest.fn(
        ({
          where,
          update,
          create,
          include,
        }: {
          where: { cycleId_userId: { cycleId: string; userId: string } };
          update: { amount: number };
          create: { cycleId: string; userId: string; amount: number };
          include: {
            user: {
              select: { id: true; phone: true; fullName: true };
            };
          };
        }) => {
          const existing = bids.find(
            (item) =>
              item.cycleId === where.cycleId_userId.cycleId &&
              item.userId === where.cycleId_userId.userId,
          );

          if (existing) {
            existing.amount = update.amount;
            existing.updatedAt = new Date();
            return {
              ...existing,
              ...(include.user ? { user: findUser(existing.userId) } : {}),
            };
          }

          const record: BidRecord = {
            id: `bid_${bids.length + 1}`,
            cycleId: create.cycleId,
            userId: create.userId,
            amount: create.amount,
            createdAt: new Date(),
            updatedAt: new Date(),
          };
          bids.push(record);

          return {
            ...record,
            ...(include.user ? { user: findUser(record.userId) } : {}),
          };
        },
      ),
      findMany: jest.fn(
        ({
          where,
          include,
          orderBy,
          take,
        }: {
          where: { cycleId: string; userId?: string };
          include?: {
            user: {
              select: { id: true; phone: true; fullName: true };
            };
          };
          orderBy: Array<{
            amount?: 'asc' | 'desc';
            createdAt?: 'asc' | 'desc';
          }>;
          take?: number;
        }) => {
          let filtered = bids.filter(
            (item) =>
              item.cycleId === where.cycleId &&
              (!where.userId || item.userId === where.userId),
          );

          filtered = [...filtered].sort((a, b) => {
            if (a.amount !== b.amount) {
              return b.amount - a.amount;
            }
            return a.createdAt.getTime() - b.createdAt.getTime();
          });

          if (typeof take === 'number') {
            filtered = filtered.slice(0, take);
          }

          return filtered.map((bid) => ({
            ...bid,
            ...(include?.user ? { user: findUser(bid.userId) } : {}),
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

    auctionsController =
      moduleFixture.get<AuctionsController>(AuctionsController);
  });

  beforeEach(() => {
    cycles.splice(0, cycles.length);
    auctions.splice(0, auctions.length);
    bids.splice(0, bids.length);
    cycles.push({
      id: '00000000-0000-0000-0000-000000000201',
      groupId: '00000000-0000-0000-0000-000000000101',
      status: CycleStatus.OPEN,
      auctionStatus: AuctionStatus.NONE,
      scheduledPayoutUserId: '00000000-0000-0000-0000-000000000022',
      finalPayoutUserId: '00000000-0000-0000-0000-000000000022',
      winningBidAmount: null,
      winningBidUserId: null,
    });
    jest.clearAllMocks();
  });

  it('scheduled recipient opens auction, members bid, and close selects highest bidder as final recipient', async () => {
    const opened = await auctionsController.openAuction(
      scheduledUser,
      '00000000-0000-0000-0000-000000000201',
    );
    expect(opened.auctionStatus).toBe(AuctionStatus.OPEN);

    await auctionsController.submitBid(
      adminUser,
      '00000000-0000-0000-0000-000000000201',
      { amount: 500 },
    );
    await auctionsController.submitBid(
      bidderUser,
      '00000000-0000-0000-0000-000000000201',
      { amount: 650 },
    );

    const closed = await auctionsController.closeAuction(
      scheduledUser,
      '00000000-0000-0000-0000-000000000201',
    );

    expect(closed.auctionStatus).toBe(AuctionStatus.CLOSED);
    expect(closed.finalPayoutUserId).toBe(
      '00000000-0000-0000-0000-000000000033',
    );
    expect(closed.winningBidUserId).toBe(
      '00000000-0000-0000-0000-000000000033',
    );
    expect(closed.winningBidAmount).toBe(650);
  });
});
