import {
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBadRequestResponse,
  ApiBearerAuth,
  ApiBody,
  ApiForbiddenResponse,
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';

import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { GroupAdminGuard } from '../../common/guards/group-admin.guard';
import { GroupMemberGuard } from '../../common/guards/group-member.guard';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import { ConfirmContributionDto } from './dto/confirm-contribution.dto';
import { RejectContributionDto } from './dto/reject-contribution.dto';
import { SubmitContributionDto } from './dto/submit-contribution.dto';
import {
  ContributionListResponseDto,
  ContributionResponseDto,
} from './entities/contributions.entities';
import { ContributionsService } from './contributions.service';

@ApiTags('Contributions')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@ApiUnauthorizedResponse({ description: 'Missing or invalid access token' })
@Controller()
export class ContributionsController {
  constructor(private readonly contributionsService: ContributionsService) {}

  @Post('cycles/:cycleId/contributions/submit')
  @ApiOperation({
    summary: 'Submit contribution payment for a cycle due row',
  })
  @ApiBody({ type: SubmitContributionDto })
  @ApiOkResponse({ type: ContributionResponseDto })
  @ApiForbiddenResponse({
    description: 'Active membership required for the cycle group',
  })
  @ApiBadRequestResponse({
    description: 'Cycle closed or invalid proof key scope',
  })
  @ApiNotFoundResponse({ description: 'Cycle not found' })
  submitContribution(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('cycleId', new ParseUUIDPipe()) cycleId: string,
    @Body() dto: SubmitContributionDto,
  ): Promise<ContributionResponseDto> {
    return this.contributionsService.submitContribution(
      currentUser,
      cycleId,
      dto,
    );
  }

  @Post('cycles/:cycleId/contributions')
  @ApiOperation({
    summary:
      'Submit contribution payment for a cycle due row (legacy compatibility route)',
  })
  @ApiBody({ type: SubmitContributionDto })
  @ApiOkResponse({ type: ContributionResponseDto })
  @ApiForbiddenResponse({
    description: 'Active membership required for the cycle group',
  })
  @ApiBadRequestResponse({
    description: 'Cycle closed or invalid proof key scope',
  })
  @ApiNotFoundResponse({ description: 'Cycle not found' })
  submitContributionLegacy(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('cycleId', new ParseUUIDPipe()) cycleId: string,
    @Body() dto: SubmitContributionDto,
  ): Promise<ContributionResponseDto> {
    return this.contributionsService.submitContribution(
      currentUser,
      cycleId,
      dto,
    );
  }

  @Post('contributions/:id/verify')
  @UseGuards(GroupAdminGuard)
  @ApiOperation({ summary: 'Verify a paid contribution' })
  @ApiBody({ type: ConfirmContributionDto, required: false })
  @ApiOkResponse({ type: ContributionResponseDto })
  @ApiForbiddenResponse({ description: 'Active admin membership required' })
  @ApiBadRequestResponse({
    description: 'Only PAID_SUBMITTED contributions can be verified',
  })
  @ApiNotFoundResponse({ description: 'Contribution not found' })
  verifyContribution(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) contributionId: string,
    @Body() dto: ConfirmContributionDto,
  ): Promise<ContributionResponseDto> {
    return this.contributionsService.verifyContribution(
      currentUser,
      contributionId,
      dto.note,
    );
  }

  @Patch('contributions/:id/confirm')
  @UseGuards(GroupAdminGuard)
  @ApiOperation({
    summary: 'Confirm a submitted contribution (legacy compatibility route)',
  })
  @ApiBody({ type: ConfirmContributionDto })
  @ApiOkResponse({ type: ContributionResponseDto })
  @ApiForbiddenResponse({ description: 'Active admin membership required' })
  @ApiBadRequestResponse({
    description: 'Only SUBMITTED contributions can be confirmed',
  })
  @ApiNotFoundResponse({ description: 'Contribution not found' })
  confirmContribution(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) contributionId: string,
    @Body() dto: ConfirmContributionDto,
  ): Promise<ContributionResponseDto> {
    return this.contributionsService.verifyContribution(
      currentUser,
      contributionId,
      dto.note,
    );
  }

  @Patch('contributions/:id/reject')
  @UseGuards(GroupAdminGuard)
  @ApiOperation({ summary: 'Reject a submitted contribution' })
  @ApiBody({ type: RejectContributionDto })
  @ApiOkResponse({ type: ContributionResponseDto })
  @ApiForbiddenResponse({ description: 'Active admin membership required' })
  @ApiBadRequestResponse({
    description: 'Only SUBMITTED contributions can be rejected',
  })
  @ApiNotFoundResponse({ description: 'Contribution not found' })
  rejectContribution(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) contributionId: string,
    @Body() dto: RejectContributionDto,
  ): Promise<ContributionResponseDto> {
    return this.contributionsService.rejectContribution(
      currentUser,
      contributionId,
      dto,
    );
  }

  @Get('groups/:id/cycles/:cycleId/contributions')
  @UseGuards(GroupMemberGuard)
  @ApiTags('Cycles')
  @ApiOperation({
    summary: 'List cycle contributions and summary for group members',
  })
  @ApiOkResponse({ type: ContributionListResponseDto })
  @ApiForbiddenResponse({ description: 'Active group membership required' })
  @ApiNotFoundResponse({ description: 'Group or cycle not found' })
  listCycleContributions(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) groupId: string,
    @Param('cycleId', new ParseUUIDPipe()) cycleId: string,
  ): Promise<ContributionListResponseDto> {
    return this.contributionsService.listCycleContributions(
      currentUser,
      groupId,
      cycleId,
    );
  }
}
