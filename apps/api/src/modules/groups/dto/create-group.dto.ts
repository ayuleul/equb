import { GroupFrequency, GroupVisibility } from '@prisma/client';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsDateString,
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  Matches,
  Min,
  MaxLength,
} from 'class-validator';

export class CreateGroupDto {
  @ApiProperty({ example: 'Family Equb' })
  @IsString()
  @IsNotEmpty()
  name!: string;

  @ApiPropertyOptional({ example: 'A neighborhood savings circle.' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  description?: string;

  @ApiPropertyOptional({
    example: 500,
    description: 'Legacy compatibility field; prefer PUT /groups/:id/rules',
  })
  @IsOptional()
  @IsInt()
  @Min(1)
  contributionAmount?: number;

  @ApiPropertyOptional({
    enum: GroupFrequency,
    example: GroupFrequency.MONTHLY,
    description: 'Legacy compatibility field; prefer PUT /groups/:id/rules',
  })
  @IsOptional()
  @IsEnum(GroupFrequency)
  frequency?: GroupFrequency;

  @ApiPropertyOptional({
    example: '2026-03-01',
    description: 'Legacy compatibility field; defaults to current date',
  })
  @IsOptional()
  @IsDateString()
  startDate?: string;

  @ApiPropertyOptional({ example: 'ETB' })
  @IsOptional()
  @IsString()
  @Matches(/^[A-Z]{3}$/)
  currency?: string;

  @ApiPropertyOptional({
    enum: GroupVisibility,
    example: GroupVisibility.PRIVATE,
    default: GroupVisibility.PRIVATE,
  })
  @IsOptional()
  @IsEnum(GroupVisibility)
  visibility?: GroupVisibility;
}
