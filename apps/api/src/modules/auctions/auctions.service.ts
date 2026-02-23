import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  AuctionStatus,
  CycleStatus,
  MemberRole,
  Prisma,
} from '@prisma/client';

import { AuditService } from '../../common/audit/audit.service';
import { isParticipatingMemberStatus } from '../../common/membership/member-status.util';
import { PrismaService } from '../../common/prisma/prisma.service';
import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import { SubmitBidDto } from './dto/submit-bid.dto';
import {
  CycleAuctionStateResponseDto,
  CycleBidResponseDto,
} from './entities/auctions.entities';

type BidWithUser = Prisma.CycleBidGetPayload<{
  include: {
    user: {
      select: {
        id: true;
        phone: true;
        fullName: true;
      };
    };
  };
}>;

@Injectable()
export class AuctionsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly auditService: AuditService,
  ) {}

  async openAuction(
    currentUser: AuthenticatedUser,
    cycleId: string,
  ): Promise<CycleAuctionStateResponseDto> {
    const cycle = await this.prisma.equbCycle.findUnique({
      where: { id: cycleId },
      select: {
        id: true,
        groupId: true,
        status: true,
        auctionStatus: true,
        scheduledPayoutUserId: true,
        finalPayoutUserId: true,
        winningBidAmount: true,
        winningBidUserId: true,
      },
    });

    if (!cycle) {
      throw new NotFoundException('Cycle not found');
    }

    if (cycle.status !== CycleStatus.OPEN) {
      throw new BadRequestException(
        'Auction can only be opened for open cycle',
      );
    }

    if (cycle.auctionStatus !== AuctionStatus.NONE) {
      throw new BadRequestException('Auction is already opened or closed');
    }

    const isAdmin = await this.isActiveAdmin(cycle.groupId, currentUser.id);
    if (currentUser.id !== cycle.scheduledPayoutUserId && !isAdmin) {
      throw new ForbiddenException(
        'Only the scheduled recipient or an admin can open auction',
      );
    }

    const updatedCycle = await this.prisma.$transaction(async (tx) => {
      await tx.cycleAuction.create({
        data: {
          cycleId: cycle.id,
          openedByUserId: currentUser.id,
          status: AuctionStatus.OPEN,
          openedAt: new Date(),
        },
      });

      return tx.equbCycle.update({
        where: { id: cycle.id },
        data: { auctionStatus: AuctionStatus.OPEN },
        select: {
          id: true,
          auctionStatus: true,
          scheduledPayoutUserId: true,
          finalPayoutUserId: true,
          winningBidAmount: true,
          winningBidUserId: true,
        },
      });
    });

    await this.auditService.log(
      'AUCTION_OPENED',
      currentUser.id,
      {
        cycleId: cycle.id,
        scheduledPayoutUserId: cycle.scheduledPayoutUserId,
      },
      cycle.groupId,
    );

    return this.toAuctionStateResponse(updatedCycle);
  }

  async submitBid(
    currentUser: AuthenticatedUser,
    cycleId: string,
    dto: SubmitBidDto,
  ): Promise<CycleBidResponseDto> {
    const cycle = await this.prisma.equbCycle.findUnique({
      where: { id: cycleId },
      select: {
        id: true,
        groupId: true,
        status: true,
        auctionStatus: true,
      },
    });

    if (!cycle) {
      throw new NotFoundException('Cycle not found');
    }

    if (cycle.status !== CycleStatus.OPEN) {
      throw new BadRequestException('Cannot bid on closed cycle');
    }

    if (cycle.auctionStatus !== AuctionStatus.OPEN) {
      throw new BadRequestException('Auction is not open for bidding');
    }

    const bid = await this.prisma.cycleBid.upsert({
      where: {
        cycleId_userId: {
          cycleId: cycle.id,
          userId: currentUser.id,
        },
      },
      update: {
        amount: dto.amount,
      },
      create: {
        cycleId: cycle.id,
        userId: currentUser.id,
        amount: dto.amount,
      },
      include: {
        user: {
          select: {
            id: true,
            phone: true,
            fullName: true,
          },
        },
      },
    });

    await this.auditService.log(
      'BID_SUBMITTED',
      currentUser.id,
      {
        cycleId: cycle.id,
        bidId: bid.id,
        amount: bid.amount,
      },
      cycle.groupId,
    );

    return this.toBidResponse(bid);
  }

  async listBids(
    currentUser: AuthenticatedUser,
    cycleId: string,
  ): Promise<CycleBidResponseDto[]> {
    const cycle = await this.prisma.equbCycle.findUnique({
      where: { id: cycleId },
      select: {
        id: true,
        groupId: true,
        scheduledPayoutUserId: true,
      },
    });

    if (!cycle) {
      throw new NotFoundException('Cycle not found');
    }

    const isAdmin = await this.isActiveAdmin(cycle.groupId, currentUser.id);
    const canSeeAllBids =
      isAdmin || currentUser.id === cycle.scheduledPayoutUserId;

    const bids = await this.prisma.cycleBid.findMany({
      where: canSeeAllBids
        ? { cycleId: cycle.id }
        : { cycleId: cycle.id, userId: currentUser.id },
      include: {
        user: {
          select: {
            id: true,
            phone: true,
            fullName: true,
          },
        },
      },
      orderBy: [{ amount: 'desc' }, { createdAt: 'asc' }],
    });

    return bids.map((bid) => this.toBidResponse(bid));
  }

  async closeAuction(
    currentUser: AuthenticatedUser,
    cycleId: string,
  ): Promise<CycleAuctionStateResponseDto> {
    const cycle = await this.prisma.equbCycle.findUnique({
      where: { id: cycleId },
      select: {
        id: true,
        groupId: true,
        status: true,
        auctionStatus: true,
        scheduledPayoutUserId: true,
      },
    });

    if (!cycle) {
      throw new NotFoundException('Cycle not found');
    }

    if (cycle.status !== CycleStatus.OPEN) {
      throw new BadRequestException(
        'Auction can only be closed for open cycle',
      );
    }

    if (cycle.auctionStatus !== AuctionStatus.OPEN) {
      throw new BadRequestException('Auction is not open');
    }

    const isAdmin = await this.isActiveAdmin(cycle.groupId, currentUser.id);
    if (currentUser.id !== cycle.scheduledPayoutUserId && !isAdmin) {
      throw new ForbiddenException(
        'Only the scheduled recipient or an admin can close auction',
      );
    }

    const { updatedCycle, winner } = await this.prisma.$transaction(
      async (tx) => {
        const auction = await tx.cycleAuction.findUnique({
          where: { cycleId: cycle.id },
          select: { id: true, status: true },
        });

        if (!auction || auction.status !== AuctionStatus.OPEN) {
          throw new BadRequestException('Auction record is not open');
        }

        const bids = await tx.cycleBid.findMany({
          where: { cycleId: cycle.id },
          orderBy: [{ amount: 'desc' }, { createdAt: 'asc' }],
          take: 1,
        });

        const winner = bids[0] ?? null;

        const updatedCycle = await tx.equbCycle.update({
          where: { id: cycle.id },
          data: {
            finalPayoutUserId: winner
              ? winner.userId
              : cycle.scheduledPayoutUserId,
            winningBidAmount: winner ? winner.amount : null,
            winningBidUserId: winner ? winner.userId : null,
            auctionStatus: AuctionStatus.CLOSED,
          },
          select: {
            id: true,
            auctionStatus: true,
            scheduledPayoutUserId: true,
            finalPayoutUserId: true,
            winningBidAmount: true,
            winningBidUserId: true,
          },
        });

        await tx.cycleAuction.update({
          where: { cycleId: cycle.id },
          data: {
            status: AuctionStatus.CLOSED,
            closedAt: new Date(),
          },
        });

        return {
          updatedCycle,
          winner,
        };
      },
    );

    await this.auditService.log(
      'AUCTION_CLOSED',
      currentUser.id,
      {
        cycleId: cycle.id,
        finalPayoutUserId: updatedCycle.finalPayoutUserId,
      },
      cycle.groupId,
    );

    if (winner) {
      await this.auditService.log(
        'WINNER_SELECTED',
        currentUser.id,
        {
          cycleId: cycle.id,
          winnerUserId: winner.userId,
          winningBidAmount: winner.amount,
        },
        cycle.groupId,
      );
    }

    return this.toAuctionStateResponse(updatedCycle);
  }

  private async isActiveAdmin(
    groupId: string,
    userId: string,
  ): Promise<boolean> {
    const membership = await this.prisma.equbMember.findUnique({
      where: {
        groupId_userId: {
          groupId,
          userId,
        },
      },
      select: {
        status: true,
        role: true,
      },
    });

    return (
      !!membership &&
      isParticipatingMemberStatus(membership.status) &&
      membership.role === MemberRole.ADMIN
    );
  }

  private toBidResponse(bid: BidWithUser): CycleBidResponseDto {
    return {
      id: bid.id,
      cycleId: bid.cycleId,
      userId: bid.userId,
      amount: bid.amount,
      createdAt: bid.createdAt,
      updatedAt: bid.updatedAt,
      user: bid.user,
    };
  }

  private toAuctionStateResponse(cycle: {
    id: string;
    auctionStatus: AuctionStatus;
    scheduledPayoutUserId: string;
    finalPayoutUserId: string;
    winningBidAmount: number | null;
    winningBidUserId: string | null;
  }): CycleAuctionStateResponseDto {
    return {
      cycleId: cycle.id,
      auctionStatus: cycle.auctionStatus,
      scheduledPayoutUserId: cycle.scheduledPayoutUserId,
      finalPayoutUserId: cycle.finalPayoutUserId,
      winningBidAmount: cycle.winningBidAmount,
      winningBidUserId: cycle.winningBidUserId,
    };
  }
}
