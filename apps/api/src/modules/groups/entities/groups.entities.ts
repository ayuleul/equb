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
  GroupVisibility,
  JoinRequestStatus,
  MemberRole,
  MemberStatus,
  StartPolicy,
  WinnerSelectionTiming,
} from '@prisma/client';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  GroupTrustSummaryDto,
  HostReputationSummaryDto,
  MemberReliabilitySummaryDto,
} from '../../reputation/entities/reputation.entities';

export class GroupSummaryResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  name!: string;

  @ApiPropertyOptional({ nullable: true })
  description!: string | null;

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

  @ApiProperty({ enum: GroupVisibility })
  visibility!: GroupVisibility;

  @ApiProperty()
  rulesetConfigured!: boolean;

  @ApiProperty()
  canInviteMembers!: boolean;

  @ApiProperty()
  canStartCycle!: boolean;

  @ApiPropertyOptional({ nullable: true })
  hostTier!: string | null;

  @ApiPropertyOptional({ nullable: true })
  hostReputationAtCreation!: number | null;

  @ApiPropertyOptional({ nullable: true })
  hostReputationLevel!: string | null;

  @ApiPropertyOptional({ nullable: true, type: Object })
  allowedPublicEqubLimits!: {
    maxMembers: number | null;
    maxContributionAmount: number | null;
    maxDurationDays: number | null;
    maxActivePublicEqubs: number | null;
  } | null;
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

  @ApiProperty({ type: () => GroupTrustSummaryDto })
  trustSummary!: GroupTrustSummaryDto;
}

export class GroupStartReadinessDto {
  @ApiProperty()
  eligibleCount!: number;

  @ApiProperty()
  isReadyToStart!: boolean;

  @ApiProperty()
  isWaitingForMembers!: boolean;

  @ApiProperty()
  isWaitingForDate!: boolean;
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

  @ApiProperty({ enum: WinnerSelectionTiming })
  winnerSelectionTiming!: WinnerSelectionTiming;

  @ApiProperty({ enum: GroupPaymentMethod, isArray: true })
  paymentMethods!: GroupPaymentMethod[];

  @ApiProperty()
  requiresMemberVerification!: boolean;

  @ApiProperty()
  strictCollection!: boolean;

  @ApiProperty()
  roundSize!: number;

  @ApiProperty({ enum: StartPolicy })
  startPolicy!: StartPolicy;

  @ApiPropertyOptional({ nullable: true })
  startAt!: Date | null;

  @ApiPropertyOptional({ nullable: true })
  minToStart!: number | null;

  @ApiProperty()
  requiredToStart!: number;

  @ApiProperty({ type: () => GroupStartReadinessDto })
  readiness!: GroupStartReadinessDto;

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

export class PublicGroupRulesSummaryResponseDto {
  @ApiProperty()
  contributionAmount!: number;

  @ApiProperty({ enum: GroupRuleFrequency })
  frequency!: GroupRuleFrequency;

  @ApiPropertyOptional({ nullable: true })
  customIntervalDays!: number | null;

  @ApiProperty({ enum: GroupRulePayoutMode })
  payoutMode!: GroupRulePayoutMode;

  @ApiProperty()
  roundSize!: number;

  @ApiProperty({ enum: StartPolicy })
  startPolicy!: StartPolicy;

  @ApiPropertyOptional({ nullable: true })
  startAt!: Date | null;

  @ApiPropertyOptional({ nullable: true })
  minToStart!: number | null;

  @ApiProperty({ enum: WinnerSelectionTiming })
  winnerSelectionTiming!: WinnerSelectionTiming;
}

export class PublicGroupSummaryResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  name!: string;

  @ApiPropertyOptional({ nullable: true })
  description!: string | null;

  @ApiProperty()
  currency!: string;

  @ApiProperty()
  contributionAmount!: number;

  @ApiProperty({ enum: GroupRuleFrequency })
  frequency!: GroupRuleFrequency;

  @ApiPropertyOptional({ enum: GroupRulePayoutMode, nullable: true })
  payoutMode!: GroupRulePayoutMode | null;

  @ApiProperty()
  memberCount!: number;

  @ApiProperty()
  alreadyStarted!: boolean;

  @ApiPropertyOptional({ nullable: true })
  hostName!: string | null;

  @ApiPropertyOptional({ nullable: true })
  hostTier!: string | null;

