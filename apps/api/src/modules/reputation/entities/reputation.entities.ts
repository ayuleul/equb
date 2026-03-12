import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class ReputationEligibilityResponseDto {
  @ApiProperty()
  canHostPublicGroup!: boolean;

  @ApiProperty()
  canJoinHighValuePublicGroup!: boolean;

  @ApiProperty()
  canAccessLending!: boolean;

  @ApiProperty()
  canAccessMarketplace!: boolean;

  @ApiPropertyOptional({ nullable: true })
  hostTier!: string | null;

  @ApiProperty()
  hostReputationLevel!: string;

  @ApiProperty({ type: Object })
  allowedPublicEqubLimits!: {
    maxMembers: number | null;
    maxContributionAmount: number | null;
    maxDurationDays: number | null;
    maxActivePublicEqubs: number | null;
  };
}

export class ReputationBadgeDto {
  @ApiProperty()
  code!: string;

  @ApiProperty()
  label!: string;

  @ApiProperty()
  description!: string;
}

export class ReputationComponentsDto {
  @ApiProperty()
  payment!: number;

  @ApiProperty()
  completion!: number;

  @ApiProperty()
  behavior!: number;

  @ApiProperty()
  experience!: number;
}

export class MemberReliabilitySummaryDto {
  @ApiProperty()
  userId!: string;

  @ApiProperty()
  trustScore!: number;

  @ApiProperty()
  trustLevel!: string;

  @ApiProperty()
  summaryLabel!: string;

  @ApiProperty()
  equbsCompleted!: number;

  @ApiProperty()
  equbsHosted!: number;

  @ApiPropertyOptional({ nullable: true })
  onTimePaymentRate!: number | null;
}

export class HostReputationSummaryDto {
  @ApiProperty()
  userId!: string;

  @ApiProperty()
  trustScore!: number;

  @ApiProperty()
  trustLevel!: string;

  @ApiProperty()
  summaryLabel!: string;

  @ApiProperty()
  equbsHosted!: number;

  @ApiProperty()
  hostedEqubsCompleted!: number;

  @ApiProperty()
  turnsParticipated!: number;

  @ApiPropertyOptional({ nullable: true })
  hostedCompletionRate!: number | null;

  @ApiProperty()
  cancelledGroupsCount!: number;

  @ApiProperty()
  hostDisputesCount!: number;
}

export class GroupTrustSummaryDto {
  @ApiProperty()
  groupId!: string;

  @ApiProperty()
  hostScore!: number;

  @ApiPropertyOptional({ nullable: true })
  averageMemberScore!: number | null;

  @ApiPropertyOptional({ nullable: true })
  verifiedMembersPercent!: number | null;

  @ApiProperty()
  groupTrustLevel!: string;

  @ApiProperty({ type: () => HostReputationSummaryDto })
  host!: HostReputationSummaryDto;
}

export class ReputationProfileResponseDto {
  @ApiProperty()
  userId!: string;

  @ApiProperty()
  trustScore!: number;

  @ApiProperty()
  trustLevel!: string;

  @ApiProperty()
  summaryLabel!: string;

  @ApiProperty()
  equbsJoined!: number;

  @ApiProperty()
  equbsCompleted!: number;

  @ApiProperty()
  equbsLeftEarly!: number;

  @ApiProperty()
  equbsHosted!: number;

  @ApiProperty()
  hostedEqubsCompleted!: number;

  @ApiProperty()
  onTimePayments!: number;

  @ApiProperty()
  latePayments!: number;

  @ApiProperty()
  missedPayments!: number;

  @ApiProperty()
  turnsParticipated!: number;

  @ApiProperty()
  payoutsReceived!: number;

  @ApiProperty()
  payoutsConfirmed!: number;

  @ApiProperty()
  removalsCount!: number;

  @ApiProperty()
  disputesCount!: number;

  @ApiProperty()
  cancelledGroupsCount!: number;

  @ApiProperty()
  hostDisputesCount!: number;

  @ApiProperty({ type: () => ReputationComponentsDto })
  components!: ReputationComponentsDto;

  @ApiProperty()
  baseScore!: number;

  @ApiProperty()
  activityFactor!: number;

  @ApiProperty()
  adjustedScore!: number;

  @ApiProperty()
  confidenceFactor!: number;

  @ApiPropertyOptional({ nullable: true })
  lastEqubActivityAt!: Date | null;

  @ApiPropertyOptional({ nullable: true })
  onTimePaymentRate!: number | null;

  @ApiPropertyOptional({ nullable: true })
  hostedCompletionRate!: number | null;

  @ApiProperty()
  updatedAt!: Date;

  @ApiProperty({ type: () => ReputationEligibilityResponseDto })
  eligibility!: ReputationEligibilityResponseDto;

  @ApiProperty({ type: () => ReputationBadgeDto, isArray: true })
  badges!: ReputationBadgeDto[];
}

export class ReputationHistoryEntryDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  userId!: string;

  @ApiProperty()
  eventType!: string;

  @ApiProperty()
  scoreDelta!: number;

  @ApiProperty({ type: Object })
  metricChanges!: Record<string, number>;

  @ApiPropertyOptional({ nullable: true })
  relatedGroupId!: string | null;

  @ApiPropertyOptional({ nullable: true })
  relatedCycleId!: string | null;

  @ApiPropertyOptional({ nullable: true, type: Object })
  metadata!: Record<string, unknown> | null;

  @ApiProperty()
  createdAt!: Date;
}

export class ReputationHistoryResponseDto {
  @ApiProperty({ type: () => ReputationHistoryEntryDto, isArray: true })
  items!: ReputationHistoryEntryDto[];

  @ApiProperty()
  page!: number;

  @ApiProperty()
  limit!: number;

  @ApiProperty()
  total!: number;
}
