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
import { ConfirmPayoutDto } from './dto/confirm-payout.dto';
import { CloseCycleDto } from './dto/close-cycle.dto';
import { CreatePayoutDto } from './dto/create-payout.dto';
import { DisbursePayoutDto } from './dto/disburse-payout.dto';
import { SelectWinnerDto } from './dto/select-winner.dto';
import { GroupCycleResponseDto } from '../groups/entities/groups.entities';
import {
  CloseCycleResponseDto,
  PayoutResponseDto,
} from './entities/payouts.entities';
import { PayoutsService } from './payouts.service';

@ApiTags('Payouts')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@ApiUnauthorizedResponse({ description: 'Missing or invalid access token' })
@Controller()
export class PayoutsController {
  constructor(private readonly payoutsService: PayoutsService) {}

  @Post('cycles/:cycleId/winner/select')
  @UseGuards(GroupAdminGuard)
  @ApiOperation({ summary: 'Select payout winner for cycle based on ruleset' })
  @ApiBody({ type: SelectWinnerDto, required: false })
  @ApiOkResponse({ type: GroupCycleResponseDto })
  @ApiForbiddenResponse({ description: 'Active admin membership required' })
  @ApiBadRequestResponse({
    description: 'Cycle is not ready or winner selection input is invalid',
  })
  @ApiNotFoundResponse({ description: 'Cycle not found' })
  selectWinner(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('cycleId', new ParseUUIDPipe()) cycleId: string,
    @Body() dto: SelectWinnerDto,
  ): Promise<GroupCycleResponseDto> {
    return this.payoutsService.selectWinner(currentUser, cycleId, dto);
  }

  @Post('cycles/:cycleId/payout/disburse')
  @UseGuards(GroupAdminGuard)
  @ApiOperation({
    summary:
      'Disburse payout for selected winner, create payout row, and ledger entry',
  })
  @ApiBody({ type: DisbursePayoutDto, required: false })
  @ApiOkResponse({ type: PayoutResponseDto })
  @ApiForbiddenResponse({ description: 'Active admin membership required' })
  @ApiBadRequestResponse({
    description: 'Winner is not selected or disbursement prerequisites failed',
  })
  @ApiNotFoundResponse({ description: 'Cycle not found' })
  disbursePayout(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('cycleId', new ParseUUIDPipe()) cycleId: string,
    @Body() dto: DisbursePayoutDto,
  ): Promise<PayoutResponseDto> {
    return this.payoutsService.disbursePayout(currentUser, cycleId, dto);
  }

  @Post('cycles/:cycleId/payout')
  @UseGuards(GroupAdminGuard)
  @ApiOperation({ summary: 'Create payout for an open cycle' })
  @ApiBody({ type: CreatePayoutDto, required: false })
  @ApiOkResponse({ type: PayoutResponseDto })
  @ApiForbiddenResponse({ description: 'Active admin membership required' })
  @ApiBadRequestResponse({
    description: 'Cycle closed, payout already exists, or invalid proof scope',
  })
  @ApiNotFoundResponse({ description: 'Cycle not found' })
  createPayout(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('cycleId', new ParseUUIDPipe()) cycleId: string,
    @Body() dto: CreatePayoutDto,
  ): Promise<PayoutResponseDto> {
    return this.payoutsService.createPayout(currentUser, cycleId, dto);
  }

  @Patch('payouts/:id/confirm')
  @UseGuards(GroupAdminGuard)
  @ApiOperation({ summary: 'Confirm a pending payout' })
  @ApiBody({ type: ConfirmPayoutDto, required: false })
  @ApiOkResponse({ type: PayoutResponseDto })
  @ApiForbiddenResponse({ description: 'Active admin membership required' })
  @ApiBadRequestResponse({
    description: 'Payout state or strict payout checks failed',
  })
  @ApiNotFoundResponse({ description: 'Payout not found' })
  confirmPayout(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) payoutId: string,
    @Body() dto: ConfirmPayoutDto,
  ): Promise<PayoutResponseDto> {
    return this.payoutsService.confirmPayout(currentUser, payoutId, dto);
  }

  @Post('cycles/:cycleId/close')
  @UseGuards(GroupAdminGuard)
  @ApiOperation({
    summary: 'Close cycle after payout is disbursed and optionally auto-start next',
  })
  @ApiBody({ type: CloseCycleDto, required: false })
  @ApiOkResponse({ type: CloseCycleResponseDto })
  @ApiForbiddenResponse({ description: 'Active admin membership required' })
  @ApiBadRequestResponse({
    description: 'Cycle is closed or payout is not confirmed',
  })
  @ApiNotFoundResponse({ description: 'Cycle not found' })
  closeCycle(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('cycleId', new ParseUUIDPipe()) cycleId: string,
    @Body() dto: CloseCycleDto,
  ): Promise<CloseCycleResponseDto> {
    return this.payoutsService.closeCycle(currentUser, cycleId, dto);
  }

  @Get('cycles/:cycleId/payout')
  @UseGuards(GroupMemberGuard)
  @ApiTags('Cycles')
  @ApiOperation({ summary: 'Get payout for cycle if available' })
  @ApiOkResponse({ type: PayoutResponseDto })
  @ApiForbiddenResponse({ description: 'Active group membership required' })
  @ApiNotFoundResponse({ description: 'Cycle not found' })
  getCyclePayout(
    @Param('cycleId', new ParseUUIDPipe()) cycleId: string,
  ): Promise<PayoutResponseDto | null> {
    return this.payoutsService.getCyclePayout(cycleId);
  }
}
