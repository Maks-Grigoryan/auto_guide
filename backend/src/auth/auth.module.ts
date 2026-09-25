import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { JwtModule, type JwtSignOptions } from '@nestjs/jwt';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import {
  LoggingVerificationSender,
  VERIFICATION_SENDER,
} from './verification-sender';

@Module({
  imports: [
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => {
        const secret = config.get<string>('JWT_SECRET');
        // Fail at boot, not at the first login. Falling back to a built-in
        // default would let the server come up looking healthy while every
        // token it issues is forgeable by anyone who has read this repository.
        if (!secret || secret.length < 32) {
          throw new Error(
            'JWT_SECRET must be set and at least 32 characters long',
          );
        }
        // jsonwebtoken types the duration as a template literal union
        // («30d», «12h», …) rather than plain string, so an env-sourced value
        // has to be narrowed to it.
        const expiresIn = (config.get<string>('JWT_EXPIRES_IN') ??
          '30d') as JwtSignOptions['expiresIn'];

        return {
          secret,
          signOptions: {
            // Long enough that people are not asked to sign in mid-errand,
            // short enough that a token lifted from a shared phone expires.
            expiresIn,
          },
        };
      },
    }),
  ],
  controllers: [AuthController],
  providers: [
    AuthService,
    // Swap this class for a real SMS or mail client to start delivering codes;
    // nothing else in the flow has to change. Until then it writes them to the
    // server log, which is at least honest about not having sent anything.
    { provide: VERIFICATION_SENDER, useClass: LoggingVerificationSender },
  ],
  exports: [AuthService],
})
export class AuthModule {}
