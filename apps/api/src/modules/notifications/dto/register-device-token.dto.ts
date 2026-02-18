import { ApiProperty } from '@nestjs/swagger';
import { Platform } from '@prisma/client';
import { IsEnum, IsNotEmpty, IsString, MaxLength } from 'class-validator';

export class RegisterDeviceTokenDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  @MaxLength(2048)
  token!: string;

  @ApiProperty({ enum: Platform })
  @IsEnum(Platform)
  platform!: Platform;
}
