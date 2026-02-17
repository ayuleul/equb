import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, Length, Matches } from 'class-validator';

export class VerifyOtpDto {
  @ApiProperty({ example: '+251911223344' })
  @IsString()
  @IsNotEmpty()
  @Matches(/^\+?[1-9]\d{7,14}$/)
  phone!: string;

  @ApiProperty({ example: '123456' })
  @IsString()
  @Length(4, 8)
  code!: string;
}
