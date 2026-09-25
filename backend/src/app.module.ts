import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_GUARD } from '@nestjs/core';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import { DatabaseModule } from './database/database.module';
import { SearchModule } from './search/search.module';
import { CatalogModule } from './catalog/catalog.module';
import { VendorsModule } from './vendors/vendors.module';
import { HealthModule } from './health/health.module';
import { AuthModule } from './auth/auth.module';
import { AiChatModule } from './ai-chat/ai-chat.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env', '../.env'],
    }),
    // A generous ceiling for ordinary browsing — catalogue and search are
    // read-only and cheap. The endpoints actually worth attacking carry their
    // own, much tighter @Throttle in auth.controller.ts.
    ThrottlerModule.forRoot({
      throttlers: [{ ttl: 60_000, limit: 100 }],
      // The e2e suite makes more sign-up attempts in a few seconds than a
      // human would in a minute, so leaving the limiter on would let the
      // runner's speed decide whether the tests pass. Overriding APP_GUARD
      // from the test module does not work — Nest keeps the original binding —
      // so the switch lives here, off unless a test explicitly sets it.
      skipIf: () => process.env.THROTTLE_DISABLED === 'true',
    }),
    DatabaseModule,
    SearchModule,
    CatalogModule,
    VendorsModule,
    HealthModule,
    AuthModule,
    // Conditional on purpose. The assistant needs a language model, and its
    // provider refuses to construct without one — the right behaviour for a
    // deployment that meant to have it. But the catalogue, search and sign-in
    // do not need a model to work, and neither does the e2e suite. Without a
    // key the assistant is simply not mounted; everything else comes up.
    ...(process.env.LLM_API_KEY ? [AiChatModule] : []),
  ],
  providers: [
    // Registered globally so every new endpoint is rate-limited by default.
    // Opting out then has to be deliberate, instead of protection being
    // something each route must remember to ask for.
    { provide: APP_GUARD, useClass: ThrottlerGuard },
  ],
})
export class AppModule {}
