import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional } from 'class-validator';

export class GenerateCyclesDto {
  @ApiPropertyOptional({
    deprecated: true,
    description:
      'Deprecated. Cycle generation is sequential and always creates exactly one next cycle.',
  })
  @IsOptional()
  count?: unknown;
}
