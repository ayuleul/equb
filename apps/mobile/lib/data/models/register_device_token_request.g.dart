// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_device_token_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RegisterDeviceTokenRequest _$RegisterDeviceTokenRequestFromJson(
  Map<String, dynamic> json,
) => _RegisterDeviceTokenRequest(
  token: json['token'] as String,
  platform: $enumDecode(_$DevicePlatformModelEnumMap, json['platform']),
);

Map<String, dynamic> _$RegisterDeviceTokenRequestToJson(
  _RegisterDeviceTokenRequest instance,
) => <String, dynamic>{
  'token': instance.token,
  'platform': _$DevicePlatformModelEnumMap[instance.platform]!,
};

const _$DevicePlatformModelEnumMap = {
  DevicePlatformModel.ios: 'IOS',
  DevicePlatformModel.android: 'ANDROID',
  DevicePlatformModel.web: 'WEB',
};
