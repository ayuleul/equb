import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString } from 'class-validator';

export class ConfirmPayoutDto {
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
