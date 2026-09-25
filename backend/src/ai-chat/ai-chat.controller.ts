import { Body, Controller, Post, Res, UseGuards } from '@nestjs/common';
import type { Response } from 'express';

import { CurrentUser, JwtAuthGuard } from '../auth/jwt-auth.guard';
import type { JwtPayload } from '../auth/jwt-auth.guard';
import { AiChatService } from './ai-chat.service';
import { AiChatDto } from './dto/ai-chat.dto';

/**
 * Server-sent events rather than a plain JSON response.
 *
 * An answer takes ten to twenty seconds once the model has searched the
 * catalogue. Sent as one block that is a spinner and a wait; streamed, the user
 * reads the first sentence while the rest is still being written.
 *
 * The response is written by hand instead of through Nest's `@Sse()` decorator:
 * that helper takes an Observable, and the service produces an async iterable
 * whose lifetime is tied to the request. Doing it directly keeps the two in
 * step and lets each event carry its own name.
 */
@Controller('ai')
@UseGuards(JwtAuthGuard)
export class AiChatController {
  constructor(private readonly chat: AiChatService) {}

  @Post('chat')
  async chatStream(
    @Body() dto: AiChatDto,
    @CurrentUser() user: JwtPayload,
    @Res() response: Response,
  ): Promise<void> {
    response.setHeader('Content-Type', 'text/event-stream');
    response.setHeader('Cache-Control', 'no-cache, no-transform');
    response.setHeader('Connection', 'keep-alive');
    // Nginx buffers proxied responses by default, which would hold the whole
    // stream back and deliver it at the end — exactly what SSE is here to
    // avoid.
    response.setHeader('X-Accel-Buffering', 'no');
    response.flushHeaders();

    const stream = this.chat.streamReply({
      userId: Number(user.sub),
      conversationId: dto.conversationId,
      message: dto.message,
      locale: dto.locale,
      carLabel: dto.carLabel,
      context: {
        lat: dto.lat,
        lng: dto.lng,
        makeId: dto.makeId,
        modelId: dto.modelId,
        generationId: dto.generationId,
      },
    });

    // Someone closing the app mid-answer should stop the work, not leave the
    // loop writing into a dead socket.
    let clientGone = false;
    response.on('close', () => {
      clientGone = true;
    });

    try {
      for await (const event of stream) {
        if (clientGone) break;
        write(response, event.type, event);
      }
    } catch {
      // The service already turns provider failures into `error` events; this
      // catches what it could not, and still ends the stream cleanly rather
      // than leaving the client waiting.
      if (!clientGone) write(response, 'error', { code: 'internal_error' });
    } finally {
      if (!clientGone) response.end();
    }
  }
}

function write(response: Response, event: string, payload: unknown): void {
  response.write(`event: ${event}\n`);
  response.write(`data: ${JSON.stringify(payload)}\n\n`);
}
