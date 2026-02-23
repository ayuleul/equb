import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

export class ResolveDisputeDto {
  @ApiProperty({
    example:
      'Mismatch confirmed and corrected. Contribution should be re-submitted.',
  })
  @IsString()
  @MinLength(3)
  @MaxLength(300)
  outcome!: string;

  @ApiPropertyOptional({
    example: 'Member agreed to resubmit with updated transfer reference.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  note?: string;
}
