import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

import {
  LlmChatParams,
  LlmEvent,
  LlmMessage,
  LlmProvider,
  LlmProviderError,
  LlmToolCall,
  LlmUsage,
} from './llm-provider';

/** Shape of one streamed chunk. Only the fields this app reads. */
interface StreamChunk {
  choices?: Array<{
    delta?: {
      content?: string | null;
      tool_calls?: Array<{
        index: number;
        id?: string;
        function?: { name?: string; arguments?: string };
      }>;
    };
    finish_reason?: string | null;
  }>;
  usage?: { prompt_tokens?: number; completion_tokens?: number } | null;
}

/**
 * Talks to any OpenAI-compatible endpoint: DeepInfra, Together, Fireworks, or a
 * vLLM you run yourself. They differ in price and in which models they host,
 * not in this protocol.
 *
 * Node 20 has fetch built in, so there is no HTTP client dependency here.
 */
@Injectable()
export class OpenAiCompatibleProvider implements LlmProvider {
  private readonly baseUrl: string;
  private readonly apiKey: string;
  private readonly defaultModel: string;
  private readonly timeoutMs: number;

  constructor(config: ConfigService) {
    // Fail at startup, not at the first user question. A missing key here is a
    // deployment mistake and should look like one immediately.
    this.baseUrl = requireConfig(config, 'LLM_BASE_URL').replace(/\/+$/, '');
    this.apiKey = requireConfig(config, 'LLM_API_KEY');
    this.defaultModel = requireConfig(config, 'LLM_MODEL');
    this.timeoutMs = Number(config.get<string>('LLM_TIMEOUT_MS') ?? '120000');
  }

  async *chat(params: LlmChatParams): AsyncIterable<LlmEvent> {
    const response = await this.post(params, true);
    const body = response.body;
    if (!body) {
      throw new LlmProviderError('unavailable', 'Provider returned no body');
    }

    // Tool calls arrive spread across chunks, keyed by index: the name comes in
    // one chunk and the arguments in pieces across several more.
    const partialCalls = new Map<
      number,
      { id: string; name: string; args: string }
    >();
    let usage: LlmUsage = { inputTokens: 0, outputTokens: 0 };
    let finishReason = 'stop';

    for await (const data of readSseData(body)) {
      if (data === '[DONE]') break;

      let chunk: StreamChunk;
      try {
        chunk = JSON.parse(data) as StreamChunk;
      } catch {
        // A malformed chunk is the provider's problem, not a reason to drop a
        // conversation that is otherwise streaming fine.
        continue;
      }

      if (chunk.usage) {
        usage = {
          inputTokens: chunk.usage.prompt_tokens ?? 0,
          outputTokens: chunk.usage.completion_tokens ?? 0,
        };
      }

      const choice = chunk.choices?.[0];
      if (!choice) continue;

      if (choice.finish_reason) finishReason = choice.finish_reason;

      const text = choice.delta?.content;
      if (text) yield { type: 'text', delta: text };

      for (const call of choice.delta?.tool_calls ?? []) {
        const existing = partialCalls.get(call.index) ?? {
          id: '',
          name: '',
          args: '',
        };
        partialCalls.set(call.index, {
          id: call.id ?? existing.id,
          name: call.function?.name ?? existing.name,
          args: existing.args + (call.function?.arguments ?? ''),
        });
      }
    }

    if (partialCalls.size > 0) {
      const calls: LlmToolCall[] = [...partialCalls.entries()]
        .sort(([a], [b]) => a - b)
        .map(([index, call]) => ({
          // Some providers omit the id on streamed calls; the loop needs one to
          // match the result back, so synthesise a stable substitute.
          id: call.id || `call_${index}`,
          name: call.name,
          argumentsJson: call.args || '{}',
        }));
      yield { type: 'tool_calls', calls };
    }

    yield { type: 'done', usage, finishReason };
  }

