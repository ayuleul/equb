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
import { AuthenticatedUser } from '../types/authenticated-user.type';

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

    const idParam = request.params?.id;
    const userId = request.user?.id;

    if (!idParam) {
      throw new BadRequestException('Resource id is required');
    }

    if (!userId) {
      throw new ForbiddenException('Authentication required');
    }

    let groupId = idParam;
    const isContributionRoute = request.path.includes('/contributions/');

    if (isContributionRoute) {
      const contribution = await this.prisma.contribution.findUnique({
        where: { id: idParam },
        select: { groupId: true },
      });

      if (!contribution) {
        throw new ForbiddenException('Contribution not found');
      }

      groupId = contribution.groupId;
    }

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
}
