import '../api/api_client.dart';
import '../models/auth_response.dart';

class AuthApi {
  AuthApi(this._apiClient);

  final ApiClient _apiClient;

  Future<String> requestOtp(String phone) async {
    final payload = await _apiClient.postMap(
      '/auth/request-otp',
      data: <String, dynamic>{'phone': phone},
    );

    final message = payload['message'];
    return message is String && message.isNotEmpty ? message : 'OTP sent';
  }

  Future<AuthResponse> verifyOtp({
    required String phone,
    required String code,
  }) async {
    final payload = await _apiClient.postMap(
      '/auth/verify-otp',
      data: <String, dynamic>{'phone': phone, 'code': code},
    );

    return AuthResponse.fromJson(payload);
  }

  Future<AuthResponse> refresh(String refreshToken) async {
    final payload = await _apiClient.postMap(
      '/auth/refresh',
      data: <String, dynamic>{'refreshToken': refreshToken},
    );

    return AuthResponse.fromJson(payload);
  }

  Future<bool> logout(String refreshToken) async {
    final payload = await _apiClient.postMap(
      '/auth/logout',
      data: <String, dynamic>{'refreshToken': refreshToken},
    );

    final success = payload['success'];
    return success == true;
  }
}
