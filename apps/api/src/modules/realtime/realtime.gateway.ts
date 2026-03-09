import {
  CanActivate,
  ExecutionContext,
  Injectable,
  Logger,
  UnauthorizedException,
  UseGuards,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import {
  ConnectedSocket,
  MessageBody,
  OnGatewayConnection,
  OnGatewayDisconnect,
  OnGatewayInit,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
  WsException,
} from '@nestjs/websockets';
import type { Server, Socket } from 'socket.io';

import { isParticipatingMemberStatus } from '../../common/membership/member-status.util';
import { PrismaService } from '../../common/prisma/prisma.service';
import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import { JoinGroupRoomDto } from './dto/join-group-room.dto';
import { JoinTurnRoomDto } from './dto/join-turn-room.dto';
import { RealtimeService } from './realtime.service';
import {
  type RealtimeSocketData,
  groupRoomName,
  turnRoomName,
} from './realtime.types';

type RealtimeSocket = Socket & { data: RealtimeSocketData };

interface AccessTokenPayload {
  sub: string;
  phone: string;
}

@Injectable()
export class RealtimeSocketAuthService {
  constructor(
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  async authenticate(socket: RealtimeSocket): Promise<AuthenticatedUser> {
    const token = this.extractToken(socket);
    if (!token) {
      throw new UnauthorizedException('Missing access token');
    }

    const payload = await this.jwtService.verifyAsync<AccessTokenPayload>(
      token,
      {
        secret:
          this.configService.get<string>('JWT_ACCESS_SECRET') ??
          'change-me-access-secret',
      },
    );

    return {
      id: payload.sub,
      phone: payload.phone,
    };
  }

  private extractToken(socket: RealtimeSocket): string | null {
    const authToken = socket.handshake.auth?.token;
    if (typeof authToken === 'string' && authToken.trim().length > 0) {
      return this.normalizeToken(authToken);
    }

    const accessToken = socket.handshake.auth?.accessToken;
    if (typeof accessToken === 'string' && accessToken.trim().length > 0) {
      return this.normalizeToken(accessToken);
    }

    const headerValue = socket.handshake.headers.authorization;
    if (typeof headerValue === 'string' && headerValue.trim().length > 0) {
      return this.normalizeToken(headerValue);
    }

    return null;
  }

  private normalizeToken(value: string): string {
    return value.replace(/^Bearer\s+/i, '').trim();
  }
}

@Injectable()
export class WsJwtAuthGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const client = context.switchToWs().getClient<RealtimeSocket>();
    if (!client.data.user) {
      throw new WsException('Unauthorized');
    }

    return true;
  }
}

@Injectable()
export class RealtimeAccessService {
  constructor(private readonly prisma: PrismaService) {}

  async assertGroupMembership(userId: string, groupId: string): Promise<void> {
    const membership = await this.prisma.equbMember.findUnique({
      where: {
        groupId_userId: {
          groupId,
          userId,
        },
      },
      select: {
        status: true,
      },
    });

    if (!membership || !isParticipatingMemberStatus(membership.status)) {
      throw new WsException('Forbidden');
    }
  }

  async assertTurnMembership(
    userId: string,
    turnId: string,
  ): Promise<{ groupId: string }> {
    const turn = await this.prisma.equbCycle.findUnique({
      where: { id: turnId },
      select: { id: true, groupId: true },
    });

    if (!turn) {
      throw new WsException('Turn not found');
    }

    await this.assertGroupMembership(userId, turn.groupId);
    return { groupId: turn.groupId };
  }
}

@WebSocketGateway({
  cors: {
    origin: true,
    credentials: true,
  },
})
export class RealtimeGateway
  implements OnGatewayInit, OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer()
  server!: Server;

  private readonly logger = new Logger(RealtimeGateway.name);

  constructor(
    private readonly realtimeService: RealtimeService,
    private readonly authService: RealtimeSocketAuthService,
    private readonly accessService: RealtimeAccessService,
  ) {}

  afterInit(server: Server): void {
    this.realtimeService.attachServer(server);
    server.use(async (socket: RealtimeSocket, next) => {
      try {
        socket.data.user = await this.authService.authenticate(socket);
        next();
      } catch (error) {
        next(error instanceof Error ? error : new Error('Unauthorized'));
      }
    });
  }

  handleConnection(client: RealtimeSocket): void {
    if (!client.data.user) {
      client.disconnect();
      throw new WsException('Unauthorized');
    }

    this.logger.debug(
      `Realtime client connected userId=${client.data.user.id}`,
    );
  }

  handleDisconnect(client: RealtimeSocket): void {
    const userId = client.data.user?.id ?? 'unknown';
    this.logger.debug(`Realtime client disconnected userId=${userId}`);
  }

  @UseGuards(WsJwtAuthGuard)
  @SubscribeMessage('join_group_room')
  async joinGroupRoom(
    @ConnectedSocket() client: RealtimeSocket,
    @MessageBody() dto: JoinGroupRoomDto,
  ): Promise<{ room: string }> {
    await this.accessService.assertGroupMembership(
      client.data.user!.id,
      dto.groupId,
    );
    const room = groupRoomName(dto.groupId);
    await client.join(room);
    return { room };
  }

  @UseGuards(WsJwtAuthGuard)
  @SubscribeMessage('leave_group_room')
  async leaveGroupRoom(
    @ConnectedSocket() client: RealtimeSocket,
    @MessageBody() dto: JoinGroupRoomDto,
  ): Promise<{ room: string }> {
    const room = groupRoomName(dto.groupId);
    await client.leave(room);
    return { room };
  }

  @UseGuards(WsJwtAuthGuard)
  @SubscribeMessage('join_turn_room')
  async joinTurnRoom(
    @ConnectedSocket() client: RealtimeSocket,
    @MessageBody() dto: JoinTurnRoomDto,
  ): Promise<{ room: string }> {
    await this.accessService.assertTurnMembership(
      client.data.user!.id,
      dto.turnId,
    );
    const room = turnRoomName(dto.turnId);
    await client.join(room);
    return { room };
  }

  @UseGuards(WsJwtAuthGuard)
  @SubscribeMessage('leave_turn_room')
  async leaveTurnRoom(
    @ConnectedSocket() client: RealtimeSocket,
    @MessageBody() dto: JoinTurnRoomDto,
  ): Promise<{ room: string }> {
    const room = turnRoomName(dto.turnId);
    await client.leave(room);
    return { room };
  }
}
