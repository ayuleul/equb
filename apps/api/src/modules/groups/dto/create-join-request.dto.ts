import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, MaxLength } from 'class-validator';

export class CreateJoinRequestDto {
  @ApiPropertyOptional({
    example: 'I would like to join your monthly family Equb.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  message?: string;
}
