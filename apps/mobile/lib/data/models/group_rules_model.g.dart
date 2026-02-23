// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_rules_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
      paymentMethods: _paymentMethodsFromJson(json['paymentMethods']),
      requiresMemberVerification: json['requiresMemberVerification'] as bool,
      strictCollection: json['strictCollection'] as bool,
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
      'paymentMethods': _paymentMethodsToJson(instance.paymentMethods),
      'requiresMemberVerification': instance.requiresMemberVerification,
      'strictCollection': instance.strictCollection,
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