  async complete(
    params: LlmChatParams,
  ): Promise<{ text: string; usage: LlmUsage }> {
    const response = await this.post(params, false);
    const json = (await response.json()) as {
      choices?: Array<{ message?: { content?: string | null } }>;
      usage?: { prompt_tokens?: number; completion_tokens?: number };
    };
    return {
      text: json.choices?.[0]?.message?.content ?? '',
      usage: {
        inputTokens: json.usage?.prompt_tokens ?? 0,
        outputTokens: json.usage?.completion_tokens ?? 0,
      },
    };
  }

  private async post(params: LlmChatParams, stream: boolean): Promise<Response> {
    const body = {
      model: params.model ?? this.defaultModel,
      messages: [
        { role: 'system', content: params.system },
        ...params.messages.map(toWireMessage),
      ],
      ...(params.tools?.length
        ? {
            tools: params.tools.map((tool) => ({
              type: 'function',
              function: {
                name: tool.name,
                description: tool.description,
                parameters: tool.parameters,
              },
            })),
          }
        : {}),
      max_tokens: params.maxTokens ?? 2048,
      temperature: params.temperature ?? 0.3,
      stream,
      ...(stream ? { stream_options: { include_usage: true } } : {}),
    };

    let response: Response;
    try {
      response = await fetch(`${this.baseUrl}/chat/completions`, {
        method: 'POST',
        headers: {
          'content-type': 'application/json',
          authorization: `Bearer ${this.apiKey}`,
        },
        body: JSON.stringify(body),
        signal: AbortSignal.timeout(this.timeoutMs),
      });
    } catch (error) {
      throw new LlmProviderError(
        'unavailable',
        `LLM request failed: ${(error as Error).message}`,
      );
    }

    if (!response.ok) {
      // The provider's own text is read for the server log and deliberately not
      // forwarded: it names plans, quotas and models.
      const detail = await response.text().catch(() => '');
      throw new LlmProviderError(
        classifyStatus(response.status),
        `LLM provider returned ${response.status}: ${detail.slice(0, 500)}`,
      );
    }

    return response;
  }
}

function toWireMessage(message: LlmMessage): Record<string, unknown> {
  if (message.role === 'tool') {
    return {
      role: 'tool',
      content: message.content,
      tool_call_id: message.toolCallId,
    };
  }
  if (message.toolCalls?.length) {
    return {
      role: message.role,
      content: message.content || null,
      tool_calls: message.toolCalls.map((call) => ({
        id: call.id,
        type: 'function',
        function: { name: call.name, arguments: call.argumentsJson },
      })),
    };
  }
  return { role: message.role, content: message.content };
}

function classifyStatus(status: number): LlmProviderError['code'] {
  if (status === 429) return 'rate_limited';
  if (status === 401 || status === 403) return 'unauthorized';
  if (status >= 500) return 'unavailable';
  return 'invalid';
}

function requireConfig(config: ConfigService, key: string): string {
  const value = config.get<string>(key);
  if (!value) {
    throw new Error(`${key} environment variable is not set`);
  }
  return value;
}

/**
 * Yields the payload of each `data:` line in an SSE stream.
 *
 * Chunks do not arrive aligned to lines — a JSON object can be split across two
 * network reads — so the tail of each read is carried over rather than parsed.
 */
async function* readSseData(
  body: ReadableStream<Uint8Array>,
): AsyncGenerator<string> {
  const reader = body.getReader();
  const decoder = new TextDecoder();
  let buffer = '';

  try {
    for (;;) {
      const { done, value } = await reader.read();
      if (done) break;

      buffer += decoder.decode(value, { stream: true });
      const lines = buffer.split('\n');
      buffer = lines.pop() ?? '';

      for (const line of lines) {
        const trimmed = line.trim();
        if (trimmed.startsWith('data:')) {
          yield trimmed.slice(5).trim();
        }
      }
    }
  } finally {
    reader.releaseLock();
  }
}
