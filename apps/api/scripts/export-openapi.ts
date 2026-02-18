import { mkdirSync, writeFileSync } from 'fs';
import { dirname, resolve } from 'path';

import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';

import { AppModule } from '../src/app.module';

async function bootstrap(): Promise<void> {
  process.env.NODE_ENV = process.env.NODE_ENV ?? 'development';
  process.env.JOBS_DISABLED = process.env.JOBS_DISABLED ?? 'true';

  const app = await NestFactory.create(AppModule, {
    logger: false,
  });

  const config = new DocumentBuilder()
    .setTitle('Equb API')
    .setDescription('Equb backend API documentation')
    .setVersion('1.0.0')
    .addBearerAuth()
    .addTag('Auth')
    .addTag('Groups')
    .addTag('Members')
    .addTag('Cycles')
    .addTag('Contributions')
    .addTag('Payouts')
    .addTag('Files')
    .addTag('Devices')
    .addTag('Notifications')
    .addTag('System')
    .build();

  const document = SwaggerModule.createDocument(app, config);

  const outputPath = resolve(__dirname, '../../../docs/openapi.json');
  mkdirSync(dirname(outputPath), { recursive: true });
  writeFileSync(outputPath, JSON.stringify(document, null, 2), 'utf-8');

  await app.close();
  // eslint-disable-next-line no-console
  console.log(`OpenAPI exported to ${outputPath}`);
}

void bootstrap();
