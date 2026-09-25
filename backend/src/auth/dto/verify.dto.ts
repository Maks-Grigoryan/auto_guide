import {
  IsString,
  Length,
  Matches,
  MaxLength,
  MinLength,
} from 'class-validator';

/**
 * Confirmation payload: the identifier registration was started with, and the
 * code that was sent to it.
 *
 * The identifier is repeated rather than kept in a server session, so the flow
 * survives a reload, a move to another device, or the app being closed between
 * the two steps. What protects the account is the code, not the fact of having
 * been here a moment ago.
 */
export class VerifyDto {
  @IsString()
  @MinLength(3)
  @MaxLength(254)
  identifier!: string;

  @IsString()
  @Length(6, 6, { message: 'code must be 6 digits' })
  @Matches(/^\d{6}$/, { message: 'code must be 6 digits' })
  code!: string;
}
