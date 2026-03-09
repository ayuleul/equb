import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';

type RoundEligibilityTx = Prisma.TransactionClient;

@Injectable()
export class RoundEligibilityService {
  async getRoundParticipantUserIds(
    tx: RoundEligibilityTx,
    args: {
      roundId: string;
      fallbackUserIds?: string[];
    },
  ): Promise<string[]> {
    const scheduledUsers = await tx.payoutSchedule.findMany({
      where: {
        roundId: args.roundId,
      },
      select: {
        userId: true,
      },
      orderBy: {
        position: 'asc',
      },
    });

    if (scheduledUsers.length > 0) {
      return this.uniqueUserIds(scheduledUsers.map((entry) => entry.userId));
    }

    const contributionUsers = await tx.contribution.findMany({
      where: {
        cycle: {
          roundId: args.roundId,
        },
      },
      select: {
        userId: true,
      },
      distinct: ['userId'],
    });

    if (contributionUsers.length > 0) {
      return this.uniqueUserIds(contributionUsers.map((entry) => entry.userId));
    }

    return this.uniqueUserIds(args.fallbackUserIds ?? []);
  }

  async listCompletedWinnerUserIds(
    tx: RoundEligibilityTx,
    roundId: string,
  ): Promise<string[]> {
    const completedCycles = await tx.equbCycle.findMany({
      where: {
        roundId,
        payoutReceivedConfirmedAt: {
          not: null,
        },
        selectedWinnerUserId: {
          not: null,
        },
      },
      select: {
        selectedWinnerUserId: true,
      },
      orderBy: {
        cycleNo: 'asc',
      },
    });

    return this.uniqueUserIds(
      completedCycles
        .map((cycle) => cycle.selectedWinnerUserId)
        .filter((userId): userId is string => userId != null),
    );
  }

  computeRemainingEligibleWinnerUserIds(
    roundParticipantUserIds: string[],
    completedWinnerUserIds: string[],
  ): string[] {
    const completedWinnerUserIdSet = new Set(completedWinnerUserIds);
    return roundParticipantUserIds.filter(
      (userId) => !completedWinnerUserIdSet.has(userId),
    );
  }

  async closeRoundIfOpen(
    tx: RoundEligibilityTx,
    args: {
      roundId: string;
      closedAt: Date;
    },
  ): Promise<void> {
    await tx.equbRound.updateMany({
      where: {
        id: args.roundId,
        closedAt: null,
      },
      data: {
        closedAt: args.closedAt,
      },
    });
  }

  private uniqueUserIds(userIds: string[]): string[] {
    return [...new Set(userIds)];
  }
}
