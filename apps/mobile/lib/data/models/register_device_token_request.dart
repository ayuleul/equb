import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_device_token_request.freezed.dart';
part 'register_device_token_request.g.dart';

enum DevicePlatformModel {
  @JsonValue('IOS')
  ios,
  @JsonValue('ANDROID')
  android,
  @JsonValue('WEB')
  web,
}

@freezed
sealed class RegisterDeviceTokenRequest with _$RegisterDeviceTokenRequest {
  const factory RegisterDeviceTokenRequest({
    required String token,
    required DevicePlatformModel platform,
  }) = _RegisterDeviceTokenRequest;

  factory RegisterDeviceTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterDeviceTokenRequestFromJson(json);
}

DevicePlatformModel currentDevicePlatform() {
  if (kIsWeb) {
    return DevicePlatformModel.web;
  }

  return switch (defaultTargetPlatform) {
    TargetPlatform.iOS => DevicePlatformModel.ios,
    TargetPlatform.android => DevicePlatformModel.android,
    _ => DevicePlatformModel.web,
  };
}
