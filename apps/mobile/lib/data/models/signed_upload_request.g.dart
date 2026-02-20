// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signed_upload_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SignedUploadRequest _$SignedUploadRequestFromJson(Map<String, dynamic> json) =>
    _SignedUploadRequest(
      purpose: $enumDecode(_$UploadPurposeModelEnumMap, json['purpose']),
      groupId: json['groupId'] as String,
      cycleId: json['cycleId'] as String,
      contentType: json['contentType'] as String,
      fileName: json['fileName'] as String,
    );

Map<String, dynamic> _$SignedUploadRequestToJson(
  _SignedUploadRequest instance,
) => <String, dynamic>{
  'purpose': _$UploadPurposeModelEnumMap[instance.purpose]!,
  'groupId': instance.groupId,
  'cycleId': instance.cycleId,
  'contentType': instance.contentType,
  'fileName': instance.fileName,
};

const _$UploadPurposeModelEnumMap = {
  UploadPurposeModel.contributionProof: 'contribution_proof',
  UploadPurposeModel.payoutProof: 'payout_proof',
};
