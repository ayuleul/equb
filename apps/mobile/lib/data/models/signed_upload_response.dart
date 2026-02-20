import 'package:freezed_annotation/freezed_annotation.dart';

part 'signed_upload_response.freezed.dart';
part 'signed_upload_response.g.dart';

@freezed
sealed class SignedUploadResponse with _$SignedUploadResponse {
  const factory SignedUploadResponse({
    required String key,
    required String uploadUrl,
    @JsonKey(fromJson: _toInt) required int expiresInSeconds,
  }) = _SignedUploadResponse;

  factory SignedUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$SignedUploadResponseFromJson(json);
}

@freezed
sealed class SignedDownloadResponse with _$SignedDownloadResponse {
  const factory SignedDownloadResponse({
    required String downloadUrl,
    @JsonKey(fromJson: _toInt) required int expiresInSeconds,
  }) = _SignedDownloadResponse;

  factory SignedDownloadResponse.fromJson(Map<String, dynamic> json) =>
      _$SignedDownloadResponseFromJson(json);
}

int _toInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }

  return 0;
}
