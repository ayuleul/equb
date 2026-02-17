import { ApiProperty } from '@nestjs/swagger';

export class AuthUserResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  phone!: string;

  @ApiProperty({ required: false, nullable: true })
  fullName!: string | null;
}

export class RequestOtpResponseDto {
  @ApiProperty({ example: 'OTP sent' })
  message!: string;
}

export class AuthTokensResponseDto {
  @ApiProperty()
  accessToken!: string;

  @ApiProperty()
  refreshToken!: string;

  @ApiProperty({ type: () => AuthUserResponseDto })
  user!: AuthUserResponseDto;
}

export class LogoutResponseDto {
  @ApiProperty({ example: true })
  success!: boolean;
}
