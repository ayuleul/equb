import { ApiProperty } from '@nestjs/swagger';
import { IsInt, Min } from 'class-validator';

export class SubmitBidDto {
  @ApiProperty({ example: 500 })
  @IsInt()
  @Min(1)
  amount!: number;
}
