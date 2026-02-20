import 'package:freezed_annotation/freezed_annotation.dart';

import 'auth_tokens.dart';
import 'user_model.dart';

part 'auth_response.freezed.dart';
part 'auth_response.g.dart';

@freezed
sealed class AuthResponse with _$AuthResponse {
  const AuthResponse._();

  const factory AuthResponse({
    required String accessToken,
    required String refreshToken,
    required UserModel user,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  AuthTokens get tokens =>
      AuthTokens(accessToken: accessToken, refreshToken: refreshToken);
}
