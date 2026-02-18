import { MemberStatus } from '@prisma/client';
import { ApiProperty } from '@nestjs/swagger';
import { IsEnum, IsIn } from 'class-validator';

export class UpdateMemberStatusDto {
  @ApiProperty({ enum: [MemberStatus.LEFT, MemberStatus.REMOVED] })
  @IsEnum(MemberStatus)
  @IsIn([MemberStatus.LEFT, MemberStatus.REMOVED])
  status!: 'LEFT' | 'REMOVED';
}
