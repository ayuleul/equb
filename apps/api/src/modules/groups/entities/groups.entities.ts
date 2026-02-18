import {
  CycleStatus,
  GroupFrequency,
  GroupStatus,
  MemberRole,
  MemberStatus,
} from '@prisma/client';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class GroupSummaryResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  name!: string;

  @ApiProperty()
  currency!: string;

  @ApiProperty()
  contributionAmount!: number;

  @ApiProperty({ enum: GroupFrequency })
  frequency!: GroupFrequency;

  @ApiProperty()
  startDate!: Date;

  @ApiProperty({ enum: GroupStatus })
  status!: GroupStatus;
}

export class CurrentMembershipResponseDto {
  @ApiProperty({ enum: MemberRole })
  role!: MemberRole;

  @ApiProperty({ enum: MemberStatus })
  status!: MemberStatus;
}

export class GroupDetailResponseDto extends GroupSummaryResponseDto {
  @ApiProperty()
  createdByUserId!: string;

  @ApiProperty()
  createdAt!: Date;

  @ApiProperty()
  strictPayout!: boolean;

  @ApiProperty()
  timezone!: string;

  @ApiProperty({ type: () => CurrentMembershipResponseDto })
  membership!: CurrentMembershipResponseDto;
}

export class InviteCodeResponseDto {
  @ApiProperty()
  code!: string;

  @ApiProperty()
  joinUrl!: string;
}

export class GroupJoinResponseDto {
  @ApiProperty()
  groupId!: string;

  @ApiProperty({ enum: MemberRole })
  role!: MemberRole;

  @ApiProperty({ enum: MemberStatus })
  status!: MemberStatus;

  @ApiPropertyOptional()
  joinedAt!: Date | null;
}

export class MemberProfileResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  phone!: string;

  @ApiPropertyOptional({ nullable: true })
  fullName!: string | null;
}

export class GroupMemberResponseDto {
  @ApiProperty({ type: () => MemberProfileResponseDto })
  user!: MemberProfileResponseDto;

  @ApiProperty({ enum: MemberRole })
  role!: MemberRole;

  @ApiProperty({ enum: MemberStatus })
  status!: MemberStatus;

  @ApiPropertyOptional({ nullable: true })
  payoutPosition!: number | null;

  @ApiPropertyOptional({ nullable: true })
  joinedAt!: Date | null;
}

export class CyclePayoutUserResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  phone!: string;

  @ApiPropertyOptional({ nullable: true })
  fullName!: string | null;
}

export class GroupCycleResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  groupId!: string;

  @ApiProperty()
  cycleNo!: number;

  @ApiProperty()
  dueDate!: Date;

  @ApiProperty()
  payoutUserId!: string;

  @ApiProperty({ enum: CycleStatus })
  status!: CycleStatus;

  @ApiProperty()
  createdByUserId!: string;

  @ApiProperty()
  createdAt!: Date;

  @ApiProperty({ type: () => CyclePayoutUserResponseDto })
  payoutUser!: CyclePayoutUserResponseDto;
}
