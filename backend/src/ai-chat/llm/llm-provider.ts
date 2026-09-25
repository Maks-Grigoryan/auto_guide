/**
 * The seam between this application and whatever language model is behind it.
 *
 * Everything above this file — the agent loop, the tools, the chat history —
 * is written against these types and knows nothing about the provider. Moving
 * from a hosted open-weight endpoint to your own vLLM is three lines of .env,
 * because both speak the same OpenAI-compatible protocol.
 *
 * The types are deliberately narrower than that protocol. Only what the
 * assistant actually uses appears here; a field nobody needs is a field that
 * will be wrong the day someone starts trusting it.
 */

export type LlmRole = 'system' | 'user' | 'assistant' | 'tool';

export interface LlmToolCall {
  id: string;
  name: string;
  /** Raw JSON from the model — parse it, never string-match it. */
  argumentsJson: string;
}

export interface LlmMessage {
  role: LlmRole;
  content: string;
  /** Present on assistant turns that asked for tools. */
  toolCalls?: LlmToolCall[];
  /** Present on tool results: which call this answers. */
  toolCallId?: string;
}

export interface LlmTool {
  name: string;
  description: string;
  /** JSON Schema for the arguments. */
  parameters: Record<string, unknown>;
}

/** What the model spent. Recorded per message so the bill is never a surprise. */
export interface LlmUsage {
  inputTokens: number;
  outputTokens: number;
}

/**
 * One step of a conversation.
 *
 * `text` arrives in pieces as the model writes; `tool_calls` and `done` arrive
 * once, at the end of a turn.
 */
export type LlmEvent =
  | { type: 'text'; delta: string }
  | { type: 'tool_calls'; calls: LlmToolCall[] }
  | { type: 'done'; usage: LlmUsage; finishReason: string };

export interface LlmChatParams {
  system: string;
  messages: LlmMessage[];
  tools?: LlmTool[];
  /** Overrides the configured model — used by the cheap topic classifier. */
  model?: string;
  maxTokens?: number;
  temperature?: number;
}

export const LLM_PROVIDER = 'LLM_PROVIDER';

export interface LlmProvider {
  /** Streams one turn. Ends with exactly one `done` event. */
  chat(params: LlmChatParams): AsyncIterable<LlmEvent>;

  /** Non-streaming, for short single-shot calls like classification. */
  complete(params: LlmChatParams): Promise<{ text: string; usage: LlmUsage }>;
}

/**
 * Thrown when the provider itself fails.
 *
 * Carries a coarse `code` rather than the provider's message: those mention
 * account plans, rate-limit tiers and model names, and none of that belongs in
 * a response to someone asking about brake pads.
 */
export class LlmProviderError extends Error {
  constructor(
    readonly code: 'rate_limited' | 'unauthorized' | 'unavailable' | 'invalid',
    message: string,
  ) {
    super(message);
    this.name = 'LlmProviderError';
  }
}
