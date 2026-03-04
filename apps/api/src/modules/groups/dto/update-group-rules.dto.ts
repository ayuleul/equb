import {
  GroupPaymentMethod,
  GroupRuleFineType,
  GroupRuleFrequency,
  GroupRulePayoutMode,
  StartPolicy,
} from '@prisma/client';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  ArrayNotEmpty,
  ArrayUnique,
  IsArray,
  IsBoolean,
  IsEnum,
  IsInt,
  IsOptional,
  IsDateString,
  Min,
  ValidateIf,
} from 'class-validator';

export class UpdateGroupRulesDto {
  @ApiProperty({ example: 500 })
  @IsInt()
  @Min(1)
  contributionAmount!: number;

  @ApiProperty({
    enum: GroupRuleFrequency,
    example: GroupRuleFrequency.MONTHLY,
  })
  @IsEnum(GroupRuleFrequency)
  frequency!: GroupRuleFrequency;

  @ApiPropertyOptional({
    example: 14,
    nullable: true,
    description: 'Required when frequency is CUSTOM_INTERVAL',
  })
  @ValidateIf(
    (dto: UpdateGroupRulesDto) =>
      dto.frequency === GroupRuleFrequency.CUSTOM_INTERVAL,
  )
  @IsInt()
  @Min(1)
  customIntervalDays?: number;

  @ApiProperty({ example: 2 })
  @IsInt()
  @Min(0)
  graceDays!: number;

  @ApiProperty({ enum: GroupRuleFineType, example: GroupRuleFineType.NONE })
  @IsEnum(GroupRuleFineType)
  fineType!: GroupRuleFineType;

  @ApiProperty({ example: 0 })
  @ValidateIf(
    (dto: UpdateGroupRulesDto) =>
      dto.fineType === GroupRuleFineType.FIXED_AMOUNT,
  )
  @IsInt()
  @Min(1)
  fineAmount!: number;

  @ApiProperty({
    enum: GroupRulePayoutMode,
    example: GroupRulePayoutMode.LOTTERY,
  })
  @IsEnum(GroupRulePayoutMode)
  payoutMode!: GroupRulePayoutMode;

  @ApiProperty({
    enum: GroupPaymentMethod,
    isArray: true,
    example: [GroupPaymentMethod.CASH_ACK],
  })
  @IsArray()
  @ArrayNotEmpty()
  @ArrayUnique()
  @IsEnum(GroupPaymentMethod, { each: true })
  paymentMethods!: GroupPaymentMethod[];

  @ApiProperty({ example: false })
  @IsBoolean()
  requiresMemberVerification!: boolean;

  @ApiProperty({ example: false })
  @IsBoolean()
  strictCollection!: boolean;

  @ApiProperty({
    example: 12,
    minimum: 2,
    description: 'Number of members in each round before rollover',
  })
  @IsInt()
  @Min(2)
  roundSize!: number;

  @ApiProperty({
    enum: StartPolicy,
    example: StartPolicy.WHEN_FULL,
    default: StartPolicy.WHEN_FULL,
  })
  @IsEnum(StartPolicy)
  startPolicy: StartPolicy = StartPolicy.WHEN_FULL;

  @ApiPropertyOptional({
    example: '2026-04-01T08:00:00.000Z',
    nullable: true,
    description: 'Required only when startPolicy is ON_DATE',
  })
  @IsOptional()
  @IsDateString()
  startAt?: string | null;

  @ApiPropertyOptional({
    example: 8,
    nullable: true,
    description:
      'Optional minimum member count to start early for ON_DATE/MANUAL policies',
  })
  @IsOptional()
  @IsInt()
  @Min(2)
  minToStart?: number | null;
}
