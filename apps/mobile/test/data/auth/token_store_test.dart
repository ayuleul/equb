import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/auth/token_store.dart';

void main() {
  group('TokenStore', () {
    test('save, read, and clear session values', () async {
      final store = _InMemorySecureStore();
      final tokenStore = TokenStore(store);
      final issuedAt = DateTime.utc(2026, 2, 20, 12, 0, 0);

      await tokenStore.saveSession(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        userId: 'user-1',
        issuedAt: issuedAt,
      );

      expect(await tokenStore.getAccessToken(), 'access-token');
      expect(await tokenStore.getRefreshToken(), 'refresh-token');
      expect(await tokenStore.getUserId(), 'user-1');
      expect(await tokenStore.getIssuedAt(), issuedAt);

      await tokenStore.clearAll();

      expect(await tokenStore.getAccessToken(), isNull);
      expect(await tokenStore.getRefreshToken(), isNull);
      expect(await tokenStore.getUserId(), isNull);
      expect(await tokenStore.getIssuedAt(), isNull);
    });
  });
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
