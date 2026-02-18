import { GroupFrequency } from '@prisma/client';
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
} from 'class-validator';

export class CreateGroupDto {
  @ApiProperty({ example: 'Family Equb' })
  @IsString()
  @IsNotEmpty()
  name!: string;

  @ApiProperty({ example: 500 })
  @IsInt()
  @Min(1)
  contributionAmount!: number;

  @ApiProperty({ enum: GroupFrequency, example: GroupFrequency.MONTHLY })
  @IsEnum(GroupFrequency)
  frequency!: GroupFrequency;

  @ApiProperty({ example: '2026-03-01' })
  @IsDateString()
  startDate!: string;

  @ApiPropertyOptional({ example: 'ETB' })
  @IsOptional()
  @IsString()
  @Matches(/^[A-Z]{3}$/)
  currency?: string;
}
