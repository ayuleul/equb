import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsDateString, IsInt, IsOptional, Min } from 'class-validator';

export class CreateInviteDto {
  @ApiPropertyOptional({ example: '2026-04-01T00:00:00.000Z' })
  @IsOptional()
  @IsDateString()
  expiresAt?: string;

  @ApiPropertyOptional({ example: 20 })
  @IsOptional()
  @IsInt()
  @Min(1)
  maxUses?: number;
}
