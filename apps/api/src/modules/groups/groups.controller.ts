import {
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
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

import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { GroupAdminGuard } from '../../common/guards/group-admin.guard';
import { GroupMemberGuard } from '../../common/guards/group-member.guard';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import { CreateGroupDto } from './dto/create-group.dto';
import { CreateInviteDto } from './dto/create-invite.dto';
import { JoinGroupDto } from './dto/join-group.dto';
import { UpdateGroupRulesDto } from './dto/update-group-rules.dto';
import { UpdateMemberRoleDto } from './dto/update-member-role.dto';
import { UpdateMemberStatusDto } from './dto/update-member-status.dto';
import {
  GroupCycleResponseDto,
  GroupDetailResponseDto,
  GroupJoinResponseDto,
  GroupMemberResponseDto,
  GroupRulesResponseDto,
  GroupSummaryResponseDto,
  InviteCodeResponseDto,
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
    summary: 'List groups where current user is a joined member',
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

  @Get(':id')
  @UseGuards(GroupMemberGuard)
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

  @Get(':id/rules')
  @UseGuards(GroupMemberGuard)
  @ApiTags('Rules')
  @ApiOperation({ summary: 'Get group ruleset' })
  @ApiOkResponse({ type: GroupRulesResponseDto })
  @ApiForbiddenResponse({ description: 'Joined group membership required' })
  @ApiNotFoundResponse({
    description: 'Group not found or rules not configured',
  })
  getGroupRules(
    @Param('id', new ParseUUIDPipe()) groupId: string,
  ): Promise<GroupRulesResponseDto> {
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
  @ApiTags('Members')
  @ApiOperation({ summary: 'List members in a group' })
  @ApiOkResponse({ type: GroupMemberResponseDto, isArray: true })
  @ApiForbiddenResponse({ description: 'Joined group membership required' })
  listMembers(
    @Param('id', new ParseUUIDPipe()) groupId: string,
  ): Promise<GroupMemberResponseDto[]> {
    return this.groupsService.listMembers(groupId);
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
