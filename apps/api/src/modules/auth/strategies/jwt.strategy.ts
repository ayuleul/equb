import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';

import { AuthenticatedUser } from '../../../common/types/authenticated-user.type';

interface AccessTokenPayload {
  sub: string;
  phone: string;
}

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(configService: ConfigService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey:
        configService.get<string>('JWT_ACCESS_SECRET') ??
        'change-me-access-secret',
    });
  }

  validate(payload: AccessTokenPayload): AuthenticatedUser {
    return {
      id: payload.sub,
      phone: payload.phone,
    };
  }
}
