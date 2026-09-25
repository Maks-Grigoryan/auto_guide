import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
  createParamDecorator,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import type { Request } from 'express';
import type { UserRole } from './auth.service';

/** Claims carried by an access token. */
export interface JwtPayload {
  sub: string;
  role: UserRole;
}

export interface AuthenticatedRequest extends Request {
  user?: JwtPayload;
}

/**
 * Rejects requests without a valid `Authorization: Bearer <token>` header and
 * attaches the decoded claims to the request.
 *
 * The role is read from the signed token rather than re-queried per request:
 * the signature is what makes it trustworthy, and a database round trip on
 * every call would buy nothing here. The trade-off is that a role change takes
 * effect only once the holder's token expires — acceptable while promotion
 * happens by hand through `admin:create`.
 */
@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(private readonly jwt: JwtService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<AuthenticatedRequest>();
    const header = request.headers.authorization;

    if (!header?.startsWith('Bearer ')) {
      throw new UnauthorizedException('Missing bearer token');
    }

    try {
      request.user = await this.jwt.verifyAsync<JwtPayload>(header.slice(7));
    } catch {
      // Expired, tampered with, or signed by a different secret — all one
      // answer to the caller. Which of the three it was is not their business.
      throw new UnauthorizedException('Invalid or expired token');
    }
    return true;
  }
}

/** Injects the claims that [JwtAuthGuard] attached to the request. */
export const CurrentUser = createParamDecorator(
  (_data: unknown, context: ExecutionContext): JwtPayload => {
    const request = context.switchToHttp().getRequest<AuthenticatedRequest>();
    if (!request.user) {
      // Reaching here means the route forgot @UseGuards(JwtAuthGuard). Failing
      // loudly beats handing the handler an undefined user.
      throw new UnauthorizedException('Route is not guarded');
    }
    return request.user;
  },
);
