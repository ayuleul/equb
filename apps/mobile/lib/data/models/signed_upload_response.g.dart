// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signed_upload_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SignedUploadResponse _$SignedUploadResponseFromJson(
  Map<String, dynamic> json,
) => _SignedUploadResponse(
  key: json['key'] as String,
  uploadUrl: json['uploadUrl'] as String,
  expiresInSeconds: _toInt(json['expiresInSeconds']),
);

Map<String, dynamic> _$SignedUploadResponseToJson(
  _SignedUploadResponse instance,
) => <String, dynamic>{
  'key': instance.key,
  'uploadUrl': instance.uploadUrl,
  'expiresInSeconds': instance.expiresInSeconds,
};

_SignedDownloadResponse _$SignedDownloadResponseFromJson(
  Map<String, dynamic> json,
) => _SignedDownloadResponse(
  downloadUrl: json['downloadUrl'] as String,
  expiresInSeconds: _toInt(json['expiresInSeconds']),
);

Map<String, dynamic> _$SignedDownloadResponseToJson(
  _SignedDownloadResponse instance,
) => <String, dynamic>{
  'downloadUrl': instance.downloadUrl,
  'expiresInSeconds': instance.expiresInSeconds,
};
