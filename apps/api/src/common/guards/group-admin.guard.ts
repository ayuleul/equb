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

    const groupId = request.params?.id;
    const userId = request.user?.id;

    if (!groupId) {
      throw new BadRequestException('Group id is required');
    }

    if (!userId) {
      throw new ForbiddenException('Authentication required');
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
