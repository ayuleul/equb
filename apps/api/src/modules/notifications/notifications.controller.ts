import {
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
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
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import { ListNotificationsDto } from './dto/list-notifications.dto';
import { RegisterDeviceTokenDto } from './dto/register-device-token.dto';
import {
  DeviceTokenResponseDto,
  NotificationListResponseDto,
  NotificationResponseDto,
} from './entities/notifications.entities';
import { NotificationsService } from './notifications.service';

@ApiTags('notifications')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller()
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Post('devices/register-token')
  @ApiOperation({ summary: 'Register or refresh a device push token' })
  @ApiBody({ type: RegisterDeviceTokenDto })
  @ApiOkResponse({ type: DeviceTokenResponseDto })
  registerDeviceToken(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Body() dto: RegisterDeviceTokenDto,
  ): Promise<DeviceTokenResponseDto> {
    return this.notificationsService.registerDeviceToken(currentUser, dto);
  }

  @Get('notifications')
  @ApiOperation({ summary: 'List current user notifications' })
  @ApiOkResponse({ type: NotificationListResponseDto })
  listNotifications(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Query() dto: ListNotificationsDto,
  ): Promise<NotificationListResponseDto> {
    return this.notificationsService.listNotifications(currentUser, dto);
  }

  @Patch('notifications/:id/read')
  @ApiOperation({ summary: 'Mark one notification as read' })
  @ApiOkResponse({ type: NotificationResponseDto })
  markNotificationRead(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) notificationId: string,
  ): Promise<NotificationResponseDto> {
    return this.notificationsService.markNotificationRead(
      currentUser,
      notificationId,
    );
  }
}