  @ApiPropertyOptional({ nullable: true })
  hostReputationAtCreation!: number | null;

  @ApiPropertyOptional({ nullable: true })
  hostReputationLevel!: string | null;

  @ApiPropertyOptional({ nullable: true, type: Object })
  allowedPublicEqubLimits!: {
    maxMembers: number | null;
    maxContributionAmount: number | null;
    maxDurationDays: number | null;
    maxActivePublicEqubs: number | null;
  } | null;

  @ApiProperty({ type: () => HostReputationSummaryDto })
  host!: HostReputationSummaryDto;

  @ApiProperty({ type: () => GroupTrustSummaryDto })
  trustSummary!: GroupTrustSummaryDto;
}

export class PublicGroupDetailResponseDto extends PublicGroupSummaryResponseDto {
  @ApiProperty({ enum: GroupVisibility })
  visibility!: GroupVisibility;

  @ApiProperty({ enum: GroupStatus })
  status!: GroupStatus;

  @ApiProperty()
  rulesetConfigured!: boolean;

  @ApiProperty()
  isCurrentUserMember!: boolean;

  @ApiPropertyOptional({
    type: () => PublicGroupRulesSummaryResponseDto,
    nullable: true,
  })
  rules!: PublicGroupRulesSummaryResponseDto | null;
}

export class DiscoverGroupHostDto {
  @ApiProperty()
  id!: string;

  @ApiPropertyOptional({ nullable: true })
  name!: string | null;

  @ApiProperty()
  trustScore!: number;

  @ApiProperty()
  trustLevel!: string;
}

export class DiscoverGroupItemResponseDto extends PublicGroupSummaryResponseDto {
  @ApiProperty()
  equbId!: string;

  @ApiProperty()
  durationDays!: number;

  @ApiProperty()
  joinedCount!: number;

  @ApiProperty()
  maxMembers!: number;

  @ApiProperty()
  fillPercent!: number;

  @ApiProperty()
  groupTrustLevel!: string;

  @ApiProperty({ type: () => DiscoverGroupHostDto })
  discoverHost!: DiscoverGroupHostDto;

  @ApiProperty({ type: String, isArray: true })
  reasonLabels!: string[];
}

export class DiscoverGroupSectionResponseDto {
  @ApiProperty()
  key!: string;

  @ApiProperty()
  title!: string;

  @ApiProperty({ type: () => DiscoverGroupItemResponseDto, isArray: true })
  items!: DiscoverGroupItemResponseDto[];
}

export class DiscoverGroupsResponseDto {
  @ApiProperty({ type: () => DiscoverGroupSectionResponseDto, isArray: true })
  sections!: DiscoverGroupSectionResponseDto[];
}

export class JoinRequestUserResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  phone!: string;

  @ApiPropertyOptional({ nullable: true })
  fullName!: string | null;

  @ApiPropertyOptional({ type: () => MemberReliabilitySummaryDto })
  reputation?: MemberReliabilitySummaryDto;
}

export class JoinRequestResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  groupId!: string;

  @ApiProperty()
  userId!: string;

  @ApiProperty({ enum: JoinRequestStatus })
  status!: JoinRequestStatus;

  @ApiPropertyOptional({ nullable: true })
  message!: string | null;

  @ApiProperty()
  createdAt!: Date;

  @ApiPropertyOptional({ nullable: true })
  reviewedAt!: Date | null;

  @ApiPropertyOptional({ nullable: true })
  reviewedByUserId!: string | null;

  @ApiPropertyOptional({ nullable: true })
  retryAvailableAt!: Date | null;

  @ApiPropertyOptional({ type: () => JoinRequestUserResponseDto })
  user?: JoinRequestUserResponseDto;
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

  @ApiPropertyOptional({ type: () => MemberReliabilitySummaryDto })
  reputation?: MemberReliabilitySummaryDto;
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

  @ApiPropertyOptional({ nullable: true })
  winnerSelectedAt!: Date | null;

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

  @ApiPropertyOptional({ nullable: true })
  payoutSentAt!: Date | null;

  @ApiPropertyOptional({ nullable: true })
  payoutSentByUserId!: string | null;

  @ApiPropertyOptional({ nullable: true })
  payoutReceivedConfirmedAt!: Date | null;

  @ApiPropertyOptional({ nullable: true })
  payoutReceivedConfirmedByUserId!: string | null;

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
