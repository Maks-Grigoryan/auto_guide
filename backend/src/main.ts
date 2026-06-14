import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { ValidationPipe, ArgumentsHost, Catch, ExceptionFilter, HttpException, HttpStatus } from '@nestjs/common';
import { Request, Response } from 'express';
import { AppModule } from './app.module';

@Catch()
class SafeExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();

    if (exception instanceof HttpException) {
      const status = exception.getStatus();
      const exceptionResponse = exception.getResponse();
      const message =
        typeof exceptionResponse === 'object' && exceptionResponse !== null && 'message' in exceptionResponse
          ? (exceptionResponse as { message: unknown }).message
          : exception.message;
      response.status(status).json({ error: exception.name, message });
    } else {
      response.status(HttpStatus.INTERNAL_SERVER_ERROR).json({
        error: 'InternalServerError',
        message: 'An unexpected error occurred',
      });
    }
  }
}

async function bootstrap(): Promise<void> {
  const app = await NestFactory.create(AppModule);
  app.useGlobalPipes(
    new ValidationPipe({ transform: true, whitelist: true }),
  );
  app.useGlobalFilters(new SafeExceptionFilter());
  const port = process.env['PORT'] ?? 3000;
  await app.listen(port);
}

bootstrap().catch((err: unknown) => {
  console.error('Fatal startup error', err);
  process.exit(1);
});
