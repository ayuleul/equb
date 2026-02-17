import { Injectable, Logger } from '@nestjs/common';

import { SmsProvider } from '../interfaces/sms-provider.interface';

@Injectable()
export class DevSmsProvider implements SmsProvider {
  private readonly logger = new Logger(DevSmsProvider.name);

  sendOtp(phone: string, code: string): Promise<void> {
    this.logger.log(`[DEV_OTP] phone=${phone} code=${code}`);
    return Promise.resolve();
  }
}
