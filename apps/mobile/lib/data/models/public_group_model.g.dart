// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PublicGroupRulesModel _$PublicGroupRulesModelFromJson(
  Map<String, dynamic> json,
) => _PublicGroupRulesModel(
  contributionAmount: _toInt(json['contributionAmount']),
  frequency: $enumDecode(
    _$PublicGroupFrequencyModelEnumMap,
    json['frequency'],
    unknownValue: PublicGroupFrequencyModel.unknown,
  ),
  customIntervalDays: (json['customIntervalDays'] as num?)?.toInt(),
  payoutMode: $enumDecode(
    _$PublicGroupPayoutModeModelEnumMap,
    json['payoutMode'],
    unknownValue: PublicGroupPayoutModeModel.unknown,
  ),
  roundSize: _toInt(json['roundSize']),
  startPolicy: $enumDecode(
    _$PublicGroupStartPolicyModelEnumMap,
    json['startPolicy'],
    unknownValue: PublicGroupStartPolicyModel.unknown,
  ),
  startAt: json['startAt'] == null
      ? null
      : DateTime.parse(json['startAt'] as String),
  minToStart: (json['minToStart'] as num?)?.toInt(),
  winnerSelectionTiming: $enumDecode(
    _$WinnerSelectionTimingModelEnumMap,
    json['winnerSelectionTiming'],
    unknownValue: WinnerSelectionTimingModel.unknown,
  ),
);

Map<String, dynamic> _$PublicGroupRulesModelToJson(
  _PublicGroupRulesModel instance,
) => <String, dynamic>{
  'contributionAmount': instance.contributionAmount,
  'frequency': _$PublicGroupFrequencyModelEnumMap[instance.frequency]!,
  'customIntervalDays': instance.customIntervalDays,
  'payoutMode': _$PublicGroupPayoutModeModelEnumMap[instance.payoutMode]!,
  'roundSize': instance.roundSize,
  'startPolicy': _$PublicGroupStartPolicyModelEnumMap[instance.startPolicy]!,
  'startAt': instance.startAt?.toIso8601String(),
  'minToStart': instance.minToStart,
  'winnerSelectionTiming':
      _$WinnerSelectionTimingModelEnumMap[instance.winnerSelectionTiming]!,
};

const _$PublicGroupFrequencyModelEnumMap = {
  PublicGroupFrequencyModel.weekly: 'WEEKLY',
  PublicGroupFrequencyModel.monthly: 'MONTHLY',
  PublicGroupFrequencyModel.customInterval: 'CUSTOM_INTERVAL',
  PublicGroupFrequencyModel.unknown: 'unknown',
};

const _$PublicGroupPayoutModeModelEnumMap = {
  PublicGroupPayoutModeModel.lottery: 'LOTTERY',
  PublicGroupPayoutModeModel.auction: 'AUCTION',
  PublicGroupPayoutModeModel.rotation: 'ROTATION',
  PublicGroupPayoutModeModel.decision: 'DECISION',
  PublicGroupPayoutModeModel.unknown: 'unknown',
};

const _$PublicGroupStartPolicyModelEnumMap = {
  PublicGroupStartPolicyModel.whenFull: 'WHEN_FULL',
  PublicGroupStartPolicyModel.onDate: 'ON_DATE',
  PublicGroupStartPolicyModel.manual: 'MANUAL',
  PublicGroupStartPolicyModel.unknown: 'unknown',
};

const _$WinnerSelectionTimingModelEnumMap = {
  WinnerSelectionTimingModel.beforeCollection: 'BEFORE_COLLECTION',
  WinnerSelectionTimingModel.afterCollection: 'AFTER_COLLECTION',
  WinnerSelectionTimingModel.unknown: 'unknown',
};

_PublicGroupModel _$PublicGroupModelFromJson(
  Map<String, dynamic> json,
) => _PublicGroupModel(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  currency: json['currency'] as String,
  contributionAmount: _toInt(json['contributionAmount']),
  frequency: $enumDecode(
    _$PublicGroupFrequencyModelEnumMap,
    json['frequency'],
    unknownValue: PublicGroupFrequencyModel.unknown,
  ),
  payoutMode: $enumDecodeNullable(
    _$PublicGroupPayoutModeModelEnumMap,
    json['payoutMode'],
    unknownValue: PublicGroupPayoutModeModel.unknown,
  ),
  memberCount: _toInt(json['memberCount']),
  alreadyStarted: json['alreadyStarted'] as bool,
  hostName: json['hostName'] as String?,
  hostTier: json['hostTier'] as String?,
  hostReputationAtCreation: _toNullableInt(json['hostReputationAtCreation']),
  hostReputationLevel: json['hostReputationLevel'] as String?,
  allowedPublicEqubLimits: json['allowedPublicEqubLimits'] == null
      ? null
      : AllowedPublicEqubLimitsModel.fromJson(
          json['allowedPublicEqubLimits'] as Map<String, dynamic>,
        ),
  host: json['host'] == null
      ? null
      : HostReputationSummaryModel.fromJson(
          json['host'] as Map<String, dynamic>,
        ),
  trustSummary: json['trustSummary'] == null
      ? null
      : GroupTrustSummaryModel.fromJson(
          json['trustSummary'] as Map<String, dynamic>,
        ),
  rulesetConfigured: json['rulesetConfigured'] as bool?,
  isCurrentUserMember: json['isCurrentUserMember'] as bool?,
  rules: json['rules'] == null
      ? null
      : PublicGroupRulesModel.fromJson(json['rules'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PublicGroupModelToJson(_PublicGroupModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'currency': instance.currency,
      'contributionAmount': instance.contributionAmount,
      'frequency': _$PublicGroupFrequencyModelEnumMap[instance.frequency]!,
      'payoutMode': _$PublicGroupPayoutModeModelEnumMap[instance.payoutMode],
      'memberCount': instance.memberCount,
      'alreadyStarted': instance.alreadyStarted,
      'hostName': instance.hostName,
      'hostTier': instance.hostTier,
      'hostReputationAtCreation': instance.hostReputationAtCreation,
      'hostReputationLevel': instance.hostReputationLevel,
      'allowedPublicEqubLimits': instance.allowedPublicEqubLimits,
      'host': instance.host,
      'trustSummary': instance.trustSummary,
      'rulesetConfigured': instance.rulesetConfigured,
      'isCurrentUserMember': instance.isCurrentUserMember,
      'rules': instance.rules,
    };
