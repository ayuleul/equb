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
import { CreateGroupDto } from './dto/create-group.dto';
import { CreateInviteDto } from './dto/create-invite.dto';
import { GenerateCyclesDto } from './dto/generate-cycles.dto';
import { JoinGroupDto } from './dto/join-group.dto';
import { PayoutOrderItemDto } from './dto/payout-order-item.dto';
import { UpdateMemberRoleDto } from './dto/update-member-role.dto';
import { UpdateMemberStatusDto } from './dto/update-member-status.dto';
import {
  GroupCycleResponseDto,
  GroupDetailResponseDto,
  GroupJoinResponseDto,
  GroupMemberResponseDto,
  GroupSummaryResponseDto,
  InviteCodeResponseDto,
} from './entities/groups.entities';
import { GroupsService } from './groups.service';

@ApiTags('groups')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
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
  joinGroup(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Body() dto: JoinGroupDto,
  ): Promise<GroupJoinResponseDto> {
    return this.groupsService.joinGroup(currentUser, dto);
  }

  @Get(':id')
  @UseGuards(GroupMemberGuard)
  @ApiOperation({ summary: 'Get group details for current member' })
  @ApiOkResponse({ type: GroupDetailResponseDto })
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
  createInvite(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) groupId: string,
    @Body() dto: CreateInviteDto,
  ): Promise<InviteCodeResponseDto> {
    return this.groupsService.createInvite(currentUser, groupId, dto);
  }

  @Get(':id/members')
  @UseGuards(GroupMemberGuard)
  @ApiOperation({ summary: 'List members in a group' })
  @ApiOkResponse({ type: GroupMemberResponseDto, isArray: true })
  listMembers(
    @Param('id', new ParseUUIDPipe()) groupId: string,
  ): Promise<GroupMemberResponseDto[]> {
    return this.groupsService.listMembers(groupId);
  }

  @Patch(':id/members/:userId/role')
  @UseGuards(GroupAdminGuard)
  @ApiOperation({ summary: 'Update member role in a group' })
  @ApiBody({ type: UpdateMemberRoleDto })
  @ApiOkResponse({ type: GroupMemberResponseDto })
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
  @ApiOperation({
    summary: 'Update member status (self leave or admin remove)',
  })
  @ApiBody({ type: UpdateMemberStatusDto })
  @ApiOkResponse({ type: GroupMemberResponseDto })
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
  @ApiOperation({ summary: 'Set payout order for active members' })
  @ApiBody({ type: PayoutOrderItemDto, isArray: true })
  @ApiOkResponse({ type: GroupMemberResponseDto, isArray: true })
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
  @ApiOperation({ summary: 'Generate next cycle(s) based on payout order' })
  @ApiBody({ type: GenerateCyclesDto, required: false })
  @ApiOkResponse({ type: GroupCycleResponseDto, isArray: true })
  generateCycles(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) groupId: string,
    @Body() dto: GenerateCyclesDto,
  ): Promise<GroupCycleResponseDto[]> {
    return this.groupsService.generateCycles(currentUser, groupId, dto);
  }

  @Get(':id/cycles/current')
  @UseGuards(GroupMemberGuard)
  @ApiOperation({ summary: 'Get current open cycle for a group' })
  @ApiOkResponse({ type: GroupCycleResponseDto })
  getCurrentCycle(
    @Param('id', new ParseUUIDPipe()) groupId: string,
  ): Promise<GroupCycleResponseDto | null> {
    return this.groupsService.getCurrentCycle(groupId);
  }

  @Get(':id/cycles/:cycleId')
  @UseGuards(GroupMemberGuard)
  @ApiOperation({ summary: 'Get cycle details by id' })
  @ApiOkResponse({ type: GroupCycleResponseDto })
  getCycleById(
    @Param('id', new ParseUUIDPipe()) groupId: string,
    @Param('cycleId', new ParseUUIDPipe()) cycleId: string,
  ): Promise<GroupCycleResponseDto> {
    return this.groupsService.getCycleById(groupId, cycleId);
  }

  @Get(':id/cycles')
  @UseGuards(GroupMemberGuard)
  @ApiOperation({ summary: 'List cycles for a group' })
  @ApiOkResponse({ type: GroupCycleResponseDto, isArray: true })
  listCycles(
    @Param('id', new ParseUUIDPipe()) groupId: string,
  ): Promise<GroupCycleResponseDto[]> {
    return this.groupsService.listCycles(groupId);
  }
}
