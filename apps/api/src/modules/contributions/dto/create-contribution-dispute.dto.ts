import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

export class CreateContributionDisputeDto {
  @ApiProperty({
    example: 'Receipt amount does not match expected contribution amount.',
  })
  @IsString()
  @MinLength(3)
  @MaxLength(500)
  reason!: string;

  @ApiPropertyOptional({
    example: 'I uploaded a corrected proof and need admin review.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  note?: string;
}
