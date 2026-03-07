// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_group_rules_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateGroupRulesRequest _$UpdateGroupRulesRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateGroupRulesRequest(
  contributionAmount: (json['contributionAmount'] as num).toInt(),
  frequency: $enumDecode(
    _$GroupRuleFrequencyModelEnumMap,
    json['frequency'],
    unknownValue: GroupRuleFrequencyModel.unknown,
  ),
  customIntervalDays: (json['customIntervalDays'] as num?)?.toInt(),
  graceDays: (json['graceDays'] as num).toInt(),
  fineType: $enumDecode(
    _$GroupRuleFineTypeModelEnumMap,
    json['fineType'],
    unknownValue: GroupRuleFineTypeModel.unknown,
  ),
  fineAmount: (json['fineAmount'] as num).toInt(),
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
  startPolicy: $enumDecode(
    _$StartPolicyModelEnumMap,
    json['startPolicy'],
    unknownValue: StartPolicyModel.unknown,
  ),
  roundSize: (json['roundSize'] as num).toInt(),
  startAt: json['startAt'] == null
      ? null
      : DateTime.parse(json['startAt'] as String),
  minToStart: (json['minToStart'] as num?)?.toInt(),
);

Map<String, dynamic> _$UpdateGroupRulesRequestToJson(
  _UpdateGroupRulesRequest instance,
) => <String, dynamic>{
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
  'startPolicy': _$StartPolicyModelEnumMap[instance.startPolicy]!,
  'roundSize': instance.roundSize,
  'startAt': _nullableDateToIsoString(instance.startAt),
  'minToStart': instance.minToStart,
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
