import {
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
  Put,
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
import { SkipThrottle } from '@nestjs/throttler';

import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { GroupAdminGuard } from '../../common/guards/group-admin.guard';
import { GroupMemberGuard } from '../../common/guards/group-member.guard';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import { CreateGroupDto } from './dto/create-group.dto';
import { CreateInviteDto } from './dto/create-invite.dto';
import { CreateJoinRequestDto } from './dto/create-join-request.dto';
import { JoinGroupDto } from './dto/join-group.dto';
import { ListDiscoverGroupsDto } from './dto/list-discover-groups.dto';
import { UpdateGroupDto } from './dto/update-group.dto';
import { UpdateGroupRulesDto } from './dto/update-group-rules.dto';
import { UpdateMemberRoleDto } from './dto/update-member-role.dto';
import { UpdateMemberStatusDto } from './dto/update-member-status.dto';
import {
  DiscoverGroupsResponseDto,
  GroupCycleResponseDto,
  GroupDetailResponseDto,
  GroupJoinResponseDto,
  GroupMemberResponseDto,
  GroupRulesResponseDto,
  GroupSummaryResponseDto,
  InviteCodeResponseDto,
  JoinRequestResponseDto,
  PublicGroupDetailResponseDto,
  PublicGroupSummaryResponseDto,
} from './entities/groups.entities';
import { GroupsDiscoverService } from './groups-discover.service';
import { GroupsService } from './groups.service';
import { GroupTrustSummaryDto } from '../reputation/entities/reputation.entities';

@ApiTags('Groups')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@ApiUnauthorizedResponse({ description: 'Missing or invalid access token' })
@Controller('groups')
export class GroupsController {
  constructor(
    private readonly groupsService: GroupsService,
    private readonly groupsDiscoverService: GroupsDiscoverService,
  ) {}

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
    summary: 'List groups where current user is a joined member',
  })
  @ApiOkResponse({ type: GroupSummaryResponseDto, isArray: true })
  listGroups(
    @CurrentUser() currentUser: AuthenticatedUser,
  ): Promise<GroupSummaryResponseDto[]> {
    return this.groupsService.listGroups(currentUser);
  }

  @Get('public')
  @SkipThrottle()
  @ApiOperation({ summary: 'List discoverable public groups' })
  @ApiOkResponse({ type: PublicGroupSummaryResponseDto, isArray: true })
  listPublicGroups(
    @CurrentUser() currentUser: AuthenticatedUser,
  ): Promise<PublicGroupSummaryResponseDto[]> {
    return this.groupsService.listPublicGroups(currentUser);
  }

  @Get('discover')
  @SkipThrottle()
  @ApiOperation({ summary: 'List ranked public Equb discover sections' })
  @ApiOkResponse({ type: DiscoverGroupsResponseDto })
  discoverGroups(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Query() query: ListDiscoverGroupsDto,
  ): Promise<DiscoverGroupsResponseDto> {
    return this.groupsDiscoverService.listDiscoverSections(currentUser, query);
  }

  @Get('public/:groupId')
  @SkipThrottle()
  @ApiOperation({ summary: 'Get discoverable public group detail' })
  @ApiOkResponse({ type: PublicGroupDetailResponseDto })
  @ApiNotFoundResponse({ description: 'Public group not found' })
  getPublicGroup(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('groupId', new ParseUUIDPipe()) groupId: string,
  ): Promise<PublicGroupDetailResponseDto> {
    return this.groupsService.getPublicGroupDetails(currentUser, groupId);
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
      'Group is locked while a cycle is open or invite became unavailable',
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
      'Group is locked while a cycle is open or invite became unavailable',
  })
  acceptInvite(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) groupId: string,
    @Param('code') code: string,
  ): Promise<GroupJoinResponseDto> {
    return this.groupsService.acceptInvite(currentUser, groupId, code);
  }

  @Post(':id/join-requests')
  @ApiOperation({ summary: 'Request to join a public group' })
  @ApiBody({ type: CreateJoinRequestDto })
  @ApiOkResponse({ type: JoinRequestResponseDto })
  @ApiBadRequestResponse({
    description: 'Group is not public or already joined',
  })
  @ApiConflictResponse({
    description:
      'Open request already exists or the group is currently in progress',
  })
  @ApiNotFoundResponse({ description: 'Group not found' })
  createJoinRequest(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) groupId: string,
    @Body() dto: CreateJoinRequestDto,
  ): Promise<JoinRequestResponseDto> {
    return this.groupsService.createJoinRequest(currentUser, groupId, dto);
  }

  @Get(':id/join-request/me')
  @SkipThrottle()
  @ApiOperation({
    summary: "Get current user's join request for a public group",
  })
  @ApiOkResponse({ type: JoinRequestResponseDto })
  @ApiNotFoundResponse({ description: 'Group not found' })
  getMyJoinRequest(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) groupId: string,
  ): Promise<JoinRequestResponseDto | null> {
    return this.groupsService.getMyJoinRequest(currentUser, groupId);
  }

  @Get(':id/join-requests')
  @UseGuards(GroupAdminGuard)
  @SkipThrottle()
  @ApiOperation({ summary: 'List pending join requests for a group' })
  @ApiOkResponse({ type: JoinRequestResponseDto, isArray: true })
  @ApiForbiddenResponse({ description: 'Joined admin membership required' })
  @ApiNotFoundResponse({ description: 'Group not found' })
  listJoinRequests(
    @Param('id', new ParseUUIDPipe()) groupId: string,
  ): Promise<JoinRequestResponseDto[]> {
    return this.groupsService.listJoinRequests(groupId);
  }

  @Post(':id/join-requests/:joinRequestId/approve')
  @UseGuards(GroupAdminGuard)
  @ApiOperation({ summary: 'Approve a join request' })
  @ApiOkResponse({ type: JoinRequestResponseDto })
  @ApiForbiddenResponse({ description: 'Joined admin membership required' })
  @ApiConflictResponse({ description: 'Join request cannot be approved' })
  @ApiNotFoundResponse({ description: 'Join request not found' })
  approveJoinRequest(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) groupId: string,
    @Param('joinRequestId') joinRequestId: string,
  ): Promise<JoinRequestResponseDto> {
    return this.groupsService.approveJoinRequest(
      currentUser,
      groupId,
      joinRequestId,
    );
  }

  @Post(':id/join-requests/:joinRequestId/reject')
  @UseGuards(GroupAdminGuard)
  @ApiOperation({ summary: 'Reject a join request' })
  @ApiOkResponse({ type: JoinRequestResponseDto })
  @ApiForbiddenResponse({ description: 'Joined admin membership required' })
  @ApiConflictResponse({ description: 'Join request cannot be rejected' })
  @ApiNotFoundResponse({ description: 'Join request not found' })
  rejectJoinRequest(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) groupId: string,
    @Param('joinRequestId') joinRequestId: string,
  ): Promise<JoinRequestResponseDto> {
    return this.groupsService.rejectJoinRequest(
      currentUser,
      groupId,
      joinRequestId,
    );
  }

  @Get(':id')
  @UseGuards(GroupMemberGuard)
  @SkipThrottle()
  @ApiTags('Members')
  @ApiOperation({ summary: 'Get group details for current member' })
  @ApiOkResponse({ type: GroupDetailResponseDto })
  @ApiForbiddenResponse({ description: 'Joined group membership required' })
  @ApiNotFoundResponse({ description: 'Group or membership not found' })
  getGroup(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) groupId: string,
  ): Promise<GroupDetailResponseDto> {
    return this.groupsService.getGroupDetails(currentUser, groupId);
  }

  @Patch(':id')
  @UseGuards(GroupAdminGuard)
  @ApiOperation({ summary: 'Update editable group metadata' })
  @ApiBody({ type: UpdateGroupDto })
  @ApiOkResponse({ type: GroupDetailResponseDto })
  @ApiForbiddenResponse({ description: 'Joined admin membership required' })
  @ApiBadRequestResponse({
    description: 'No supported group fields were provided',
  })
  @ApiNotFoundResponse({ description: 'Group not found' })
  updateGroup(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) groupId: string,
    @Body() dto: UpdateGroupDto,
  ): Promise<GroupDetailResponseDto> {
    return this.groupsService.updateGroup(currentUser, groupId, dto);
  }

  @Get(':id/rules')
  @UseGuards(GroupMemberGuard)
  @SkipThrottle()
  @ApiTags('Rules')
  @ApiOperation({ summary: 'Get group ruleset' })
  @ApiOkResponse({
    type: GroupRulesResponseDto,
    description:
      'Returns the configured ruleset, or null when the group exists but rules are not configured yet',
  })
  @ApiForbiddenResponse({ description: 'Joined group membership required' })
  @ApiNotFoundResponse({ description: 'Group not found' })
  getGroupRules(
    @Param('id', new ParseUUIDPipe()) groupId: string,
  ): Promise<GroupRulesResponseDto | null> {
    return this.groupsService.getGroupRules(groupId);
  }

  @Put(':id/rules')
  @UseGuards(GroupAdminGuard)
  @ApiTags('Rules')
  @ApiOperation({ summary: 'Create or update group ruleset' })
  @ApiBody({ type: UpdateGroupRulesDto })
  @ApiOkResponse({ type: GroupRulesResponseDto })
  @ApiForbiddenResponse({ description: 'Joined admin membership required' })
  @ApiBadRequestResponse({ description: 'Invalid rules configuration' })
  @ApiNotFoundResponse({ description: 'Group not found' })
  updateGroupRules(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) groupId: string,
    @Body() dto: UpdateGroupRulesDto,
  ): Promise<GroupRulesResponseDto> {
    return this.groupsService.updateGroupRules(currentUser, groupId, dto);
  }

  @Post(':id/invites')
  @UseGuards(GroupAdminGuard)
  @ApiOperation({ summary: 'Create invite code for group' })
  @ApiBody({ type: CreateInviteDto })
  @ApiOkResponse({ type: InviteCodeResponseDto })
  @ApiForbiddenResponse({ description: 'Joined admin membership required' })
  @ApiBadRequestResponse({ description: 'Invalid invite constraints' })
  @ApiConflictResponse({
    description: 'Ruleset must be configured before creating invites',
  })
  @ApiNotFoundResponse({ description: 'Group not found' })
  createInvite(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) groupId: string,
    @Body() dto: CreateInviteDto,
  ): Promise<InviteCodeResponseDto> {
    return this.groupsService.createInvite(currentUser, groupId, dto);
  }

  @Post(':id/invite')
  @UseGuards(GroupAdminGuard)
  @ApiOperation({
    summary: 'Create invite code for group (legacy compatibility route)',
  })
  @ApiBody({ type: CreateInviteDto })
  @ApiOkResponse({ type: InviteCodeResponseDto })
  @ApiForbiddenResponse({ description: 'Joined admin membership required' })
  @ApiBadRequestResponse({ description: 'Invalid invite constraints' })
  @ApiConflictResponse({
    description: 'Ruleset must be configured before creating invites',
  })
  @ApiNotFoundResponse({ description: 'Group not found' })
  createInviteLegacy(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) groupId: string,
    @Body() dto: CreateInviteDto,
  ): Promise<InviteCodeResponseDto> {
    return this.groupsService.createInvite(currentUser, groupId, dto);
  }

  @Get(':id/members')
  @UseGuards(GroupMemberGuard)
  @SkipThrottle()
  @ApiTags('Members')
  @ApiOperation({ summary: 'List members in a group' })
  @ApiOkResponse({ type: GroupMemberResponseDto, isArray: true })
  @ApiForbiddenResponse({ description: 'Joined group membership required' })
  listMembers(
    @Param('id', new ParseUUIDPipe()) groupId: string,
  ): Promise<GroupMemberResponseDto[]> {
    return this.groupsService.listMembers(groupId);
  }

  @Get(':id/members/reputation')
  @UseGuards(GroupMemberGuard)
  @SkipThrottle()
  @ApiTags('Members')
  @ApiOperation({
    summary: 'List members with reliability summaries for a group',
  })
  @ApiOkResponse({ type: GroupMemberResponseDto, isArray: true })
  @ApiForbiddenResponse({ description: 'Joined group membership required' })
  listMemberReputations(
    @Param('id', new ParseUUIDPipe()) groupId: string,
  ): Promise<GroupMemberResponseDto[]> {
    return this.groupsService.listMembers(groupId);
  }

  @Get(':id/trust-summary')
  @SkipThrottle()
  @ApiOperation({ summary: 'Get aggregated trust summary for a group' })
  @ApiOkResponse({ type: GroupTrustSummaryDto })
  @ApiNotFoundResponse({ description: 'Group not found' })
  getGroupTrustSummary(
    @Param('id', new ParseUUIDPipe()) groupId: string,
  ): Promise<GroupTrustSummaryDto> {
    return this.groupsService.getGroupTrustSummary(groupId);
  }

  @Post(':id/members/:memberId/verify')
  @UseGuards(GroupAdminGuard)
  @ApiTags('Members')
  @ApiOperation({ summary: 'Verify a joined member in a group' })
  @ApiOkResponse({ type: GroupMemberResponseDto })
  @ApiForbiddenResponse({ description: 'Joined admin membership required' })
  @ApiBadRequestResponse({ description: 'Member cannot be verified' })
  @ApiNotFoundResponse({ description: 'Member not found in group' })
  verifyMember(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) groupId: string,
    @Param('memberId', new ParseUUIDPipe()) memberId: string,
  ): Promise<GroupMemberResponseDto> {
    return this.groupsService.verifyMember(currentUser, groupId, memberId);
  }

  @Patch(':id/members/:userId/role')
  @UseGuards(GroupAdminGuard)
  @ApiTags('Members')
  @ApiOperation({ summary: 'Update member role in a group' })
  @ApiBody({ type: UpdateMemberRoleDto })
  @ApiOkResponse({ type: GroupMemberResponseDto })
  @ApiForbiddenResponse({ description: 'Joined admin membership required' })
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

  @Post(':id/cycles/start')
  @UseGuards(GroupAdminGuard)
  @ApiTags('Cycles')
  @ApiOperation({
    summary:
      'Start a new cycle and create contribution due rows for eligible members',
  })
  @ApiOkResponse({ type: GroupCycleResponseDto })
  @ApiForbiddenResponse({ description: 'Joined admin membership required' })
  @ApiBadRequestResponse({
    description: 'Cycle start prerequisites are not satisfied',
  })
  @ApiConflictResponse({
    description: 'Open cycle already exists or ruleset is missing',
  })
  @ApiNotFoundResponse({ description: 'Group not found' })
  startCycle(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) groupId: string,
  ): Promise<GroupCycleResponseDto> {
    return this.groupsService.startCycle(currentUser, groupId);
  }

  @Get(':id/cycles/current')
  @UseGuards(GroupMemberGuard)
  @SkipThrottle()
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
  @SkipThrottle()
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
  @SkipThrottle()
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
