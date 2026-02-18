import { Injectable, Logger } from '@nestjs/common';
import { Prisma } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AuditService {
  private readonly logger = new Logger(AuditService.name);

  constructor(private readonly prisma: PrismaService) {}

  async log(
    action: string,
    actorUserId: string | null,
    metadata?: Record<string, unknown>,
    groupId?: string | null,
  ): Promise<void> {
    try {
      await this.prisma.auditLog.create({
        data: {
          action,
          groupId,
          actorUserId,
          metadata: metadata as Prisma.InputJsonValue,
        },
      });
    } catch (error) {
      this.logger.error(
        `Failed to persist audit log for action=${action}`,
        error instanceof Error ? error.stack : undefined,
      );
    }
  }
}
