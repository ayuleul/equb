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
  ApiBearerAuth,
  ApiBody,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
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

@ApiTags('contributions')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller()
export class ContributionsController {
  constructor(private readonly contributionsService: ContributionsService) {}

  @Post('cycles/:cycleId/contributions')
  @ApiOperation({
    summary: 'Submit or resubmit contribution for an open cycle',
  })
  @ApiBody({ type: SubmitContributionDto })
  @ApiOkResponse({ type: ContributionResponseDto })
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

  @Patch('contributions/:id/confirm')
  @UseGuards(GroupAdminGuard)
  @ApiOperation({ summary: 'Confirm a submitted contribution' })
  @ApiBody({ type: ConfirmContributionDto })
  @ApiOkResponse({ type: ContributionResponseDto })
  confirmContribution(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) contributionId: string,
    @Body() dto: ConfirmContributionDto,
  ): Promise<ContributionResponseDto> {
    return this.contributionsService.confirmContribution(
      currentUser,
      contributionId,
      dto,
    );
  }

  @Patch('contributions/:id/reject')
  @UseGuards(GroupAdminGuard)
  @ApiOperation({ summary: 'Reject a submitted contribution' })
  @ApiBody({ type: RejectContributionDto })
  @ApiOkResponse({ type: ContributionResponseDto })
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
  @ApiOperation({
    summary: 'List cycle contributions and summary for group members',
  })
  @ApiOkResponse({ type: ContributionListResponseDto })
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
