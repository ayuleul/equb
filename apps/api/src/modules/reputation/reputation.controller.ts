import { Controller, Get, Param, Query, UseGuards } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { SkipThrottle } from '@nestjs/throttler';

import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { ListReputationHistoryDto } from './dto/list-reputation-history.dto';
import {
  HostReputationSummaryDto,
  ReputationEligibilityResponseDto,
  ReputationHistoryResponseDto,
  ReputationProfileResponseDto,
} from './entities/reputation.entities';
import { ReputationService } from './reputation.service';

@ApiTags('Reputation')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@ApiUnauthorizedResponse({ description: 'Missing or invalid access token' })
@Controller()
export class ReputationController {
  constructor(private readonly reputationService: ReputationService) {}

  @Get('users/:id/reputation')
  @SkipThrottle()
  @ApiOperation({ summary: 'Get a user reputation profile' })
  @ApiOkResponse({ type: ReputationProfileResponseDto })
  @ApiNotFoundResponse({ description: 'User not found' })
  getUserReputation(
    @Param('id') userId: string,
  ): Promise<ReputationProfileResponseDto> {
    return this.reputationService.getProfile(userId);
  }

  @Get('users/:id/reputation/history')
  @SkipThrottle()
  @ApiOperation({ summary: 'Get paginated reputation history for a user' })
  @ApiOkResponse({ type: ReputationHistoryResponseDto })
  @ApiNotFoundResponse({ description: 'User not found' })
  getUserReputationHistory(
    @Param('id') userId: string,
    @Query() query: ListReputationHistoryDto,
  ): Promise<ReputationHistoryResponseDto> {
    return this.reputationService.getHistory(userId, query);
  }

  @Get('users/:id/reputation/eligibility')
  @SkipThrottle()
  @ApiOperation({ summary: 'Get reputation-driven eligibility summary for a user' })
  @ApiOkResponse({ type: ReputationEligibilityResponseDto })
  @ApiNotFoundResponse({ description: 'User not found' })
  getUserEligibility(
    @Param('id') userId: string,
  ): Promise<ReputationEligibilityResponseDto> {
    return this.reputationService.getEligibility(userId);
  }

  @Get('hosts/:id/reputation-summary')
  @SkipThrottle()
  @ApiOperation({ summary: 'Get host reputation summary' })
  @ApiOkResponse({ type: HostReputationSummaryDto })
  @ApiNotFoundResponse({ description: 'User not found' })
  getHostSummary(
    @Param('id') userId: string,
  ): Promise<HostReputationSummaryDto> {
    return this.reputationService.getHostSummary(userId);
  }
}
