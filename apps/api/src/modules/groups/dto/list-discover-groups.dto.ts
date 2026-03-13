import { ApiPropertyOptional } from '@nestjs/swagger';
import { GroupRuleFrequency } from '@prisma/client';
import { Transform, Type } from 'class-transformer';
import { IsEnum, IsInt, IsOptional, IsString, Max, Min } from 'class-validator';

import { DISCOVER_LIMITS } from '../discover.constants';

export class ListDiscoverGroupsDto {
  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  contributionMin?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  contributionMax?: number;

  @ApiPropertyOptional({
    description: 'Duration in days; matched against the rules frequency',
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  durationMin?: number;

  @ApiPropertyOptional({
    description: 'Duration in days; matched against the rules frequency',
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  durationMax?: number;

  @ApiPropertyOptional({ enum: GroupRuleFrequency })
  @IsOptional()
  @IsEnum(GroupRuleFrequency)
  frequency?: GroupRuleFrequency;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(2)
  groupSizeMin?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(2)
  groupSizeMax?: number;

  @ApiPropertyOptional({
    description: 'Filter by host trust level band such as New or Trusted',
  })
  @IsOptional()
  @Transform(({ value }) =>
    typeof value === 'string' && value.trim().length > 0
      ? value.trim()
      : undefined,
  )
  @IsString()
  trustLevel?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @Transform(({ value }) =>
    typeof value === 'string' && value.trim().length > 0
      ? value.trim()
      : undefined,
  )
  @IsString()
  hostTier?: string;

  @ApiPropertyOptional({
    default: DISCOVER_LIMITS.defaultSectionLimit,
    maximum: DISCOVER_LIMITS.maxSectionLimit,
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(DISCOVER_LIMITS.maxSectionLimit)
  sectionLimit?: number;
}
