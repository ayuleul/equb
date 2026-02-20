import 'package:freezed_annotation/freezed_annotation.dart';

part 'signed_upload_request.freezed.dart';
part 'signed_upload_request.g.dart';

enum UploadPurposeModel {
  @JsonValue('contribution_proof')
  contributionProof,
  @JsonValue('payout_proof')
  payoutProof,
}

@freezed
sealed class SignedUploadRequest with _$SignedUploadRequest {
  const factory SignedUploadRequest({
    required UploadPurposeModel purpose,
    required String groupId,
    required String cycleId,
    required String contentType,
    required String fileName,
  }) = _SignedUploadRequest;

  factory SignedUploadRequest.fromJson(Map<String, dynamic> json) =>
      _$SignedUploadRequestFromJson(json);
}
