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
import { ConfirmPayoutDto } from './dto/confirm-payout.dto';
import { CreatePayoutDto } from './dto/create-payout.dto';
import { PayoutResponseDto } from './entities/payouts.entities';
import { PayoutsService } from './payouts.service';

@ApiTags('payouts')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller()
export class PayoutsController {
  constructor(private readonly payoutsService: PayoutsService) {}

  @Post('cycles/:cycleId/payout')
  @UseGuards(GroupAdminGuard)
  @ApiOperation({ summary: 'Create payout for an open cycle' })
  @ApiBody({ type: CreatePayoutDto, required: false })
  @ApiOkResponse({ type: PayoutResponseDto })
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
  confirmPayout(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) payoutId: string,
    @Body() dto: ConfirmPayoutDto,
  ): Promise<PayoutResponseDto> {
    return this.payoutsService.confirmPayout(currentUser, payoutId, dto);
  }

  @Post('cycles/:cycleId/close')
  @UseGuards(GroupAdminGuard)
  @ApiOperation({ summary: 'Close cycle after payout is confirmed' })
  @ApiOkResponse({
    schema: {
      type: 'object',
      properties: {
        success: { type: 'boolean', example: true },
      },
    },
  })
  closeCycle(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('cycleId', new ParseUUIDPipe()) cycleId: string,
  ): Promise<{ success: true }> {
    return this.payoutsService.closeCycle(currentUser, cycleId);
  }

  @Get('cycles/:cycleId/payout')
  @UseGuards(GroupMemberGuard)
  @ApiOperation({ summary: 'Get payout for cycle if available' })
  @ApiOkResponse({ type: PayoutResponseDto })
  getCyclePayout(
    @Param('cycleId', new ParseUUIDPipe()) cycleId: string,
  ): Promise<PayoutResponseDto | null> {
    return this.payoutsService.getCyclePayout(cycleId);
  }
}
