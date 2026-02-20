import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../auth/token_store.dart';

class DeviceTokenStore {
  DeviceTokenStore(this._store);

  factory DeviceTokenStore.fromSecureStorage(FlutterSecureStorage storage) {
    return DeviceTokenStore(FlutterSecureKeyValueStore(storage));
  }

  static const String _tokenKey = 'notifications_last_registered_token';
  static const String _userIdKey = 'notifications_last_registered_user_id';

  final SecureKeyValueStore _store;

  Future<String?> getLastRegisteredToken() => _store.read(_tokenKey);

  Future<String?> getLastRegisteredUserId() => _store.read(_userIdKey);

  Future<void> saveRegistration({
    required String token,
    required String userId,
  }) async {
    await _store.write(_tokenKey, token);
    await _store.write(_userIdKey, userId);
  }

  Future<void> clear() async {
    await _store.delete(_tokenKey);
    await _store.delete(_userIdKey);
  }
}
