// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_rules_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroupStartReadinessModel _$GroupStartReadinessModelFromJson(
  Map<String, dynamic> json,
) => _GroupStartReadinessModel(
  eligibleCount: _toInt(json['eligibleCount']),
  isReadyToStart: json['isReadyToStart'] as bool,
  isWaitingForMembers: json['isWaitingForMembers'] as bool,
  isWaitingForDate: json['isWaitingForDate'] as bool,
);

Map<String, dynamic> _$GroupStartReadinessModelToJson(
  _GroupStartReadinessModel instance,
) => <String, dynamic>{
  'eligibleCount': instance.eligibleCount,
  'isReadyToStart': instance.isReadyToStart,
  'isWaitingForMembers': instance.isWaitingForMembers,
  'isWaitingForDate': instance.isWaitingForDate,
};

_GroupRulesModel _$GroupRulesModelFromJson(Map<String, dynamic> json) =>
    _GroupRulesModel(
      groupId: json['groupId'] as String,
      contributionAmount: _toInt(json['contributionAmount']),
      frequency: $enumDecode(
        _$GroupRuleFrequencyModelEnumMap,
        json['frequency'],
        unknownValue: GroupRuleFrequencyModel.unknown,
      ),
      customIntervalDays: _toNullableInt(json['customIntervalDays']),
      graceDays: _toInt(json['graceDays']),
      fineType: $enumDecode(
        _$GroupRuleFineTypeModelEnumMap,
        json['fineType'],
        unknownValue: GroupRuleFineTypeModel.unknown,
      ),
      fineAmount: _toInt(json['fineAmount']),
      payoutMode: $enumDecode(
        _$GroupRulePayoutModeModelEnumMap,
        json['payoutMode'],
        unknownValue: GroupRulePayoutModeModel.unknown,
      ),
      winnerSelectionTiming: $enumDecode(
        _$WinnerSelectionTimingModelEnumMap,
        json['winnerSelectionTiming'],
        unknownValue: WinnerSelectionTimingModel.unknown,
      ),
      paymentMethods: _paymentMethodsFromJson(json['paymentMethods']),
      requiresMemberVerification: json['requiresMemberVerification'] as bool,
      strictCollection: json['strictCollection'] as bool,
      roundSize: _toInt(json['roundSize']),
      startPolicy: $enumDecode(
        _$StartPolicyModelEnumMap,
        json['startPolicy'],
        unknownValue: StartPolicyModel.unknown,
      ),
      startAt: json['startAt'] == null
          ? null
          : DateTime.parse(json['startAt'] as String),
      minToStart: _toNullableInt(json['minToStart']),
      requiredToStart: _toInt(json['requiredToStart']),
      readiness: GroupStartReadinessModel.fromJson(
        json['readiness'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$GroupRulesModelToJson(_GroupRulesModel instance) =>
    <String, dynamic>{
      'groupId': instance.groupId,
      'contributionAmount': instance.contributionAmount,
      'frequency': _$GroupRuleFrequencyModelEnumMap[instance.frequency]!,
      'customIntervalDays': instance.customIntervalDays,
      'graceDays': instance.graceDays,
      'fineType': _$GroupRuleFineTypeModelEnumMap[instance.fineType]!,
      'fineAmount': instance.fineAmount,
      'payoutMode': _$GroupRulePayoutModeModelEnumMap[instance.payoutMode]!,
      'winnerSelectionTiming':
          _$WinnerSelectionTimingModelEnumMap[instance.winnerSelectionTiming]!,
      'paymentMethods': _paymentMethodsToJson(instance.paymentMethods),
      'requiresMemberVerification': instance.requiresMemberVerification,
      'strictCollection': instance.strictCollection,
      'roundSize': instance.roundSize,
      'startPolicy': _$StartPolicyModelEnumMap[instance.startPolicy]!,
      'startAt': instance.startAt?.toIso8601String(),
      'minToStart': instance.minToStart,
      'requiredToStart': instance.requiredToStart,
      'readiness': instance.readiness,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$GroupRuleFrequencyModelEnumMap = {
  GroupRuleFrequencyModel.weekly: 'WEEKLY',
  GroupRuleFrequencyModel.monthly: 'MONTHLY',
  GroupRuleFrequencyModel.customInterval: 'CUSTOM_INTERVAL',
  GroupRuleFrequencyModel.unknown: 'unknown',
};

const _$GroupRuleFineTypeModelEnumMap = {
  GroupRuleFineTypeModel.none: 'NONE',
  GroupRuleFineTypeModel.fixedAmount: 'FIXED_AMOUNT',
  GroupRuleFineTypeModel.unknown: 'unknown',
};

const _$GroupRulePayoutModeModelEnumMap = {
  GroupRulePayoutModeModel.lottery: 'LOTTERY',
  GroupRulePayoutModeModel.auction: 'AUCTION',
  GroupRulePayoutModeModel.rotation: 'ROTATION',
  GroupRulePayoutModeModel.decision: 'DECISION',
  GroupRulePayoutModeModel.unknown: 'unknown',
};

const _$WinnerSelectionTimingModelEnumMap = {
  WinnerSelectionTimingModel.beforeCollection: 'BEFORE_COLLECTION',
  WinnerSelectionTimingModel.afterCollection: 'AFTER_COLLECTION',
  WinnerSelectionTimingModel.unknown: 'unknown',
};

const _$StartPolicyModelEnumMap = {
  StartPolicyModel.whenFull: 'WHEN_FULL',
  StartPolicyModel.onDate: 'ON_DATE',
  StartPolicyModel.manual: 'MANUAL',
  StartPolicyModel.unknown: 'unknown',
};
