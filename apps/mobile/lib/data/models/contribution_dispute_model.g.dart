// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contribution_dispute_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ContributionDisputeModel _$ContributionDisputeModelFromJson(
  Map<String, dynamic> json,
) => _ContributionDisputeModel(
  id: json['id'] as String,
  groupId: json['groupId'] as String,
  cycleId: json['cycleId'] as String,
  contributionId: json['contributionId'] as String,
  reportedByUserId: json['reportedByUserId'] as String,
  status: $enumDecode(
    _$ContributionDisputeStatusModelEnumMap,
    json['status'],
    unknownValue: ContributionDisputeStatusModel.unknown,
  ),
  reason: json['reason'] as String,
  note: json['note'] as String?,
  mediationNote: json['mediationNote'] as String?,
  mediatedAt: json['mediatedAt'] == null
      ? null
      : DateTime.parse(json['mediatedAt'] as String),
  mediatedByUserId: json['mediatedByUserId'] as String?,
  resolutionOutcome: json['resolutionOutcome'] as String?,
  resolutionNote: json['resolutionNote'] as String?,
  resolvedAt: json['resolvedAt'] == null
      ? null
      : DateTime.parse(json['resolvedAt'] as String),
  resolvedByUserId: json['resolvedByUserId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ContributionDisputeModelToJson(
  _ContributionDisputeModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'groupId': instance.groupId,
  'cycleId': instance.cycleId,
  'contributionId': instance.contributionId,
  'reportedByUserId': instance.reportedByUserId,
  'status': _$ContributionDisputeStatusModelEnumMap[instance.status]!,
  'reason': instance.reason,
  'note': instance.note,
  'mediationNote': instance.mediationNote,
  'mediatedAt': instance.mediatedAt?.toIso8601String(),
  'mediatedByUserId': instance.mediatedByUserId,
  'resolutionOutcome': instance.resolutionOutcome,
  'resolutionNote': instance.resolutionNote,
  'resolvedAt': instance.resolvedAt?.toIso8601String(),
  'resolvedByUserId': instance.resolvedByUserId,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$ContributionDisputeStatusModelEnumMap = {
  ContributionDisputeStatusModel.open: 'OPEN',
  ContributionDisputeStatusModel.mediating: 'MEDIATING',
  ContributionDisputeStatusModel.resolved: 'RESOLVED',
  ContributionDisputeStatusModel.unknown: 'unknown',
};
