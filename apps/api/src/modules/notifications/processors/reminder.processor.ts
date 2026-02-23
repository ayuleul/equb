import {
  Injectable,
  Logger,
  OnModuleDestroy,
  OnModuleInit,
} from '@nestjs/common';
import {
  ContributionStatus,
  CycleStatus,
  GroupStatus,
  NotificationType,
} from '@prisma/client';
import { Job, Worker } from 'bullmq';

import { DateService } from '../../../common/date/date.service';
import { PARTICIPATING_MEMBER_STATUSES } from '../../../common/membership/member-status.util';
import { BullMqService } from '../../../common/queues/bullmq.service';
import { REMINDERS_QUEUE } from '../../../common/queues/queue.constants';
import { ReminderJobData } from '../../../common/queues/queue.types';
import { PrismaService } from '../../../common/prisma/prisma.service';
import { NotificationsService } from '../notifications.service';

@Injectable()
export class ReminderProcessor implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(ReminderProcessor.name);
  private worker: Worker<ReminderJobData> | null = null;

  constructor(
    private readonly bullMqService: BullMqService,
    private readonly prisma: PrismaService,
    private readonly dateService: DateService,
    private readonly notificationsService: NotificationsService,
  ) {}

  onModuleInit(): void {
    if (!this.bullMqService.isEnabled()) {
      return;
    }

    this.worker = new Worker<ReminderJobData>(
      REMINDERS_QUEUE,
      async (job) => this.process(job),
      {
        connection: this.bullMqService.getConnectionOptions(),
        concurrency: 1,
      },
    );

    this.worker.on('failed', (job, error) => {
      this.logger.error(
        `Reminder job failed id=${job?.id ?? 'unknown'}`,
        error.stack,
      );
    });
  }

  async onModuleDestroy(): Promise<void> {
    await this.worker?.close();
  }

  private async process(job: Job<ReminderJobData>): Promise<void> {
    const reference =
      typeof job.data?.triggeredAtIso === 'string'
        ? new Date(job.data.triggeredAtIso)
        : new Date();

    const openCycles = await this.prisma.equbCycle.findMany({
      where: {
        status: CycleStatus.OPEN,
        group: {
          status: GroupStatus.ACTIVE,
        },
      },
      include: {
        group: {
          select: {
            id: true,
            name: true,
            timezone: true,
          },
        },
        contributions: {
          where: {
            status: {
              in: [
                ContributionStatus.PAID_SUBMITTED,
                ContributionStatus.SUBMITTED,
                ContributionStatus.VERIFIED,
                ContributionStatus.CONFIRMED,
              ],
            },
          },
          select: {
            userId: true,
          },
        },
      },
    });

    for (const cycle of openCycles) {
      if (
        !this.dateService.isDueWithinNext24HoursOrToday(
          cycle.dueDate,
          cycle.group.timezone,
          reference,
        )
      ) {
        continue;
      }

      const activeMembers = await this.prisma.equbMember.findMany({
        where: {
          groupId: cycle.groupId,
          status: {
            in: PARTICIPATING_MEMBER_STATUSES,
          },
        },
        select: {
          userId: true,
        },
      });

      const submittedOrConfirmedUserIds = new Set(
        cycle.contributions.map((item) => item.userId),
      );

      const reminderDateKey = this.dateService.dateKey(
        reference,
        cycle.group.timezone,
      );
      const dueDateKey = this.dateService.dateKey(
        cycle.dueDate,
        cycle.group.timezone,
      );

      await Promise.all(
        activeMembers
          .filter((member) => !submittedOrConfirmedUserIds.has(member.userId))
          .map((member) =>
            this.notificationsService.notifyUser(member.userId, {
              type: NotificationType.DUE_REMINDER,
              title: 'Contribution due reminder',
              body: `Your contribution for ${cycle.group.name} is due on ${dueDateKey}.`,
              groupId: cycle.groupId,
              data: {
                groupId: cycle.groupId,
                cycleId: cycle.id,
                dueDate: cycle.dueDate.toISOString(),
              },
              dedupKey: `due-reminder:${member.userId}:${cycle.id}:${reminderDateKey}`,
            }),
          ),
      );
    }
  }
}
