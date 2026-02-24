import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString } from 'class-validator';

export class SelectWinnerDto {
  @ApiPropertyOptional({
    description:
      'Required when payoutMode=DECISION. Ignored for other payout modes.',
  })
  @IsOptional()
  @IsString()
  userId?: string;
}
