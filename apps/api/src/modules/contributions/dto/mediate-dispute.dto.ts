import { ApiProperty } from '@nestjs/swagger';
import { IsString, MaxLength, MinLength } from 'class-validator';

export class MediateDisputeDto {
  @ApiProperty({
    example: 'Admin requested an additional receipt image for verification.',
  })
  @IsString()
  @MinLength(3)
  @MaxLength(1000)
  note!: string;
}
