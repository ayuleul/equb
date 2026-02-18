import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { NotificationStatus, NotificationType, Platform } from '@prisma/client';

export class DeviceTokenResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  userId!: string;

  @ApiProperty()
  token!: string;

  @ApiProperty({ enum: Platform })
  platform!: Platform;

  @ApiProperty()
  isActive!: boolean;

  @ApiProperty()
  lastSeenAt!: Date;

  @ApiProperty()
  createdAt!: Date;
}

export class NotificationResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  userId!: string;

  @ApiPropertyOptional({ nullable: true })
  groupId!: string | null;

  @ApiProperty({ enum: NotificationType })
  type!: NotificationType;

  @ApiProperty()
  title!: string;

  @ApiProperty()
  body!: string;

  @ApiPropertyOptional({
    nullable: true,
    type: 'object',
    additionalProperties: true,
  })
  dataJson!: Record<string, unknown> | null;

  @ApiProperty({ enum: NotificationStatus })
  status!: NotificationStatus;

  @ApiProperty()
  createdAt!: Date;

  @ApiPropertyOptional({ nullable: true })
  readAt!: Date | null;
}

export class NotificationListResponseDto {
  @ApiProperty({ type: () => NotificationResponseDto, isArray: true })
  items!: NotificationResponseDto[];

  @ApiProperty()
  total!: number;

  @ApiProperty()
  offset!: number;

  @ApiProperty()
  limit!: number;
}
