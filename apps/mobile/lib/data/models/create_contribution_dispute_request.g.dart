// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_contribution_dispute_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateContributionDisputeRequest _$CreateContributionDisputeRequestFromJson(
  Map<String, dynamic> json,
) => _CreateContributionDisputeRequest(
  reason: json['reason'] as String,
  note: json['note'] as String?,
);

Map<String, dynamic> _$CreateContributionDisputeRequestToJson(
  _CreateContributionDisputeRequest instance,
) => <String, dynamic>{'reason': instance.reason, 'note': instance.note};
