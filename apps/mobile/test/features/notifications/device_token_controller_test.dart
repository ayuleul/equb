import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/bootstrap.dart';
import 'package:mobile/data/auth/token_store.dart';
import 'package:mobile/data/models/register_device_token_request.dart';
import 'package:mobile/data/notifications/device_token_store.dart';
import 'package:mobile/data/notifications/devices_api.dart';
import 'package:mobile/data/notifications/devices_repository.dart';
import 'package:mobile/features/notifications/device_token_controller.dart';
import 'package:mobile/features/notifications/notification_bootstrap_service.dart';

void main() {
  test('registers device token only when changed per user', () async {
    final fakeBootstrap = _FakeNotificationBootstrap(token: 'token-1');
    final fakeDevicesRepository = _FakeDevicesRepository();
    final tokenStore = DeviceTokenStore(_InMemorySecureStore());

    final container = ProviderContainer(
      overrides: [
        notificationBootstrapProvider.overrideWithValue(fakeBootstrap),
        devicesRepositoryProvider.overrideWithValue(fakeDevicesRepository),
        deviceTokenStoreProvider.overrideWithValue(tokenStore),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(deviceTokenControllerProvider.notifier);

    await controller.syncTokenForUser('user-1');
    expect(fakeDevicesRepository.registerCalls.length, 1);

    await controller.syncTokenForUser('user-1');
    expect(fakeDevicesRepository.registerCalls.length, 1);

    fakeBootstrap.token = 'token-2';
    await controller.syncTokenForUser('user-1');
    expect(fakeDevicesRepository.registerCalls.length, 2);

    await controller.syncTokenForUser('user-2');
    expect(fakeDevicesRepository.registerCalls.length, 3);
  });
}

class _FakeNotificationBootstrap implements NotificationBootstrap {
  _FakeNotificationBootstrap({required this.token});

  String token;

  @override
  Future<String?> getDeviceToken() async => token;

  @override
  Future<void> initialize({
    required NotificationForegroundCallback onForegroundNotification,
    required NotificationPayloadCallback onPayloadOpened,
    NotificationTokenCallback? onTokenRefresh,
  }) async {}

  @override
  void simulatePayloadTap(Map<String, dynamic> payload) {}

  @override
  void dispose() {}
}

class _FakeDevicesRepository extends DevicesRepository {
  _FakeDevicesRepository() : super(_FakeDevicesApi());

  final List<({String token, DevicePlatformModel platform})> registerCalls =
      <({String token, DevicePlatformModel platform})>[];

  @override
  Future<void> registerToken({
    required String token,
    required DevicePlatformModel platform,
  }) async {
    registerCalls.add((token: token, platform: platform));
  }
}

class _FakeDevicesApi implements DevicesApi {
  @override
  Future<Map<String, dynamic>> registerToken(
    RegisterDeviceTokenRequest request,
  ) {
    throw UnimplementedError();
  }
}

class _InMemorySecureStore implements SecureKeyValueStore {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }

  @override
  Future<String?> read(String key) async {
    return _values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }
}
