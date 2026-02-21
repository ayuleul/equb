import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SecureKeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class FlutterSecureKeyValueStore implements SecureKeyValueStore {
  FlutterSecureKeyValueStore(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) {
    return _storage.read(key: key);
  }

  @override
  Future<void> write(String key, String value) {
    return _storage.write(key: key, value: value);
  }

  @override
  Future<void> delete(String key) {
    return _storage.delete(key: key);
  }
}

class TokenStore {
  TokenStore(this._store);

  factory TokenStore.fromSecureStorage(FlutterSecureStorage storage) {
    return TokenStore(FlutterSecureKeyValueStore(storage));
  }

  static const String accessTokenKey = 'auth_access_token';
  static const String refreshTokenKey = 'auth_refresh_token';
  static const String userIdKey = 'auth_user_id';
  static const String userJsonKey = 'auth_user_json';
  static const String issuedAtKey = 'auth_issued_at';

  final SecureKeyValueStore _store;

  Future<String?> getAccessToken() => _store.read(accessTokenKey);

  Future<String?> getRefreshToken() => _store.read(refreshTokenKey);

  Future<String?> getUserId() => _store.read(userIdKey);

  Future<String?> getUserJson() => _store.read(userJsonKey);

  Future<DateTime?> getIssuedAt() async {
    final raw = await _store.read(issuedAtKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    return DateTime.tryParse(raw);
  }

  Future<void> setAccessToken(String? token) async {
    await _writeOrDelete(accessTokenKey, token);
  }

  Future<void> setRefreshToken(String? token) async {
    await _writeOrDelete(refreshTokenKey, token);
  }

  Future<void> setUserId(String? userId) async {
    await _writeOrDelete(userIdKey, userId);
  }

  Future<void> setUserJson(String? userJson) async {
    await _writeOrDelete(userJsonKey, userJson);
  }

  Future<void> setIssuedAt(DateTime? issuedAt) async {
    await _writeOrDelete(issuedAtKey, issuedAt?.toIso8601String());
  }

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    String? userId,
    String? userJson,
    DateTime? issuedAt,
  }) async {
    await setAccessToken(accessToken);
    await setRefreshToken(refreshToken);
    await setUserId(userId);
    await setUserJson(userJson);
    await setIssuedAt(issuedAt ?? DateTime.now().toUtc());
  }

  Future<void> clearAll() async {
    await _store.delete(accessTokenKey);
    await _store.delete(refreshTokenKey);
    await _store.delete(userIdKey);
    await _store.delete(userJsonKey);
    await _store.delete(issuedAtKey);
  }

  Future<void> _writeOrDelete(String key, String? value) async {
    if (value == null || value.isEmpty) {
      await _store.delete(key);
      return;
    }

    await _store.write(key, value);
  }
}
