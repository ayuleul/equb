import { Injectable, Logger } from '@nestjs/common';
import type { Server } from 'socket.io';

import {
  type RealtimeEventPayload,
  groupRoomName,
  turnRoomName,
} from './realtime.types';

@Injectable()
export class RealtimeService {
  private readonly logger = new Logger(RealtimeService.name);
  private server: Server | null = null;

  attachServer(server: Server): void {
    this.server = server;
  }

  emitGroupEvent(groupId: string, event: RealtimeEventPayload): void {
    if (!this.server) {
      this.logger.debug(
        `Realtime server not ready. Skipping group event ${event.eventType}.`,
      );
      return;
    }

    this.server.to(groupRoomName(groupId)).emit(event.eventType, event);
  }

  emitTurnEvent(
    groupId: string,
    turnId: string,
    event: RealtimeEventPayload,
  ): void {
    if (!this.server) {
      this.logger.debug(
        `Realtime server not ready. Skipping turn event ${event.eventType}.`,
      );
      return;
    }

    this.server
      .to(groupRoomName(groupId))
      .to(turnRoomName(turnId))
      .emit(event.eventType, event);
  }
}
