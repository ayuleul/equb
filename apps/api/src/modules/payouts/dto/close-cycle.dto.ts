import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsBoolean, IsOptional } from 'class-validator';

export class CloseCycleDto {
  @ApiPropertyOptional({
    description:
      'When true, API attempts to start the next cycle immediately after closure.',
    default: false,
  })
  @IsOptional()
  @IsBoolean()
  autoNext?: boolean;
}
