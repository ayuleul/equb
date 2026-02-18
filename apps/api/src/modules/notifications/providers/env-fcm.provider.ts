import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JWT } from 'google-auth-library';

import {
  FcmProvider,
  PushSendResult,
} from '../interfaces/fcm-provider.interface';

const FCM_SCOPE = 'https://www.googleapis.com/auth/firebase.messaging';

@Injectable()
export class EnvFcmProvider implements FcmProvider {
  private readonly logger = new Logger(EnvFcmProvider.name);

  constructor(private readonly configService: ConfigService) {}

  async sendToTokens(
    tokens: string[],
    title: string,
    body: string,
    data?: Record<string, unknown> | null,
  ): Promise<PushSendResult> {
    if (this.fcmDisabled || tokens.length === 0) {
      return {
        sentCount: 0,
        failedCount: 0,
      };
    }

    const projectId = this.configService.get<string>('FCM_PROJECT_ID');
    const clientEmail = this.configService.get<string>('FCM_CLIENT_EMAIL');
    const privateKey = this.resolvePrivateKey();

    if (!projectId || !clientEmail || !privateKey) {
      this.logger.warn(
        'FCM is enabled but credentials are incomplete; skipping push delivery',
      );
      return {
        sentCount: 0,
        failedCount: tokens.length,
      };
    }

    const accessToken = await this.getAccessToken(clientEmail, privateKey);
    if (!accessToken) {
      return {
        sentCount: 0,
        failedCount: tokens.length,
      };
    }

    const endpoint = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;
    const stringData = this.toStringData(data);

    let sentCount = 0;
    let failedCount = 0;

    await Promise.all(
      tokens.map(async (token) => {
        try {
          const response = await fetch(endpoint, {
            method: 'POST',
            headers: {
              Authorization: `Bearer ${accessToken}`,
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({
              message: {
                token,
                notification: {
                  title,
                  body,
                },
                data: stringData,
              },
            }),
          });

          if (response.ok) {
            sentCount += 1;
          } else {
            failedCount += 1;
          }
        } catch {
          failedCount += 1;
        }
      }),
    );

    return {
      sentCount,
      failedCount,
    };
  }

  private get fcmDisabled(): boolean {
    const value = this.configService.get<string>('FCM_DISABLED') ?? 'true';
    return value.toLowerCase() === 'true';
  }

  private resolvePrivateKey(): string | null {
    const raw = this.configService.get<string>('FCM_PRIVATE_KEY');
    if (!raw) {
      return null;
    }

    return raw.replace(/\\n/g, '\n');
  }

  private async getAccessToken(
    clientEmail: string,
    privateKey: string,
  ): Promise<string | null> {
    try {
      const jwtClient = new JWT({
        email: clientEmail,
        key: privateKey,
        scopes: [FCM_SCOPE],
      });

      const credentials = await jwtClient.authorize();
      return credentials.access_token ?? null;
    } catch (error) {
      this.logger.error(
        'Failed to get FCM access token',
        error instanceof Error ? error.stack : undefined,
      );
      return null;
    }
  }

  private toStringData(
    data?: Record<string, unknown> | null,
  ): Record<string, string> {
    if (!data) {
      return {};
    }

    return Object.entries(data).reduce<Record<string, string>>(
      (accumulator, [key, value]) => {
        if (typeof value === 'undefined' || value === null) {
          return accumulator;
        }

        if (typeof value === 'string') {
          accumulator[key] = value;
          return accumulator;
        }

        if (typeof value === 'number' || typeof value === 'boolean') {
          accumulator[key] = value.toString();
          return accumulator;
        }

        accumulator[key] = JSON.stringify(value);
        return accumulator;
      },
      {},
    );
  }
}
