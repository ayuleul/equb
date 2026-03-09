import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';

export interface RealtimeEventPayload {
  eventType: string;
  groupId: string;
  turnId?: string;
  entityId?: string;
  timestamp: string;
  summary?: Record<string, unknown>;
}

export type RealtimeSocketData = {
  user?: AuthenticatedUser;
};

export const GROUP_ROOM_PREFIX = 'group';
export const TURN_ROOM_PREFIX = 'turn';

export function groupRoomName(groupId: string): string {
  return `${GROUP_ROOM_PREFIX}:${groupId}`;
}

export function turnRoomName(turnId: string): string {
  return `${TURN_ROOM_PREFIX}:${turnId}`;
}
