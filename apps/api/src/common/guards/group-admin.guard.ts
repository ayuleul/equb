import {
  BadRequestException,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { MemberRole, MemberStatus } from '@prisma/client';
import { Request } from 'express';

import { PrismaService } from '../prisma/prisma.service';
import type { AuthenticatedUser } from '../types/authenticated-user.type';

type RequestWithUserAndParams = Request & {
  user?: AuthenticatedUser;
  params?: Record<string, string | undefined>;
};

@Injectable()
export class GroupAdminGuard implements CanActivate {
  constructor(private readonly prisma: PrismaService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context
      .switchToHttp()
      .getRequest<RequestWithUserAndParams>();

    const userId = request.user?.id;

    if (!userId) {
      throw new ForbiddenException('Authentication required');
    }

    const groupId = await this.resolveGroupId(request);

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

    if (
      !membership ||
      membership.status !== MemberStatus.ACTIVE ||
      membership.role !== MemberRole.ADMIN
    ) {
      throw new ForbiddenException('Active admin membership is required');
    }

    return true;
  }

  private async resolveGroupId(
    request: RequestWithUserAndParams,
  ): Promise<string> {
    const params = request.params ?? {};

    const cycleId = params.cycleId;
    if (cycleId) {
      const cycle = await this.prisma.equbCycle.findUnique({
        where: { id: cycleId },
        select: { groupId: true },
      });

      if (!cycle) {
        throw new ForbiddenException('Cycle not found');
      }

      return cycle.groupId;
    }

    const idParam = params.id;
    if (!idParam) {
      throw new BadRequestException('Resource id is required');
    }

    if (request.path.includes('/contributions/')) {
      const contribution = await this.prisma.contribution.findUnique({
        where: { id: idParam },
        select: { groupId: true },
      });

      if (!contribution) {
        throw new ForbiddenException('Contribution not found');
      }

      return contribution.groupId;
    }

    if (request.path.includes('/payouts/')) {
      const payout = await this.prisma.payout.findUnique({
        where: { id: idParam },
        select: { groupId: true },
      });

      if (!payout) {
        throw new ForbiddenException('Payout not found');
      }

      return payout.groupId;
    }

    return idParam;
  }
}
