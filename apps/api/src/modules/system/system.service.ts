import { Injectable } from '@nestjs/common';

import { BullMqService } from '../../common/queues/bullmq.service';
import { PrismaService } from '../../common/prisma/prisma.service';

export interface HealthResponse {
  status: 'ok' | 'degraded';
  checks: {
    database: 'up' | 'down';
    redis: 'up' | 'down' | 'disabled';
  };
  timestamp: string;
}

@Injectable()
export class SystemService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly bullMqService: BullMqService,
  ) {}

  async getHealth(): Promise<HealthResponse> {
    const checks: HealthResponse['checks'] = {
      database: 'down',
      redis: 'down',
    };

    try {
      await this.prisma.$queryRaw`SELECT 1`;
      checks.database = 'up';
    } catch {
      checks.database = 'down';
    }

    checks.redis = await this.bullMqService.pingRedis();

    const status =
      checks.database === 'up' &&
      (checks.redis === 'up' || checks.redis === 'disabled')
        ? 'ok'
        : 'degraded';

    return {
      status,
      checks,
      timestamp: new Date().toISOString(),
    };
  }
}
