import { GroupPaymentMethod } from '@prisma/client';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import { IsEnum, IsInt, IsOptional, IsString, Min } from 'class-validator';

export class SubmitContributionDto {
  @ApiPropertyOptional({ enum: GroupPaymentMethod })
  @Transform(({ value }: { value: unknown }) =>
    typeof value === 'string' ? value.toUpperCase() : value,
  )
  @IsOptional()
  @IsEnum(GroupPaymentMethod)
  method?: GroupPaymentMethod;

  @ApiPropertyOptional({ example: 500 })
  @IsOptional()
  @IsInt()
  @Min(1)
  amount?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  receiptFileKey?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  reference?: string;

  // legacy compatibility alias for reference
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  paymentRef?: string;

  // legacy compatibility alias for receiptFileKey
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  proofFileKey?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  note?: string;
}
