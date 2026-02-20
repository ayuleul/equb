import 'dart:convert';

import '../api/api_error.dart';
import '../models/user_model.dart';
import 'auth_api.dart';
import 'token_store.dart';

class AuthRepository {
  AuthRepository({required AuthApi authApi, required TokenStore tokenStore})
    : _authApi = authApi,
      _tokenStore = tokenStore;

  final AuthApi _authApi;
  final TokenStore _tokenStore;

  Future<void> requestOtp(String phone) {
    return _authApi.requestOtp(phone);
  }

  Future<UserModel> verifyOtp({
    required String phone,
    required String code,
  }) async {
    final response = await _authApi.verifyOtp(phone: phone, code: code);

    await _tokenStore.saveSession(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      userId: response.user.id,
      issuedAt: DateTime.now().toUtc(),
    );

    return response.user;
  }

  Future<UserModel?> restoreSession() async {
    final accessToken = await _tokenStore.getAccessToken();
    final refreshToken = await _tokenStore.getRefreshToken();

    if (accessToken == null || accessToken.isEmpty) {
      await _tokenStore.clearAll();
      return null;
    }

    if (refreshToken == null || refreshToken.isEmpty) {
      await _tokenStore.clearAll();
      return null;
    }

    final cachedUser = _userFromAccessToken(accessToken);

    try {
      final refreshed = await _authApi.refresh(refreshToken);

      await _tokenStore.saveSession(
        accessToken: refreshed.accessToken,
        refreshToken: refreshed.refreshToken,
        userId: refreshed.user.id,
        issuedAt: DateTime.now().toUtc(),
      );

      return refreshed.user;
    } on ApiError catch (error) {
      if (error.type == ApiErrorType.unauthorized ||
          error.type == ApiErrorType.sessionExpired) {
        await _tokenStore.clearAll();
        return null;
      }

      return cachedUser;
    } catch (_) {
      return cachedUser;
    }
  }

  Future<void> logout() async {
    final refreshToken = await _tokenStore.getRefreshToken();

    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _authApi.logout(refreshToken);
      }
    } finally {
      await _tokenStore.clearAll();
    }
  }

  UserModel? _userFromAccessToken(String token) {
    final payload = _decodeJwtPayload(token);
    if (payload == null) {
      return null;
    }

    final id = payload['sub'];
    final phone = payload['phone'];

    if (id is! String || id.isEmpty || phone is! String || phone.isEmpty) {
      return null;
    }

    return UserModel(id: id, phone: phone, fullName: null);
  }

  Map<String, dynamic>? _decodeJwtPayload(String token) {
    final segments = token.split('.');
    if (segments.length != 3) {
      return null;
    }

    try {
      final normalized = base64Url.normalize(segments[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(decoded);
      if (payload is Map<String, dynamic>) {
        return payload;
      }
    } catch (_) {
      return null;
    }

    return null;
  }
}
