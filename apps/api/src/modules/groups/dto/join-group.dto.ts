import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class JoinGroupDto {
  @ApiProperty({ example: 'A1B2C3D4' })
  @IsString()
  @IsNotEmpty()
  code!: string;
}
