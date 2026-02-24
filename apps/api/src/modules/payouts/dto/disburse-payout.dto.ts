import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString } from 'class-validator';

export class DisbursePayoutDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  proofFileKey?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  paymentRef?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  note?: string;
}
