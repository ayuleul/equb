import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  ContributionStatus,
  DisputeStatus,
  GroupPaymentMethod,
} from '@prisma/client';

export class ContributionUserResponseDto {
  @ApiProperty()
  id!: string;

  @ApiPropertyOptional({ nullable: true })
  fullName!: string | null;

  @ApiPropertyOptional({ nullable: true })
  phone!: string | null;
}

export class ContributionResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  groupId!: string;

  @ApiProperty()
  cycleId!: string;

  @ApiProperty()
  userId!: string;

  @ApiProperty()
  amount!: number;

  @ApiProperty({ enum: ContributionStatus })
  status!: ContributionStatus;

  @ApiPropertyOptional({ enum: GroupPaymentMethod, nullable: true })
  paymentMethod!: GroupPaymentMethod | null;

  @ApiPropertyOptional({ nullable: true })
  proofFileKey!: string | null;

  @ApiPropertyOptional({ nullable: true })
  paymentRef!: string | null;

  @ApiPropertyOptional({ nullable: true })
  note!: string | null;

  @ApiPropertyOptional({ nullable: true })
  submittedAt!: Date | null;

  @ApiPropertyOptional({ nullable: true })
  confirmedAt!: Date | null;

  @ApiPropertyOptional({ nullable: true })
  rejectedAt!: Date | null;

  @ApiPropertyOptional({ nullable: true })
  rejectReason!: string | null;

  @ApiPropertyOptional({ nullable: true })
  lateMarkedAt!: Date | null;

  @ApiProperty()
  createdAt!: Date;

  @ApiProperty({ type: () => ContributionUserResponseDto })
  user!: ContributionUserResponseDto;
}

export class ContributionListSummaryDto {
  @ApiProperty()
  total!: number;

  @ApiProperty()
  pending!: number;

  @ApiProperty()
  submitted!: number;

  @ApiProperty()
  confirmed!: number;

  @ApiProperty()
  rejected!: number;

  @ApiProperty()
  paidSubmitted!: number;

  @ApiProperty()
  verified!: number;

  @ApiProperty()
  late!: number;
}

export class ContributionListResponseDto {
  @ApiProperty({ type: () => ContributionResponseDto, isArray: true })
  items!: ContributionResponseDto[];

  @ApiProperty({ type: () => ContributionListSummaryDto })
  summary!: ContributionListSummaryDto;
}

export class ContributionDisputeResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  groupId!: string;

  @ApiProperty()
  cycleId!: string;

  @ApiProperty()
  contributionId!: string;

  @ApiProperty()
  reportedByUserId!: string;

  @ApiProperty({ enum: DisputeStatus })
  status!: DisputeStatus;

  @ApiProperty()
  reason!: string;

  @ApiPropertyOptional({ nullable: true })
  note!: string | null;

  @ApiPropertyOptional({ nullable: true })
  mediationNote!: string | null;

  @ApiPropertyOptional({ nullable: true })
  mediatedAt!: Date | null;

  @ApiPropertyOptional({ nullable: true })
  mediatedByUserId!: string | null;

  @ApiPropertyOptional({ nullable: true })
  resolutionOutcome!: string | null;

  @ApiPropertyOptional({ nullable: true })
  resolutionNote!: string | null;

  @ApiPropertyOptional({ nullable: true })
  resolvedAt!: Date | null;

  @ApiPropertyOptional({ nullable: true })
  resolvedByUserId!: string | null;

  @ApiProperty()
  createdAt!: Date;

  @ApiProperty()
  updatedAt!: Date;
}

export class CycleEvaluationResponseDto {
  @ApiProperty()
  cycleId!: string;

  @ApiProperty()
  dueAt!: Date;

  @ApiProperty()
  graceDays!: number;

  @ApiProperty()
  graceDeadline!: Date;

  @ApiProperty()
  evaluatedAt!: Date;

  @ApiProperty()
  strictCollection!: boolean;

  @ApiProperty()
  allVerified!: boolean;

  @ApiProperty()
  readyForPayout!: boolean;

  @ApiProperty()
  overdueCount!: number;

  @ApiProperty()
  lateMarkedCount!: number;

  @ApiProperty()
  fineLedgerEntriesCreated!: number;

  @ApiProperty()
  notifiedMembersCount!: number;

  @ApiProperty()
  notifiedGuarantorsCount!: number;
}
