import { Body, Controller, Get, Patch, UseGuards } from '@nestjs/common';
import {
  ApiBadRequestResponse,
  ApiBearerAuth,
  ApiBody,
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';

import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { MeResponseDto } from './entities/me.entities';
import { MeService } from './me.service';

@ApiTags('Users')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@ApiUnauthorizedResponse({ description: 'Missing or invalid access token' })
@Controller('me')
export class MeController {
  constructor(private readonly meService: MeService) {}

  @Get()
  @ApiOperation({ summary: 'Get current authenticated user profile' })
  @ApiOkResponse({ type: MeResponseDto })
  @ApiNotFoundResponse({ description: 'User not found' })
  getMe(@CurrentUser() currentUser: AuthenticatedUser): Promise<MeResponseDto> {
    return this.meService.getMe(currentUser);
  }

  @Patch('profile')
  @ApiOperation({
    summary: 'Complete or update required Ethiopian-style profile names',
  })
  @ApiBody({ type: UpdateProfileDto })
  @ApiOkResponse({ type: MeResponseDto })
  @ApiBadRequestResponse({ description: 'Invalid name payload' })
  @ApiNotFoundResponse({ description: 'User not found' })
  updateProfile(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Body() dto: UpdateProfileDto,
  ): Promise<MeResponseDto> {
    return this.meService.updateProfile(currentUser, dto);
  }
}
