import 'package:freezed_annotation/freezed_annotation.dart';

import 'reputation_model.dart';

part 'public_group_model.freezed.dart';
part 'public_group_model.g.dart';

enum PublicGroupFrequencyModel {
  @JsonValue('WEEKLY')
  weekly,
  @JsonValue('MONTHLY')
  monthly,
  @JsonValue('CUSTOM_INTERVAL')
  customInterval,
  unknown,
}

enum PublicGroupPayoutModeModel {
  @JsonValue('LOTTERY')
  lottery,
  @JsonValue('AUCTION')
  auction,
  @JsonValue('ROTATION')
  rotation,
  @JsonValue('DECISION')
  decision,
  unknown,
}

enum PublicGroupStartPolicyModel {
  @JsonValue('WHEN_FULL')
  whenFull,
  @JsonValue('ON_DATE')
  onDate,
  @JsonValue('MANUAL')
  manual,
  unknown,
}

enum WinnerSelectionTimingModel {
  @JsonValue('BEFORE_COLLECTION')
  beforeCollection,
  @JsonValue('AFTER_COLLECTION')
  afterCollection,
  unknown,
}

@freezed
sealed class PublicGroupRulesModel with _$PublicGroupRulesModel {
  const factory PublicGroupRulesModel({
    @JsonKey(fromJson: _toInt) required int contributionAmount,
    @JsonKey(unknownEnumValue: PublicGroupFrequencyModel.unknown)
    required PublicGroupFrequencyModel frequency,
    int? customIntervalDays,
    @JsonKey(unknownEnumValue: PublicGroupPayoutModeModel.unknown)
    required PublicGroupPayoutModeModel payoutMode,
    @JsonKey(fromJson: _toInt) required int roundSize,
    @JsonKey(unknownEnumValue: PublicGroupStartPolicyModel.unknown)
    required PublicGroupStartPolicyModel startPolicy,
    DateTime? startAt,
    int? minToStart,
    @JsonKey(unknownEnumValue: WinnerSelectionTimingModel.unknown)
    required WinnerSelectionTimingModel winnerSelectionTiming,
  }) = _PublicGroupRulesModel;

  factory PublicGroupRulesModel.fromJson(Map<String, dynamic> json) =>
      _$PublicGroupRulesModelFromJson(json);
}

@freezed
sealed class PublicGroupModel with _$PublicGroupModel {
  const factory PublicGroupModel({
    required String id,
    required String name,
    String? description,
    required String currency,
    @JsonKey(fromJson: _toInt) required int contributionAmount,
    @JsonKey(unknownEnumValue: PublicGroupFrequencyModel.unknown)
    required PublicGroupFrequencyModel frequency,
    @JsonKey(unknownEnumValue: PublicGroupPayoutModeModel.unknown)
    PublicGroupPayoutModeModel? payoutMode,
    @JsonKey(fromJson: _toInt) required int memberCount,
    required bool alreadyStarted,
    String? hostName,
    String? hostTier,
    @JsonKey(fromJson: _toNullableInt) int? hostReputationAtCreation,
    String? hostReputationLevel,
    AllowedPublicEqubLimitsModel? allowedPublicEqubLimits,
    HostReputationSummaryModel? host,
    GroupTrustSummaryModel? trustSummary,
    bool? rulesetConfigured,
    bool? isCurrentUserMember,
    PublicGroupRulesModel? rules,
  }) = _PublicGroupModel;

  factory PublicGroupModel.fromJson(Map<String, dynamic> json) =>
      _$PublicGroupModelFromJson(json);
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

int? _toNullableInt(Object? value) {
  if (value == null) {
    return null;
  }
  return _toInt(value);
}
