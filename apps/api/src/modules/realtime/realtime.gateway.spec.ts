import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { WsException } from '@nestjs/websockets';

import {
  RealtimeAccessService,
  RealtimeGateway,
  RealtimeSocketAuthService,
} from './realtime.gateway';
import { RealtimeService } from './realtime.service';

describe('RealtimeGateway', () => {
  const configService = {
    get: jest.fn((key: string) =>
      key === 'JWT_ACCESS_SECRET' ? 'test-access-secret' : undefined,
    ),
  } as unknown as ConfigService;

  const jwtService = new JwtService();

  function createSocket(overrides?: Record<string, unknown>) {
    return {
      handshake: {
        auth: {},
        headers: {},
      },
      data: {},
      join: jest.fn(),
      leave: jest.fn(),
      disconnect: jest.fn(),
      ...overrides,
    };
  }

  it('authenticates socket connections with the JWT access token', async () => {
    const realtimeService = {
      attachServer: jest.fn(),
    } as unknown as RealtimeService;
    const authService = new RealtimeSocketAuthService(
      jwtService,
      configService,
    );
    const accessService = {
      assertGroupMembership: jest.fn(),
      assertTurnMembership: jest.fn(),
    } as unknown as RealtimeAccessService;
    const gateway = new RealtimeGateway(
      realtimeService,
      authService,
      accessService,
    );
    const server = { use: jest.fn() };

    gateway.afterInit(server as never);

    const middleware = (server.use as jest.Mock).mock.calls[0]?.[0] as (
      socket: ReturnType<typeof createSocket>,
      next: (error?: Error) => void,
    ) => Promise<void>;
    const token = await jwtService.signAsync(
      { sub: 'user-1', phone: '+251911111111' },
      { secret: 'test-access-secret' },
    );
    const socket = createSocket({
      handshake: {
        auth: { token },
        headers: {},
      },
    });
    const next = jest.fn();

    await middleware(socket, next);

    expect(socket.data).toEqual({
      user: { id: 'user-1', phone: '+251911111111' },
    });
    expect(next).toHaveBeenCalledWith();
  });

  it('blocks unauthorized group joins', async () => {
    const gateway = new RealtimeGateway(
      { attachServer: jest.fn() } as never,
      { authenticate: jest.fn() } as never,
      {
        assertGroupMembership: jest
          .fn()
          .mockRejectedValue(new WsException('Forbidden')),
        assertTurnMembership: jest.fn(),
      } as never,
    );
    const socket = createSocket({
      data: {
        user: { id: 'user-1', phone: '+251911111111' },
      },
    });

    await expect(
      gateway.joinGroupRoom(socket as never, { groupId: 'group-1' }),
    ).rejects.toThrow(WsException);
  });
});
