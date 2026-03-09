import { ExecutionContext, Injectable } from '@nestjs/common';
import { ThrottlerGuard } from '@nestjs/throttler';

@Injectable()
export class AppThrottlerGuard extends ThrottlerGuard {
  protected async shouldSkip(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<Request | undefined>();
    const method = request?.method?.toUpperCase();
    const path = request?.url?.split('?')[0] ?? '';

    if (
      method === 'GET' &&
      (this.isGroupTurnDetailPath(path) ||
        this.isCyclePayoutPath(path) ||
        this.isContributionDisputesPath(path))
    ) {
      return true;
    }

    return super.shouldSkip(context);
  }

  private isGroupTurnDetailPath(path: string): boolean {
    return /^\/groups\/[^/]+\/cycles\/current$/.test(path)
      || /^\/groups\/[^/]+\/cycles\/[^/]+$/.test(path)
      || /^\/groups\/[^/]+\/cycles\/[^/]+\/contributions$/.test(path)
      || /^\/groups\/[^/]+\/cycles$/.test(path);
  }

  private isCyclePayoutPath(path: string): boolean {
    return /^\/cycles\/[^/]+\/payout$/.test(path);
  }

  private isContributionDisputesPath(path: string): boolean {
    return /^\/contributions\/[^/]+\/disputes$/.test(path);
  }
}
