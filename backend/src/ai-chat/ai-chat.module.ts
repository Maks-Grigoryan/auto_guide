import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { JwtModule, type JwtSignOptions } from '@nestjs/jwt';

import { AiChatController } from './ai-chat.controller';
import { AiChatService } from './ai-chat.service';
import { LLM_PROVIDER } from './llm/llm-provider';
import { OpenAiCompatibleProvider } from './llm/openai-compatible.provider';
import { AiToolsService } from './tools/ai-tools.service';
import { TopicGuardService } from './topic-guard.service';

/**
 * The assistant.
 *
 * The one binding worth reading twice is LLM_PROVIDER: everything above it is
 * written against an interface, so moving from a hosted open-weight endpoint to
 * a vLLM of your own is a change of URL, not of code.
 *
 * JwtModule is imported the same way AuthModule does it — the controller's
 * JwtAuthGuard needs a JwtService, and Nest resolves that per module rather
 * than globally.
 */
@Module({
  imports: [
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => {
        const secret = config.get<string>('JWT_SECRET');
        if (!secret || secret.length < 32) {
          throw new Error(
            'JWT_SECRET must be set and at least 32 characters long',
          );
        }
        const expiresIn = (config.get<string>('JWT_EXPIRES_IN') ??
          '30d') as JwtSignOptions['expiresIn'];
        return { secret, signOptions: { expiresIn } };
      },
    }),
  ],
  controllers: [AiChatController],
  providers: [
    AiChatService,
    AiToolsService,
    TopicGuardService,
    { provide: LLM_PROVIDER, useClass: OpenAiCompatibleProvider },
  ],
})
export class AiChatModule {}
