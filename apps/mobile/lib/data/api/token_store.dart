import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStore {
  TokenStore(this._storage);

  static const _accessKey = 'auth_access_token';
  static const _refreshKey = 'auth_refresh_token';

  final FlutterSecureStorage _storage;

  Future<String?> getAccessToken() {
    return _storage.read(key: _accessKey);
  }

  Future<void> setAccessToken(String? token) async {
    if (token == null || token.isEmpty) {
      await _storage.delete(key: _accessKey);
      return;
    }

    await _storage.write(key: _accessKey, value: token);
  }

  Future<String?> getRefreshToken() {
    return _storage.read(key: _refreshKey);
  }

  Future<void> setRefreshToken(String? token) async {
    if (token == null || token.isEmpty) {
      await _storage.delete(key: _refreshKey);
      return;
    }

    await _storage.write(key: _refreshKey, value: token);
  }

  Future<void> saveTokenPair({
    required String accessToken,
    required String refreshToken,
  }) async {
    await setAccessToken(accessToken);
    await setRefreshToken(refreshToken);
  }

  Future<void> clearAll() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
