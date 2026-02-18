export interface PushSendResult {
  sentCount: number;
  failedCount: number;
}

export interface FcmProvider {
  sendToTokens(
    tokens: string[],
    title: string,
    body: string,
    data?: Record<string, unknown> | null,
  ): Promise<PushSendResult>;
}

export const FCM_PROVIDER = 'FCM_PROVIDER';
