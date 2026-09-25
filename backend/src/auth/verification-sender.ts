import { Injectable, Logger } from '@nestjs/common';

/** Where a confirmation code has to be delivered. */
export interface VerificationTarget {
  login: string | null;
  phone: string | null;
}

/**
 * Delivers confirmation codes.
 *
 * An interface rather than a concrete client, because the channel is the one
 * part of this feature that cannot be finished here: sending real SMS needs a
 * gateway account, and sending real mail needs an SMTP server or a mail API.
 * Everything around delivery — generating the code, storing it hashed, expiry,
 * attempt limits, creating the account only after a correct code — works the
 * same whichever provider is eventually plugged in.
 *
 * To go live, write one class implementing this and bind it to
 * [VERIFICATION_SENDER] in auth.module.ts. Nothing else changes.
 */
export interface VerificationSender {
  send(target: VerificationTarget, code: string): Promise<void>;
}

/** DI token — an interface cannot be one in TypeScript. */
export const VERIFICATION_SENDER = 'VERIFICATION_SENDER';

/**
 * Development sender: writes the code to the server log instead of sending it.
 *
 * The default, because it is honest — it never pretends a message went out. It
 * is also why the code is never put in the HTTP response: that would be
 * convenient locally and a complete bypass of the confirmation in production,
 * since anyone could read their own code straight out of the reply.
 */
@Injectable()
export class LoggingVerificationSender implements VerificationSender {
  private readonly logger = new Logger('VerificationCode');

  async send(target: VerificationTarget, code: string): Promise<void> {
    const to = target.login ?? target.phone ?? '(unknown)';
    this.logger.warn(
      `No delivery provider configured — code for ${to} is ${code}. ` +
        'Configure a real sender before this reaches users.',
    );
  }
}
