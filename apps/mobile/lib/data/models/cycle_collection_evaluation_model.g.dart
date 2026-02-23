// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cycle_collection_evaluation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CycleCollectionEvaluationModel _$CycleCollectionEvaluationModelFromJson(
  Map<String, dynamic> json,
) => _CycleCollectionEvaluationModel(
  cycleId: json['cycleId'] as String,
  dueAt: DateTime.parse(json['dueAt'] as String),
  graceDays: (json['graceDays'] as num).toInt(),
  graceDeadline: DateTime.parse(json['graceDeadline'] as String),
  evaluatedAt: DateTime.parse(json['evaluatedAt'] as String),
  strictCollection: json['strictCollection'] as bool,
  allVerified: json['allVerified'] as bool,
  readyForPayout: json['readyForPayout'] as bool,
  overdueCount: _toInt(json['overdueCount']),
  lateMarkedCount: _toInt(json['lateMarkedCount']),
  fineLedgerEntriesCreated: _toInt(json['fineLedgerEntriesCreated']),
  notifiedMembersCount: _toInt(json['notifiedMembersCount']),
  notifiedGuarantorsCount: _toInt(json['notifiedGuarantorsCount']),
);

Map<String, dynamic> _$CycleCollectionEvaluationModelToJson(
  _CycleCollectionEvaluationModel instance,
) => <String, dynamic>{
  'cycleId': instance.cycleId,
  'dueAt': instance.dueAt.toIso8601String(),
  'graceDays': instance.graceDays,
  'graceDeadline': instance.graceDeadline.toIso8601String(),
  'evaluatedAt': instance.evaluatedAt.toIso8601String(),
  'strictCollection': instance.strictCollection,
  'allVerified': instance.allVerified,
  'readyForPayout': instance.readyForPayout,
  'overdueCount': instance.overdueCount,
  'lateMarkedCount': instance.lateMarkedCount,
  'fineLedgerEntriesCreated': instance.fineLedgerEntriesCreated,
  'notifiedMembersCount': instance.notifiedMembersCount,
  'notifiedGuarantorsCount': instance.notifiedGuarantorsCount,
};
