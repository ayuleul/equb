import 'dart:convert';

import '../api/api_error.dart';
import '../models/user_model.dart';
import '../profile/profile_api.dart';
import 'auth_api.dart';
import 'token_store.dart';

class AuthRepository {
  AuthRepository({
    required AuthApi authApi,
    required ProfileApi profileApi,
    required TokenStore tokenStore,
  }) : _authApi = authApi,
       _profileApi = profileApi,
       _tokenStore = tokenStore;

  final AuthApi _authApi;
  final ProfileApi _profileApi;
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
      userJson: jsonEncode(response.user.toJson()),
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

    final cachedUser =
        (await _getCachedUser()) ?? _userFromAccessToken(accessToken);

    try {
      final refreshed = await _authApi.refresh(refreshToken);

      await _tokenStore.saveSession(
        accessToken: refreshed.accessToken,
        refreshToken: refreshed.refreshToken,
        userId: refreshed.user.id,
        userJson: jsonEncode(refreshed.user.toJson()),
        issuedAt: DateTime.now().toUtc(),
      );

      try {
        final mePayload = await _profileApi.getMe();
        final me = UserModel.fromJson(mePayload);
        await _tokenStore.setUserJson(jsonEncode(me.toJson()));
        return me;
      } on ApiError catch (error) {
        if (error.type == ApiErrorType.unauthorized ||
            error.type == ApiErrorType.sessionExpired) {
          await _tokenStore.clearAll();
          return null;
        }

        return refreshed.user;
      } catch (_) {
        return refreshed.user;
      }
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

  Future<void> cacheUser(UserModel user) {
    return _tokenStore.setUserJson(jsonEncode(user.toJson()));
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

  Future<UserModel?> _getCachedUser() async {
    final raw = await _tokenStore.getUserJson();
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return UserModel.fromJson(decoded);
      }
      if (decoded is Map) {
        return UserModel.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      return null;
    }

    return null;
  }
}
