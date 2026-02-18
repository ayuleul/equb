import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class RejectContributionDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  reason!: string;
}
