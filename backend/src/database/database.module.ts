import {
  Global,
  Inject,
  Injectable,
  Module,
  OnApplicationShutdown,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Pool } from 'pg';

export const PG_POOL = 'PG_POOL';

/**
 * Second pool, connected as the `ai_readonly` role (migration 015).
 *
 * Only the assistant's tools inject this one. Everything else — including the
 * chat history the assistant's own conversations are written to — keeps using
 * PG_POOL. The split is enforced by which token a service asks for, so mixing
 * them up takes a deliberate edit rather than a slip.
 */
export const AI_PG_POOL = 'AI_PG_POOL';

@Injectable()
class DatabaseLifecycle implements OnApplicationShutdown {
  constructor(
    @Inject(PG_POOL) private readonly pool: Pool,
    @Inject(AI_PG_POOL) private readonly aiPool: Pool,
  ) {}

  async onApplicationShutdown(): Promise<void> {
    await Promise.all([this.pool.end(), this.aiPool.end()]);
  }
}

@Global()
@Module({
  providers: [
    {
      provide: PG_POOL,
      inject: [ConfigService],
      useFactory: (config: ConfigService): Pool => {
        const connectionString = config.get<string>('DATABASE_URL');
        if (!connectionString) {
          throw new Error('DATABASE_URL environment variable is not set');
        }
        const max = Number(config.get<string>('DATABASE_POOL_MAX') ?? '10');
        const pool = new Pool({
          connectionString,
          max: Number.isInteger(max) && max > 0 ? max : 10,
          idleTimeoutMillis: 30_000,
          connectionTimeoutMillis: 5_000,
          ssl:
            config.get<string>('DATABASE_SSL') === 'true'
              ? { rejectUnauthorized: true }
              : undefined,
        });
        pool.on('error', (error) => {
          console.error('Unexpected PostgreSQL pool error', error);
        });
        return pool;
      },
    },
    {
      provide: AI_PG_POOL,
      inject: [ConfigService],
      useFactory: (config: ConfigService): Pool => {
        const connectionString = config.get<string>('AI_DATABASE_URL');
        if (!connectionString) {
          throw new Error('AI_DATABASE_URL environment variable is not set');
        }
        const pool = new Pool({
          connectionString,
          // Smaller than the main pool on purpose: tool calls are a handful of
          // queries per conversation, and the assistant must never be able to
          // starve the screens of connections.
          max: 5,
          idleTimeoutMillis: 30_000,
          connectionTimeoutMillis: 5_000,
          // The third lock. A statement that somehow got past the tool layer
          // and the role grants is still refused by the server itself.
          options: '-c default_transaction_read_only=on',
          ssl:
            config.get<string>('DATABASE_SSL') === 'true'
              ? { rejectUnauthorized: true }
              : undefined,
        });
        pool.on('error', (error) => {
          console.error('Unexpected ai_readonly pool error', error);
        });
        return pool;
      },
    },
    DatabaseLifecycle,
  ],
  exports: [PG_POOL, AI_PG_POOL],
})
export class DatabaseModule {}
