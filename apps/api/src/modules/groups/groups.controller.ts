import {
  Body,
  Controller,
  Get,
  Param,
  ParseArrayPipe,
  ParseUUIDPipe,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBadRequestResponse,
  ApiBearerAuth,
  ApiBody,
  ApiConflictResponse,
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
import { CreateGroupDto } from './dto/create-group.dto';
import { CreateInviteDto } from './dto/create-invite.dto';
import { GenerateCyclesDto } from './dto/generate-cycles.dto';
import { JoinGroupDto } from './dto/join-group.dto';
import { PayoutOrderItemDto } from './dto/payout-order-item.dto';
import { UpdateMemberRoleDto } from './dto/update-member-role.dto';
import { UpdateMemberStatusDto } from './dto/update-member-status.dto';
import {
  CurrentRoundScheduleResponseDto,
  GroupCycleResponseDto,
  GroupDetailResponseDto,
  GroupJoinResponseDto,
  GroupMemberResponseDto,
  GroupSummaryResponseDto,
  InviteCodeResponseDto,
  RoundSeedRevealResponseDto,
  RoundStartResponseDto,
} from './entities/groups.entities';
import { GroupsService } from './groups.service';

@ApiTags('Groups')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@ApiUnauthorizedResponse({ description: 'Missing or invalid access token' })
@Controller('groups')
export class GroupsController {
  constructor(private readonly groupsService: GroupsService) {}

  @Post()
  @ApiOperation({ summary: 'Create an Equb group' })
  @ApiBody({ type: CreateGroupDto })
  @ApiOkResponse({ type: GroupDetailResponseDto })
  createGroup(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Body() dto: CreateGroupDto,
  ): Promise<GroupDetailResponseDto> {
    return this.groupsService.createGroup(currentUser, dto);
  }

  @Get()
  @ApiOperation({
    summary: 'List groups where current user is an active member',
  })
  @ApiOkResponse({ type: GroupSummaryResponseDto, isArray: true })
  listGroups(
    @CurrentUser() currentUser: AuthenticatedUser,
  ): Promise<GroupSummaryResponseDto[]> {
    return this.groupsService.listGroups(currentUser);
  }

  @Post('join')
  @ApiOperation({ summary: 'Join a group with invite code' })
  @ApiBody({ type: JoinGroupDto })
  @ApiOkResponse({ type: GroupJoinResponseDto })
  @ApiBadRequestResponse({ description: 'Invite is invalid or unusable' })
  @ApiNotFoundResponse({ description: 'Invite code not found' })
  @ApiForbiddenResponse({ description: 'Removed members cannot self-rejoin' })
  @ApiConflictResponse({
    description:
      'Group is locked while a round is in progress or invite became unavailable',
  })
  joinGroup(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Body() dto: JoinGroupDto,
  ): Promise<GroupJoinResponseDto> {
    return this.groupsService.joinGroup(currentUser, dto);
  }

  @Post(':id/invites/:code/accept')
  @ApiOperation({ summary: 'Accept a group invite by code' })
  @ApiOkResponse({ type: GroupJoinResponseDto })
  @ApiBadRequestResponse({ description: 'Invite is invalid or unusable' })
  @ApiNotFoundResponse({ description: 'Invite code not found for group' })
  @ApiForbiddenResponse({ description: 'Removed members cannot self-rejoin' })
  @ApiConflictResponse({
    description:
      'Group is locked while a round is in progress or invite became unavailable',
  })
  acceptInvite(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) groupId: string,
    @Param('code') code: string,
  ): Promise<GroupJoinResponseDto> {
    return this.groupsService.acceptInvite(currentUser, groupId, code);
  }

  @Get(':id')
  @UseGuards(GroupMemberGuard)
  @ApiTags('Members')
  @ApiOperation({ summary: 'Get group details for current member' })
  @ApiOkResponse({ type: GroupDetailResponseDto })
  @ApiForbiddenResponse({ description: 'Active group membership required' })
  @ApiNotFoundResponse({ description: 'Group or membership not found' })
  getGroup(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) groupId: string,
  ): Promise<GroupDetailResponseDto> {
    return this.groupsService.getGroupDetails(currentUser, groupId);
  }

  @Post(':id/invite')
  @UseGuards(GroupAdminGuard)
  @ApiOperation({ summary: 'Create invite code for group' })
  @ApiBody({ type: CreateInviteDto })
  @ApiOkResponse({ type: InviteCodeResponseDto })
  @ApiForbiddenResponse({ description: 'Active admin membership required' })
  @ApiBadRequestResponse({ description: 'Invalid invite constraints' })
  @ApiNotFoundResponse({ description: 'Group not found' })
  createInvite(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) groupId: string,
    @Body() dto: CreateInviteDto,
  ): Promise<InviteCodeResponseDto> {
    return this.groupsService.createInvite(currentUser, groupId, dto);
  }

  @Get(':id/members')
  @UseGuards(GroupMemberGuard)
  @ApiTags('Members')
  @ApiOperation({ summary: 'List members in a group' })
  @ApiOkResponse({ type: GroupMemberResponseDto, isArray: true })
  @ApiForbiddenResponse({ description: 'Active group membership required' })
  listMembers(
    @Param('id', new ParseUUIDPipe()) groupId: string,
  ): Promise<GroupMemberResponseDto[]> {
    return this.groupsService.listMembers(groupId);
  }

  @Patch(':id/members/:userId/role')
  @UseGuards(GroupAdminGuard)
  @ApiTags('Members')
  @ApiOperation({ summary: 'Update member role in a group' })
  @ApiBody({ type: UpdateMemberRoleDto })
  @ApiOkResponse({ type: GroupMemberResponseDto })
  @ApiForbiddenResponse({ description: 'Active admin membership required' })
  @ApiBadRequestResponse({ description: 'Last active admin cannot be removed' })
  @ApiNotFoundResponse({ description: 'Member not found in group' })
  updateMemberRole(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) groupId: string,
    @Param('userId') targetUserId: string,
    @Body() dto: UpdateMemberRoleDto,
  ): Promise<GroupMemberResponseDto> {
    return this.groupsService.updateMemberRole(
      currentUser,
      groupId,
      targetUserId,
      dto,
    );
  }

  @Patch(':id/members/:userId/status')
  @ApiTags('Members')
  @ApiOperation({
    summary: 'Update member status (self leave or admin remove)',
  })
  @ApiBody({ type: UpdateMemberStatusDto })
  @ApiOkResponse({ type: GroupMemberResponseDto })
  @ApiForbiddenResponse({
    description: 'Only self-leave or admin remove is allowed',
  })
  @ApiBadRequestResponse({ description: 'Status transition rule violation' })
  @ApiNotFoundResponse({ description: 'Member not found in group' })
  updateMemberStatus(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) groupId: string,
    @Param('userId') targetUserId: string,
    @Body() dto: UpdateMemberStatusDto,
  ): Promise<GroupMemberResponseDto> {
    return this.groupsService.updateMemberStatus(
      currentUser,
      groupId,
      targetUserId,
      dto,
    );
  }

  @Patch(':id/payout-order')
  @UseGuards(GroupAdminGuard)
  @ApiTags('Cycles')
  @ApiOperation({ summary: 'Set payout order for active members' })
  @ApiBody({ type: PayoutOrderItemDto, isArray: true })
  @ApiOkResponse({ type: GroupMemberResponseDto, isArray: true })
  @ApiForbiddenResponse({ description: 'Active admin membership required' })
  @ApiBadRequestResponse({
    description: 'Payout positions must be contiguous and unique',
  })
  updatePayoutOrder(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) groupId: string,
    @Body(new ParseArrayPipe({ items: PayoutOrderItemDto }))
    payload: PayoutOrderItemDto[],
  ): Promise<GroupMemberResponseDto[]> {
    return this.groupsService.updatePayoutOrder(currentUser, groupId, payload);
  }

  @Post(':id/cycles/generate')
  @UseGuards(GroupAdminGuard)
  @ApiTags('Cycles')
  @ApiOperation({ summary: 'Generate next cycle (sequential only)' })
  @ApiBody({ type: GenerateCyclesDto, required: false })
  @ApiOkResponse({ type: GroupCycleResponseDto })
  @ApiForbiddenResponse({ description: 'Active admin membership required' })
  @ApiBadRequestResponse({
    description: 'Cycle generation constraints not satisfied',
  })
  @ApiConflictResponse({
    description: 'Open cycle already exists or round is completed',
  })
  @ApiNotFoundResponse({ description: 'Group not found' })
  generateCycles(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) groupId: string,
    @Body() dto: GenerateCyclesDto,
  ): Promise<GroupCycleResponseDto> {
    return this.groupsService.generateCycles(currentUser, groupId, dto);
  }

  @Post(':id/rounds/start')
  @UseGuards(GroupAdminGuard)
  @ApiTags('Rounds')
  @ApiOperation({ summary: 'Start a random-draw payout round and schedule' })
  @ApiOkResponse({ type: RoundStartResponseDto })
  @ApiForbiddenResponse({ description: 'Active admin membership required' })
  @ApiBadRequestResponse({
    description:
      'Group is inactive, round already active, or no active members',
  })
  @ApiNotFoundResponse({ description: 'Group not found' })
  startRound(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) groupId: string,
  ): Promise<RoundStartResponseDto> {
    return this.groupsService.startRound(currentUser, groupId);
  }

  @Get(':id/rounds/current/schedule')
  @UseGuards(GroupAdminGuard)
  @ApiTags('Rounds')
  @ApiOperation({ summary: 'Get current round payout schedule commitment' })
  @ApiOkResponse({ type: CurrentRoundScheduleResponseDto })
  @ApiForbiddenResponse({ description: 'Active admin membership required' })
  @ApiNotFoundResponse({ description: 'Active round not found' })
  getCurrentRoundSchedule(
    @Param('id', new ParseUUIDPipe()) groupId: string,
  ): Promise<CurrentRoundScheduleResponseDto> {
    return this.groupsService.getCurrentRoundSchedule(groupId);
  }

  @Post(':id/rounds/current/reveal-seed')
  @UseGuards(GroupAdminGuard)
  @ApiTags('Rounds')
  @ApiOperation({
    summary: 'Reveal current round seed for external schedule verification',
  })
  @ApiOkResponse({ type: RoundSeedRevealResponseDto })
  @ApiForbiddenResponse({ description: 'Active admin membership required' })
  @ApiBadRequestResponse({
    description: 'Seed reveal is unavailable for this round',
  })
  @ApiNotFoundResponse({ description: 'Active round not found' })
  revealCurrentRoundSeed(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) groupId: string,
  ): Promise<RoundSeedRevealResponseDto> {
    return this.groupsService.revealCurrentRoundSeed(currentUser, groupId);
  }

  @Post(':id/rounds/current/draw-next')
  @UseGuards(GroupAdminGuard)
  @ApiTags('Rounds')
  @ApiOperation({ summary: 'Draw next cycle recipient for current round' })
  @ApiOkResponse({ type: GroupCycleResponseDto })
  @ApiForbiddenResponse({ description: 'Active admin membership required' })
  @ApiBadRequestResponse({
    description: 'Cycle generation constraints not satisfied',
  })
  @ApiConflictResponse({
    description: 'Open cycle already exists or round is completed',
  })
  @ApiNotFoundResponse({ description: 'Group not found' })
  drawNextCycle(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) groupId: string,
  ): Promise<GroupCycleResponseDto> {
    return this.groupsService.drawNextCycle(currentUser, groupId);
  }

  @Get(':id/cycles/current')
  @UseGuards(GroupMemberGuard)
  @ApiTags('Cycles')
  @ApiOperation({ summary: 'Get current open cycle for a group' })
  @ApiOkResponse({ type: GroupCycleResponseDto })
  @ApiForbiddenResponse({ description: 'Active group membership required' })
  getCurrentCycle(
    @Param('id', new ParseUUIDPipe()) groupId: string,
  ): Promise<GroupCycleResponseDto | null> {
    return this.groupsService.getCurrentCycle(groupId);
  }

  @Get(':id/cycles/:cycleId')
  @UseGuards(GroupMemberGuard)
  @ApiTags('Cycles')
  @ApiOperation({ summary: 'Get cycle details by id' })
  @ApiOkResponse({ type: GroupCycleResponseDto })
  @ApiForbiddenResponse({ description: 'Active group membership required' })
  @ApiNotFoundResponse({ description: 'Cycle not found in group' })
  getCycleById(
    @Param('id', new ParseUUIDPipe()) groupId: string,
    @Param('cycleId', new ParseUUIDPipe()) cycleId: string,
  ): Promise<GroupCycleResponseDto> {
    return this.groupsService.getCycleById(groupId, cycleId);
  }

  @Get(':id/cycles')
  @UseGuards(GroupMemberGuard)
  @ApiTags('Cycles')
  @ApiOperation({ summary: 'List cycles for a group' })
  @ApiOkResponse({ type: GroupCycleResponseDto, isArray: true })
  @ApiForbiddenResponse({ description: 'Active group membership required' })
  listCycles(
    @Param('id', new ParseUUIDPipe()) groupId: string,
  ): Promise<GroupCycleResponseDto[]> {
    return this.groupsService.listCycles(groupId);
  }
}
