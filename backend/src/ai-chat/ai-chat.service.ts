import { Inject, Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Pool } from 'pg';

import { PG_POOL } from '../database/database.module';
import {
  LLM_PROVIDER,
  LlmMessage,
  LlmProvider,
  LlmProviderError,
  LlmUsage,
} from './llm/llm-provider';
import { buildSystemPrompt } from './prompts/system-prompt';
import {
  AI_TOOLS,
  AiToolsService,
  FoundPart,
  ToolContext,
} from './tools/ai-tools.service';
import { TopicGuardService } from './topic-guard.service';

/** What the controller turns into SSE frames. */
export type ChatStreamEvent =
  | { type: 'text'; delta: string }
  | { type: 'tool'; name: string }
  | { type: 'parts'; items: FoundPart[] }
  | { type: 'done'; conversationId: number; usage: LlmUsage }
  | { type: 'error'; code: string };

export interface ChatRequest {
  userId: number;
  conversationId?: number;
  message: string;
  locale: string;
  context: ToolContext;
  carLabel?: string;
}

/**
 * How many times the model may call tools before it has to answer.
 *
 * Three covers the real pattern — look up categories, search, answer — and
 * stops a model that has started looping from spending the budget on it.
 */
const MAX_TOOL_ROUNDS = 3;

/** Messages kept in context. Older ones are dropped rather than summarised. */
const HISTORY_LIMIT = 20;

@Injectable()
export class AiChatService {
  private readonly logger = new Logger(AiChatService.name);
  private readonly dailyLimit: number;

  constructor(
    @Inject(PG_POOL) private readonly pool: Pool,
    @Inject(LLM_PROVIDER) private readonly llm: LlmProvider,
    private readonly tools: AiToolsService,
    private readonly topicGuard: TopicGuardService,
    config: ConfigService,
  ) {
    this.dailyLimit = Number(
      config.get<string>('AI_DAILY_MESSAGE_LIMIT') ?? '50',
    );
  }

  async *streamReply(request: ChatRequest): AsyncIterable<ChatStreamEvent> {
    try {
      if (await this.isOverQuota(request.userId)) {
        yield { type: 'error', code: 'quota_exceeded' };
        return;
      }

      const conversationId = await this.ensureConversation(
        request.userId,
        request.conversationId,
      );
      const history = await this.loadHistory(conversationId);

      // The gate runs before anything expensive. It sees the recent history
      // too, so a bare «а сколько?» is judged as the follow-up it is.
      const onTopic = await this.topicGuard.isOnTopic(request.message, history);
      if (!onTopic) {
        const refusal = REFUSALS[request.locale] ?? REFUSALS.ru;
        await this.saveMessage(conversationId, 'user', request.message);
        await this.saveMessage(conversationId, 'assistant', refusal);
        yield { type: 'text', delta: refusal };
        yield {
          type: 'done',
          conversationId,
          usage: { inputTokens: 0, outputTokens: 0 },
        };
        return;
      }

      await this.saveMessage(conversationId, 'user', request.message);

      const messages: LlmMessage[] = [
        ...history,
        { role: 'user', content: request.message },
      ];
      const system = buildSystemPrompt(request.locale, request.carLabel);

      const collectedParts: FoundPart[] = [];
      let answer = '';
      const total: LlmUsage = { inputTokens: 0, outputTokens: 0 };

      for (let round = 0; round <= MAX_TOOL_ROUNDS; round += 1) {
        // On the last round the tools are withheld: the model has to produce an
        // answer rather than ask for another search it will not get.
        const withTools = round < MAX_TOOL_ROUNDS;
        let turnText = '';
        let pendingCalls: { id: string; name: string; args: string }[] = [];

        for await (const event of this.llm.chat({
          system,
          messages,
          tools: withTools ? AI_TOOLS : undefined,
          maxTokens: 1500,
        })) {
          if (event.type === 'text') {
            turnText += event.delta;
            yield { type: 'text', delta: event.delta };
          } else if (event.type === 'tool_calls') {
            pendingCalls = event.calls.map((call) => ({
              id: call.id,
              name: call.name,
              args: call.argumentsJson,
            }));
          } else {
            total.inputTokens += event.usage.inputTokens;
            total.outputTokens += event.usage.outputTokens;
          }
        }

        answer += turnText;

        if (pendingCalls.length === 0) break;

        messages.push({
          role: 'assistant',
          content: turnText,
          toolCalls: pendingCalls.map((call) => ({
            id: call.id,
            name: call.name,
            argumentsJson: call.args,
          })),
        });

        for (const call of pendingCalls) {
          yield { type: 'tool', name: call.name };

          const result = await this.runTool(
            call.name,
            call.args,
            request.context,
          );
          if (result.parts?.length) {
            collectedParts.push(...result.parts);
            yield { type: 'parts', items: result.parts };
          }

          messages.push({
            role: 'tool',
            toolCallId: call.id,
            content: JSON.stringify(result.payload),
          });
        }
      }

      // Cards are attached from what the tools returned, never from the text.
      // The model cannot invent a part it did not find.
      await this.saveMessage(
        conversationId,
        'assistant',
        answer,
        dedupeParts(collectedParts),
        total,
      );

      yield { type: 'done', conversationId, usage: total };
    } catch (error) {
      const code =
        error instanceof LlmProviderError ? error.code : 'internal_error';
      // Full detail to the server log, a bare code to the client: provider
      // messages name plans, quotas and models.
      this.logger.error(`Chat failed: ${(error as Error).message}`);
      yield { type: 'error', code };
    }
  }

