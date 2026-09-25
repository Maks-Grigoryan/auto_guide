import {
  Body,
  Controller,
  Get,
  HttpCode,
  NotFoundException,
  Post,
  UseGuards,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Throttle } from '@nestjs/throttler';
import { AuthService, AuthUser } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { VerifyDto } from './dto/verify.dto';
import { CurrentUser, JwtAuthGuard, JwtPayload } from './jwt-auth.guard';

interface AuthResponse {
  accessToken: string;
  user: AuthUser;
}

/** Where a confirmation code was sent, so the app can name it. */
interface SentTo {
  login: string | null;
  phone: string | null;
}

@Controller('auth')
export class AuthController {
  constructor(
    private readonly auth: AuthService,
    private readonly jwt: JwtService,
  ) {}

  /**
   * Creates a plain user account and signs them straight in.
   *
   * A `role` in the body is ignored twice over: `whitelist: true` on the global
   * ValidationPipe strips properties the DTO does not declare, and the service
   * has no role parameter to pass one to even if it survived.
   */
  /**
   * Starts registration: sends a confirmation code and creates no account.
   *
   * 202, not 201 — nothing has been created yet, the request is only accepted
   * for processing. Calling it again with the same identifier replaces the
   * previous code, which is also how «send it again» works: there is no
   * separate resend endpoint to keep in step with this one.
   */
  @Post('register')
  @HttpCode(202)
  @Throttle({ default: { limit: 5, ttl: 60_000 } })
  async register(@Body() dto: RegisterDto): Promise<{ sentTo: SentTo }> {
    // One identifier in, the service works out whether it is an address or a
    // number and rejects anything that is neither.
    const target = await this.auth.startRegistration(
      dto.identifier,
      dto.password,
    );
    // Echo the destination, never the code: the app says «sent to …», and
    // putting the code here would let anyone confirm an address they cannot
    // actually read.
    return { sentTo: { login: target.login, phone: target.phone } };
  }

  /**
   * Finishes registration: checks the code, creates the account, signs in.
   *
   * Rate-limited like login rather than like registration — this is the
   * endpoint where guessing gets somebody an account.
   */
  @Post('verify')
  @HttpCode(200)
  @Throttle({ default: { limit: 10, ttl: 60_000 } })
  async verify(@Body() dto: VerifyDto): Promise<AuthResponse> {
    const user = await this.auth.verifyRegistration(dto.identifier, dto.code);
    return this.sign(user);
  }

  /**
   * Signs in with either identifier. The response carries the account's role,
   * which is what lets the client tell an admin session from a normal one.
   */
  @Post('login')
  @HttpCode(200) // a successful login creates no resource
  // Tighter than registration: this is the endpoint worth guessing passwords
  // at. Ten attempts a minute stays out of the way of someone mistyping their
  // own password while making an online guessing run pointless.
  @Throttle({ default: { limit: 10, ttl: 60_000 } })
  async login(@Body() dto: LoginDto): Promise<AuthResponse> {
    const user = await this.auth.login(dto.identifier, dto.password);
    return this.sign(user);
  }

  /**
   * Returns the signed-in account, read fresh from the database.
   *
   * The token already carries the role, but a client left open since before a
   * promotion would keep showing the stale one; this is how it finds out. It is
   * also how the app checks that a stored token is still worth keeping.
   */
  @Get('me')
  @UseGuards(JwtAuthGuard)
  async me(@CurrentUser() claims: JwtPayload): Promise<AuthUser> {
    const user = await this.auth.findById(claims.sub);
    if (!user) {
      // A validly signed token for an account that has since been deleted.
      throw new NotFoundException('Account no longer exists');
    }
    return user;
  }

  private sign(user: AuthUser): AuthResponse {
    const accessToken = this.jwt.sign({ sub: user.id, role: user.role });
    return { accessToken, user };
  }
}
