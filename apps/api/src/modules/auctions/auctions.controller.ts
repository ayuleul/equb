import {
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Post,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBadRequestResponse,
  ApiBearerAuth,
  ApiForbiddenResponse,
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';

import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { GroupMemberGuard } from '../../common/guards/group-member.guard';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import { SubmitBidDto } from './dto/submit-bid.dto';
import {
  CycleAuctionStateResponseDto,
  CycleBidResponseDto,
} from './entities/auctions.entities';
import { AuctionsService } from './auctions.service';

@ApiTags('Auction')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, GroupMemberGuard)
@ApiUnauthorizedResponse({ description: 'Missing or invalid access token' })
@Controller('cycles')
export class AuctionsController {
  constructor(private readonly auctionsService: AuctionsService) {}

  @Post(':cycleId/auction/open')
  @ApiOperation({ summary: 'Open auction for the current cycle turn' })
  @ApiOkResponse({ type: CycleAuctionStateResponseDto })
  @ApiForbiddenResponse({
    description:
      'Only scheduled recipient or active admin can open auction for the cycle',
  })
  @ApiBadRequestResponse({
    description: 'Cycle is closed or auction is already opened/closed',
  })
  @ApiNotFoundResponse({ description: 'Cycle not found' })
  openAuction(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('cycleId', new ParseUUIDPipe()) cycleId: string,
  ): Promise<CycleAuctionStateResponseDto> {
    return this.auctionsService.openAuction(currentUser, cycleId);
  }

  @Post(':cycleId/auction/close')
  @ApiOperation({ summary: 'Close auction and select final cycle recipient' })
  @ApiOkResponse({ type: CycleAuctionStateResponseDto })
  @ApiForbiddenResponse({
    description:
      'Only scheduled recipient or active admin can close auction for the cycle',
  })
  @ApiBadRequestResponse({
    description: 'Cycle is closed or auction is not open',
  })
  @ApiNotFoundResponse({ description: 'Cycle not found' })
  closeAuction(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('cycleId', new ParseUUIDPipe()) cycleId: string,
  ): Promise<CycleAuctionStateResponseDto> {
    return this.auctionsService.closeAuction(currentUser, cycleId);
  }

  @Post(':cycleId/bids')
  @ApiTags('Bids')
  @ApiOperation({ summary: 'Submit or update your bid for an open cycle auction' })
  @ApiOkResponse({ type: CycleBidResponseDto })
  @ApiBadRequestResponse({
    description: 'Cycle is closed or auction is not open',
  })
  @ApiNotFoundResponse({ description: 'Cycle not found' })
  submitBid(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('cycleId', new ParseUUIDPipe()) cycleId: string,
    @Body() dto: SubmitBidDto,
  ): Promise<CycleBidResponseDto> {
    return this.auctionsService.submitBid(currentUser, cycleId, dto);
  }

  @Get(':cycleId/bids')
  @ApiTags('Bids')
  @ApiOperation({
    summary:
      'List bids for a cycle. Admin/scheduled recipient can see all bids; other members see only their own bid.',
  })
  @ApiOkResponse({ type: CycleBidResponseDto, isArray: true })
  @ApiNotFoundResponse({ description: 'Cycle not found' })
  listBids(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('cycleId', new ParseUUIDPipe()) cycleId: string,
  ): Promise<CycleBidResponseDto[]> {
    return this.auctionsService.listBids(currentUser, cycleId);
  }
}