  private async runTool(
    name: string,
    argumentsJson: string,
    context: ToolContext,
  ) {
    let args: Record<string, unknown>;
    try {
      args = JSON.parse(argumentsJson || '{}') as Record<string, unknown>;
    } catch {
      // Malformed arguments go back as a tool result, not an exception: the
      // model gets to see its own mistake and try again.
      return { payload: { error: 'Arguments were not valid JSON' } };
    }

    try {
      return await this.tools.execute(name, args, context);
    } catch (error) {
      this.logger.error(`Tool ${name} failed: ${(error as Error).message}`);
      return { payload: { error: 'Tool failed. Do not retry it this turn.' } };
    }
  }

  private async isOverQuota(userId: number): Promise<boolean> {
    const result = await this.pool.query<{ count: string }>(
      `SELECT count(*) AS count
         FROM chat_messages m
         JOIN chat_conversations c ON c.id = m.conversation_id
        WHERE c.user_id = $1
          AND m.role = 'user'
          AND m.created_at >= now() - interval '1 day'`,
      [userId],
    );
    return Number(result.rows[0]?.count ?? 0) >= this.dailyLimit;
  }

  private async ensureConversation(
    userId: number,
    conversationId?: number,
  ): Promise<number> {
    if (conversationId) {
      // Ownership is checked here, not trusted from the request: an id from
      // someone else's account must not open their conversation.
      const owned = await this.pool.query(
        'SELECT 1 FROM chat_conversations WHERE id = $1 AND user_id = $2',
        [conversationId, userId],
      );
      if (owned.rowCount) return conversationId;
    }

    const created = await this.pool.query<{ id: string }>(
      'INSERT INTO chat_conversations (user_id) VALUES ($1) RETURNING id',
      [userId],
    );
    return Number(created.rows[0].id);
  }

  private async loadHistory(conversationId: number): Promise<LlmMessage[]> {
    const result = await this.pool.query<{ role: string; content: string }>(
      `SELECT role, content FROM (
         SELECT role, content, created_at
           FROM chat_messages
          WHERE conversation_id = $1
          ORDER BY created_at DESC
          LIMIT $2
       ) recent ORDER BY created_at`,
      [conversationId, HISTORY_LIMIT],
    );
    return result.rows.map((row) => ({
      role: row.role === 'user' ? 'user' : 'assistant',
      content: row.content,
    }));
  }

  private async saveMessage(
    conversationId: number,
    role: 'user' | 'assistant',
    content: string,
    parts?: FoundPart[],
    usage?: LlmUsage,
  ): Promise<void> {
    await this.pool.query(
      `INSERT INTO chat_messages
         (conversation_id, role, content, attachments, input_tokens, output_tokens)
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [
        conversationId,
        role,
        content,
        parts?.length ? JSON.stringify(parts) : null,
        usage?.inputTokens ?? null,
        usage?.outputTokens ?? null,
      ],
    );
  }
}

/** Said without calling the expensive model at all — the gate already decided. */
const REFUSALS: Record<string, string> = {
  ru: 'Я помогаю только с автомобилями — запчасти, неисправности, сервисы. Спросите что-нибудь про вашу машину.',
  hy: 'Ես օգնում եմ միայն մեքենաների հարցերում՝ պահեստամասեր, անսարքություններ, սերվիսներ։ Հարցրեք ձեր մեքենայի մասին։',
  en: 'I only help with cars — parts, faults and repair shops. Ask me something about your vehicle.',
};

/** The same part can come back from more than one search in a turn. */
function dedupeParts(parts: FoundPart[]): FoundPart[] {
  const seen = new Map<number, FoundPart>();
  for (const part of parts) {
    if (!seen.has(part.partId)) seen.set(part.partId, part);
  }
  return [...seen.values()];
}
