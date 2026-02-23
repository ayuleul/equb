import { MemberStatus } from '@prisma/client';
import { ApiProperty } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import { IsEnum, IsIn } from 'class-validator';

export class UpdateMemberStatusDto {
  @ApiProperty({
    enum: [MemberStatus.SUSPENDED, MemberStatus.LEFT, MemberStatus.REMOVED],
  })
  @Transform(({ value }) =>
    typeof value === 'string' ? value.toUpperCase() : value,
  )
  @IsEnum(MemberStatus)
  @IsIn([MemberStatus.SUSPENDED, MemberStatus.LEFT, MemberStatus.REMOVED])
  status!: 'SUSPENDED' | 'LEFT' | 'REMOVED';
}
