import { Injectable, NotFoundException } from '@nestjs/common';
import { User } from '@prisma/client';

import { AuditService } from '../../common/audit/audit.service';
import {
  isProfileComplete,
  normalizeNameWhitespace,
} from '../../common/profile/profile.utils';
import { PrismaService } from '../../common/prisma/prisma.service';
import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { MeResponseDto } from './entities/me.entities';

@Injectable()
export class MeService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly auditService: AuditService,
  ) {}

  async getMe(currentUser: AuthenticatedUser): Promise<MeResponseDto> {
    const user = await this.prisma.user.findUnique({
      where: { id: currentUser.id },
      select: {
        id: true,
        phone: true,
        firstName: true,
        middleName: true,
        lastName: true,
        fullName: true,
      },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return this.toResponse(user);
  }

  async updateProfile(
    currentUser: AuthenticatedUser,
    dto: UpdateProfileDto,
  ): Promise<MeResponseDto> {
    const firstName = normalizeNameWhitespace(dto.firstName);
    const middleName = normalizeNameWhitespace(dto.middleName);
    const lastName = normalizeNameWhitespace(dto.lastName);
    const fullName = `${firstName} ${middleName} ${lastName}`.trim();

    const user = await this.prisma.user.update({
      where: { id: currentUser.id },
      data: {
        firstName,
        middleName,
        lastName,
        fullName,
      },
      select: {
        id: true,
        phone: true,
        firstName: true,
        middleName: true,
        lastName: true,
        fullName: true,
      },
    });

    await this.auditService.log('USER_PROFILE_UPDATED', currentUser.id, {
      firstName,
      middleName,
      lastName,
      profileComplete: isProfileComplete(user),
    });

    return this.toResponse(user);
  }

  private toResponse(
    user: Pick<
      User,
      'id' | 'phone' | 'firstName' | 'middleName' | 'lastName' | 'fullName'
    >,
  ): MeResponseDto {
    return {
      id: user.id,
      phone: user.phone,
      firstName: user.firstName,
      middleName: user.middleName,
      lastName: user.lastName,
      fullName: user.fullName,
      profileComplete: isProfileComplete(user),
    };
  }
}
