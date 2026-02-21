import { ConsoleLogger, ValidationPipe } from '@nestjs/common';
import { HttpAdapterHost } from '@nestjs/core';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import * as Sentry from '@sentry/node';

import { AppModule } from './app.module';
import { SentryExceptionFilter } from './common/filters/sentry-exception.filter';

async function bootstrap() {
  const logger = new ConsoleLogger('Bootstrap', {
    json: true,
    timestamp: true,
  });
  const app = await NestFactory.create(AppModule, { logger });

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
    }),
  );

  const sentryDsn = process.env.SENTRY_DSN;
  if (sentryDsn) {
    Sentry.init({
      dsn: sentryDsn,
      environment: process.env.NODE_ENV ?? 'development',
    });

    app.useGlobalFilters(new SentryExceptionFilter(app.get(HttpAdapterHost)));
    logger.log('Sentry error reporting enabled');
  }

  if ((process.env.NODE_ENV ?? 'development') !== 'production') {
    const config = new DocumentBuilder()
      .setTitle('Equb API')
      .setDescription('Equb backend API documentation')
      .setVersion('1.0.0')
      .addBearerAuth()
      .addTag('Auth')
      .addTag('Users')
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
    SwaggerModule.setup('docs', app, document);
  }

  const port = Number(process.env.PORT ?? 3000);
  await app.listen(port);
}

void bootstrap();
