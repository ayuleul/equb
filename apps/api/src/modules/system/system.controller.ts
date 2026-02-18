import { Controller, Get } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';

import { SystemService } from './system.service';

@ApiTags('System')
@Controller()
export class SystemController {
  constructor(private readonly systemService: SystemService) {}

  @Get('health')
  @ApiOperation({ summary: 'Health check for API dependencies' })
  @ApiOkResponse({
    schema: {
      type: 'object',
      properties: {
        status: { type: 'string', enum: ['ok', 'degraded'] },
        checks: {
          type: 'object',
          properties: {
            database: { type: 'string', enum: ['up', 'down'] },
            redis: { type: 'string', enum: ['up', 'down', 'disabled'] },
          },
        },
        timestamp: { type: 'string' },
      },
    },
  })
  getHealth() {
    return this.systemService.getHealth();
  }
}
