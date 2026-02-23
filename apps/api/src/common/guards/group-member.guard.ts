import {
  BadRequestException,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { Request } from 'express';

import { isParticipatingMemberStatus } from '../membership/member-status.util';
import { PrismaService } from '../prisma/prisma.service';
import type { AuthenticatedUser } from '../types/authenticated-user.type';

type RequestWithUserAndParams = Request & {
  user?: AuthenticatedUser;
  params?: Record<string, string | undefined>;
};

@Injectable()
export class GroupMemberGuard implements CanActivate {
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
      },
    });

    if (!membership || !isParticipatingMemberStatus(membership.status)) {
      throw new ForbiddenException('Joined group membership is required');
    }

    return true;
  }

  private async resolveGroupId(
    request: RequestWithUserAndParams,
  ): Promise<string> {
    const groupIdFromRoute = request.params?.id;
    if (groupIdFromRoute) {
      return groupIdFromRoute;
    }

    const cycleId = request.params?.cycleId;
    if (!cycleId) {
      throw new BadRequestException('Group or cycle identifier is required');
    }

    const cycle = await this.prisma.equbCycle.findUnique({
      where: { id: cycleId },
      select: { groupId: true },
    });

    if (!cycle) {
      throw new ForbiddenException('Cycle not found');
    }

    return cycle.groupId;
  }
}
