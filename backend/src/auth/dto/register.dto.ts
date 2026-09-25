import { IsString, MaxLength, MinLength } from 'class-validator';
import { MAX_PASSWORD_LENGTH } from '../password';

/**
 * Registration payload: one identifier and a password.
 *
 * `identifier` is an email address or a phone number — whichever the person
 * has. Which of the two it is gets decided by `classifyIdentifier` in the
 * service, because that is also where the value is normalised and where the
 * column is chosen; splitting the rule between a DTO and a service would let
 * the two drift apart. Only length is checked here, for the same reason.
 *
 * There is no `role` field, and adding one would change nothing: the service
 * never reads a role from a request body. An admin exists only after
 * `npm run admin:create`.
 */
export class RegisterDto {
  @IsString()
  @MinLength(3)
  @MaxLength(254) // RFC 5321 limit for a full address
  identifier!: string;

  @IsString()
  @MinLength(8, { message: 'password must be at least 8 characters' })
  @MaxLength(MAX_PASSWORD_LENGTH)
  password!: string;
}
