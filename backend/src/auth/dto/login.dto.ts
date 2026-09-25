import { IsString, MaxLength, MinLength } from 'class-validator';
import { MAX_PASSWORD_LENGTH } from '../password';

/**
 * Sign-in payload.
 *
 * One `identifier` field carries either a phone number or an email address —
 * the service decides which by looking for an `@`. Two separate fields would
 * force the person signing in to first classify what they are typing, which is
 * a question the server can answer for them.
 *
 * The identifier is checked only for length here. A stricter format rule would
 * reject a typo with "not a valid email" before the password is considered at
 * all, separating a malformed identifier from a wrong password — the exact
 * distinction login is careful not to expose.
 */
export class LoginDto {
  @IsString()
  @MinLength(3)
  @MaxLength(254)
  identifier!: string;

  @IsString()
  @MinLength(1)
  @MaxLength(MAX_PASSWORD_LENGTH)
  password!: string;
}
