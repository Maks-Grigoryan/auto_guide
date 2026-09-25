import { Inject, Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

import { LLM_PROVIDER, LlmMessage, LlmProvider } from './llm/llm-provider';
import { TOPIC_GUARD_PROMPT } from './prompts/system-prompt';

/** Turns of history the gate sees. Enough to judge a bare «а сколько?». */
const CONTEXT_TURNS = 4;

/**
 * Decides whether a message belongs in this app before the expensive model ever
 * sees it.
 *
 * Runs on a small model — an order of magnitude cheaper — so an off-topic
 * question costs a fraction of a cent rather than a full agent loop. It is the
 * first of the layers that keep the assistant on subject; the system prompt and
 * the fixed tool list are the other two.
 */
@Injectable()
export class TopicGuardService {
  private readonly logger = new Logger(TopicGuardService.name);
  private readonly model?: string;

  constructor(
    @Inject(LLM_PROVIDER) private readonly llm: LlmProvider,
    config: ConfigService,
  ) {
    this.model = config.get<string>('LLM_CLASSIFIER_MODEL') || undefined;
  }

  async isOnTopic(message: string, history: LlmMessage[]): Promise<boolean> {
    // With no classifier configured the gate is simply not there. The system
    // prompt and the tool list still hold the line — this layer is about cost,
    // and a missing cheap model must not take the chat down with it.
    if (!this.model) return true;

    const recent = history.slice(-CONTEXT_TURNS);
    const transcript = recent
      .map(
        (turn) =>
          `${turn.role === 'user' ? 'User' : 'Assistant'}: ${turn.content}`,
      )
      .join('\n');

    const question = transcript
      ? `Conversation so far:\n${transcript}\n\nNew message: ${message}`
      : `Message: ${message}`;

    try {
      const { text } = await this.llm.complete({
        system: TOPIC_GUARD_PROMPT,
        messages: [{ role: 'user', content: question }],
        model: this.model,
        maxTokens: 5,
        // Deterministic: this is a classification, not a piece of writing.
        temperature: 0,
      });
      // Look for the refusal rather than the approval — small models like to
      // add a full stop or wrap the word in quotes, and an unreadable answer
      // should let the question through rather than block it.
      return !/\bNO\b/i.test(text.trim());
    } catch (error) {
      // Fail open. A classifier outage must not lock people out of the
      // assistant; the worst case is that one off-topic question costs money.
      this.logger.warn(`Topic guard unavailable: ${(error as Error).message}`);
      return true;
    }
  }
}
