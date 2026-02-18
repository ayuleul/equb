import { MemberRole } from '@prisma/client';
import { ApiProperty } from '@nestjs/swagger';
import { IsEnum } from 'class-validator';

export class UpdateMemberRoleDto {
  @ApiProperty({ enum: MemberRole, example: MemberRole.ADMIN })
  @IsEnum(MemberRole)
  role!: MemberRole;
}
