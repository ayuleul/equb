import { GroupVisibility } from '@prisma/client';
import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
} from 'class-validator';

export class UpdateGroupDto {
  @ApiPropertyOptional({ example: 'Family Equb' })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  @MaxLength(120)
  name?: string;

  @ApiPropertyOptional({ example: 'A neighborhood savings circle.' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  description?: string;

  @ApiPropertyOptional({ example: 'ETB' })
  @IsOptional()
  @IsString()
  @Matches(/^[A-Z]{3}$/)
  currency?: string;

  @ApiPropertyOptional({
    enum: GroupVisibility,
    example: GroupVisibility.PRIVATE,
  })
  @IsOptional()
  @IsEnum(GroupVisibility)
  visibility?: GroupVisibility;
}
