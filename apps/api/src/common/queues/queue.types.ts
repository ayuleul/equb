import { NotificationType } from '@prisma/client';

export interface NotificationJobData {
  userId: string;
  groupId?: string | null;
  type: NotificationType;
  title: string;
  body: string;
  data?: Record<string, unknown> | null;
  dedupKey?: string;
}

export interface ReminderJobData {
  triggeredAtIso: string;
}
