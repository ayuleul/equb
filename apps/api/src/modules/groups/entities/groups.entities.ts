import {
  AuctionStatus,
  CycleStatus,
  CycleState,
  GroupFrequency,
  GroupPaymentMethod,
  GroupRuleFineType,
  GroupRuleFrequency,
  GroupRulePayoutMode,
  GroupStatus,
  MemberRole,
  MemberStatus,
  PayoutMode,
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

  @ApiProperty()
  rulesetConfigured!: boolean;

  @ApiProperty()
  canInviteMembers!: boolean;

  @ApiProperty()
  canStartCycle!: boolean;
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

export class GroupRulesResponseDto {
  @ApiProperty()
  groupId!: string;

  @ApiProperty()
  contributionAmount!: number;

  @ApiProperty({ enum: GroupRuleFrequency })
  frequency!: GroupRuleFrequency;

  @ApiPropertyOptional({ nullable: true })
  customIntervalDays!: number | null;

  @ApiProperty()
  graceDays!: number;

  @ApiProperty({ enum: GroupRuleFineType })
  fineType!: GroupRuleFineType;

  @ApiProperty()
  fineAmount!: number;

  @ApiProperty({ enum: GroupRulePayoutMode })
  payoutMode!: GroupRulePayoutMode;

  @ApiProperty({ enum: GroupPaymentMethod, isArray: true })
  paymentMethods!: GroupPaymentMethod[];

  @ApiProperty()
  requiresMemberVerification!: boolean;

  @ApiProperty()
  strictCollection!: boolean;

  @ApiProperty()
  createdAt!: Date;

  @ApiProperty()
  updatedAt!: Date;
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
  @ApiProperty()
  id!: string;

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

  @ApiPropertyOptional({ nullable: true })
  verifiedAt!: Date | null;

  @ApiPropertyOptional({ nullable: true })
  verifiedByUserId!: string | null;
}

export class CyclePayoutUserResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  phone!: string;

  @ApiPropertyOptional({ nullable: true })
  fullName!: string | null;
}

export class RoundScheduleResponseDto {
  @ApiProperty()
  position!: number;

  @ApiProperty()
  userId!: string;

  @ApiProperty({ type: () => CyclePayoutUserResponseDto })
  user!: CyclePayoutUserResponseDto;
}

export class RoundStartResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  groupId!: string;

  @ApiProperty()
  roundNo!: number;

  @ApiProperty({ enum: PayoutMode })
  payoutMode!: PayoutMode;

  @ApiProperty()
  drawSeedHash!: string;

  @ApiProperty()
  startedByUserId!: string;

  @ApiProperty()
  startedAt!: Date;

  @ApiProperty({ type: () => RoundScheduleResponseDto, isArray: true })
  schedule!: RoundScheduleResponseDto[];
}

export class CurrentRoundScheduleItemResponseDto {
  @ApiProperty()
  position!: number;

  @ApiProperty()
  userId!: string;

  @ApiPropertyOptional({ nullable: true })
  displayName!: string | null;
}

export class CurrentRoundScheduleResponseDto {
  @ApiProperty()
  roundId!: string;

  @ApiProperty()
  roundNo!: number;

  @ApiProperty()
  drawSeedHash!: string;

  @ApiProperty({
    type: () => CurrentRoundScheduleItemResponseDto,
    isArray: true,
  })
  schedule!: CurrentRoundScheduleItemResponseDto[];
}

export class RoundSeedRevealResponseDto {
  @ApiProperty()
  roundId!: string;

  @ApiProperty()
  roundNo!: number;

  @ApiProperty()
  seedHex!: string;

  @ApiProperty()
  seedHash!: string;

  @ApiProperty()
  revealedAt!: Date;

  @ApiProperty()
  revealedByUserId!: string;
}

export class GroupCycleResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  groupId!: string;

  @ApiProperty()
  roundId!: string;

  @ApiProperty()
  cycleNo!: number;

  @ApiProperty()
  dueDate!: Date;

  @ApiProperty()
  dueAt!: Date;

  @ApiProperty({ enum: CycleState })
  state!: CycleState;

  @ApiProperty()
  scheduledPayoutUserId!: string;

  @ApiProperty()
  finalPayoutUserId!: string;

  @ApiPropertyOptional({ nullable: true })
  selectedWinnerUserId!: string | null;

  @ApiPropertyOptional({ enum: GroupRulePayoutMode, nullable: true })
  selectionMethod!: GroupRulePayoutMode | null;

  @ApiPropertyOptional({ nullable: true, type: Object })
  selectionMetadata!: Record<string, unknown> | null;

  @ApiProperty()
  payoutUserId!: string;

  @ApiProperty({ enum: AuctionStatus })
  auctionStatus!: AuctionStatus;

  @ApiPropertyOptional({ nullable: true })
  winningBidAmount!: number | null;

  @ApiPropertyOptional({ nullable: true })
  winningBidUserId!: string | null;

  @ApiProperty({ enum: CycleStatus })
  status!: CycleStatus;

  @ApiProperty()
  createdByUserId!: string;

  @ApiProperty()
  createdAt!: Date;

  @ApiProperty({ type: () => CyclePayoutUserResponseDto })
  scheduledPayoutUser!: CyclePayoutUserResponseDto;

  @ApiProperty({ type: () => CyclePayoutUserResponseDto })
  finalPayoutUser!: CyclePayoutUserResponseDto;

  @ApiPropertyOptional({
    type: () => CyclePayoutUserResponseDto,
    nullable: true,
  })
  selectedWinnerUser!: CyclePayoutUserResponseDto | null;

  @ApiPropertyOptional({
    type: () => CyclePayoutUserResponseDto,
    nullable: true,
  })
  winningBidUser!: CyclePayoutUserResponseDto | null;

  @ApiProperty({ type: () => CyclePayoutUserResponseDto })
  payoutUser!: CyclePayoutUserResponseDto;
}
