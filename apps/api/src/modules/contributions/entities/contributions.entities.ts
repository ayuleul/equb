import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { ContributionStatus } from '@prisma/client';

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
}

export class ContributionListResponseDto {
  @ApiProperty({ type: () => ContributionResponseDto, isArray: true })
  items!: ContributionResponseDto[];

  @ApiProperty({ type: () => ContributionListSummaryDto })
  summary!: ContributionListSummaryDto;
}
