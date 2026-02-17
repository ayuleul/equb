import { Body, Controller, HttpCode, HttpStatus, Post } from '@nestjs/common';
import {
  ApiBody,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiTooManyRequestsResponse,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';

import { LogoutDto } from './dto/logout.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { RequestOtpDto } from './dto/request-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import {
  AuthTokensResponseDto,
  LogoutResponseDto,
  RequestOtpResponseDto,
} from './entities/auth.entities';
import { AuthService } from './auth.service';

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('request-otp')
  @HttpCode(HttpStatus.OK)
  @Throttle({ otp: { ttl: 60_000, limit: 5 } })
  @ApiOperation({ summary: 'Request OTP for login' })
  @ApiBody({ type: RequestOtpDto })
  @ApiOkResponse({ type: RequestOtpResponseDto })
  @ApiTooManyRequestsResponse({ description: 'Too many OTP requests' })
  requestOtp(@Body() dto: RequestOtpDto): Promise<RequestOtpResponseDto> {
    return this.authService.requestOtp(dto);
  }

  @Post('verify-otp')
  @HttpCode(HttpStatus.OK)
  @Throttle({ otp: { ttl: 60_000, limit: 10 } })
  @ApiOperation({ summary: 'Verify OTP and issue access/refresh tokens' })
  @ApiBody({ type: VerifyOtpDto })
  @ApiOkResponse({ type: AuthTokensResponseDto })
  @ApiUnauthorizedResponse({ description: 'Invalid or expired OTP' })
  @ApiTooManyRequestsResponse({ description: 'Too many verification attempts' })
  verifyOtp(@Body() dto: VerifyOtpDto): Promise<AuthTokensResponseDto> {
    return this.authService.verifyOtp(dto);
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Rotate refresh token and issue new token pair' })
  @ApiBody({ type: RefreshTokenDto })
  @ApiOkResponse({ type: AuthTokensResponseDto })
  @ApiUnauthorizedResponse({ description: 'Invalid refresh token' })
  refresh(@Body() dto: RefreshTokenDto): Promise<AuthTokensResponseDto> {
    return this.authService.refresh(dto);
  }

  @Post('logout')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Revoke refresh token' })
  @ApiBody({ type: LogoutDto })
  @ApiOkResponse({ type: LogoutResponseDto })
  logout(@Body() dto: LogoutDto): Promise<LogoutResponseDto> {
    return this.authService.logout(dto);
  }
}
