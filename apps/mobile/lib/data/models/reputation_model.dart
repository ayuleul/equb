import 'package:freezed_annotation/freezed_annotation.dart';

part 'reputation_model.freezed.dart';
part 'reputation_model.g.dart';

@freezed
sealed class AllowedPublicEqubLimitsModel with _$AllowedPublicEqubLimitsModel {
  const factory AllowedPublicEqubLimitsModel({
    int? maxMembers,
    @JsonKey(fromJson: _toNullableInt) int? maxContributionAmount,
    int? maxDurationDays,
    int? maxActivePublicEqubs,
  }) = _AllowedPublicEqubLimitsModel;

  factory AllowedPublicEqubLimitsModel.fromJson(Map<String, dynamic> json) =>
      _$AllowedPublicEqubLimitsModelFromJson(json);
}

@freezed
sealed class ReputationBadgeModel with _$ReputationBadgeModel {
  const factory ReputationBadgeModel({
    required String code,
    required String label,
    required String description,
  }) = _ReputationBadgeModel;

  factory ReputationBadgeModel.fromJson(Map<String, dynamic> json) =>
      _$ReputationBadgeModelFromJson(json);
}

@freezed
sealed class ReputationComponentsModel with _$ReputationComponentsModel {
  const factory ReputationComponentsModel({
    @JsonKey(fromJson: _toInt) required int payment,
    @JsonKey(fromJson: _toInt) required int completion,
    @JsonKey(fromJson: _toInt) required int behavior,
    @JsonKey(fromJson: _toInt) required int experience,
  }) = _ReputationComponentsModel;

  factory ReputationComponentsModel.fromJson(Map<String, dynamic> json) =>
      _$ReputationComponentsModelFromJson(json);
}

@freezed
sealed class MemberReputationSummaryModel with _$MemberReputationSummaryModel {
  const MemberReputationSummaryModel._();

  const factory MemberReputationSummaryModel({
    required String userId,
    @JsonKey(fromJson: _toInt) required int trustScore,
    required String trustLevel,
    String? summaryLabel,
    String? level,
    String? icon,
    String? displayLabel,
    String? hostTitle,
    @JsonKey(fromJson: _toInt) @Default(0) int equbsCompleted,
    @JsonKey(fromJson: _toInt) @Default(0) int equbsHosted,
    double? onTimePaymentRate,
  }) = _MemberReputationSummaryModel;

  factory MemberReputationSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$MemberReputationSummaryModelFromJson(json);

  bool get hasEarnedLevel => (displayLabel ?? '').trim().isNotEmpty;
}

@freezed
sealed class HostReputationSummaryModel with _$HostReputationSummaryModel {
  const HostReputationSummaryModel._();

  const factory HostReputationSummaryModel({
    required String userId,
    @JsonKey(fromJson: _toInt) required int trustScore,
    required String trustLevel,
    String? summaryLabel,
    String? level,
    String? icon,
    String? displayLabel,
    String? hostTitle,
    @JsonKey(fromJson: _toInt) required int equbsHosted,
    @JsonKey(fromJson: _toInt) required int hostedEqubsCompleted,
    @JsonKey(fromJson: _toInt) required int turnsParticipated,
    double? hostedCompletionRate,
    @JsonKey(fromJson: _toInt) required int cancelledGroupsCount,
    @JsonKey(fromJson: _toInt) required int hostDisputesCount,
  }) = _HostReputationSummaryModel;

  factory HostReputationSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$HostReputationSummaryModelFromJson(json);

  bool get hasEarnedLevel => (displayLabel ?? '').trim().isNotEmpty;
}

@freezed
sealed class GroupTrustSummaryModel with _$GroupTrustSummaryModel {
  const factory GroupTrustSummaryModel({
    required String groupId,
    @JsonKey(fromJson: _toInt) required int hostScore,
    double? averageMemberScore,
    double? verifiedMembersPercent,
    required String groupTrustLevel,
    required HostReputationSummaryModel host,
  }) = _GroupTrustSummaryModel;

  factory GroupTrustSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$GroupTrustSummaryModelFromJson(json);
}

@freezed
sealed class ReputationEligibilityModel with _$ReputationEligibilityModel {
  const factory ReputationEligibilityModel({
    required bool canHostPublicGroup,
    required bool canJoinHighValuePublicGroup,
    required bool canAccessLending,
    required bool canAccessMarketplace,
    String? hostTier,
    required String hostReputationLevel,
    required AllowedPublicEqubLimitsModel allowedPublicEqubLimits,
  }) = _ReputationEligibilityModel;

  factory ReputationEligibilityModel.fromJson(Map<String, dynamic> json) =>
      _$ReputationEligibilityModelFromJson(json);
}

@freezed
sealed class ReputationHistoryEntryModel with _$ReputationHistoryEntryModel {
  const factory ReputationHistoryEntryModel({
    required String id,
    required String userId,
    required String eventType,
    @JsonKey(fromJson: _toInt) required int scoreDelta,
    @Default(<String, int>{}) Map<String, int> metricChanges,
    String? relatedGroupId,
    String? relatedCycleId,
    Map<String, dynamic>? metadata,
    required DateTime createdAt,
  }) = _ReputationHistoryEntryModel;

  factory ReputationHistoryEntryModel.fromJson(Map<String, dynamic> json) =>
      _$ReputationHistoryEntryModelFromJson(json);
}

@freezed
sealed class ReputationHistoryPageModel with _$ReputationHistoryPageModel {
  const factory ReputationHistoryPageModel({
    @Default(<ReputationHistoryEntryModel>[])
    List<ReputationHistoryEntryModel> items,
    @Default(1) int page,
    @Default(10) int limit,
    @Default(0) int total,
  }) = _ReputationHistoryPageModel;

  factory ReputationHistoryPageModel.fromJson(Map<String, dynamic> json) =>
      _$ReputationHistoryPageModelFromJson(json);
}

@freezed
sealed class ReputationProfileModel with _$ReputationProfileModel {
  const ReputationProfileModel._();

  const factory ReputationProfileModel({
    required String userId,
    @JsonKey(fromJson: _toInt) required int trustScore,
    required String trustLevel,
    String? summaryLabel,
    String? level,
    String? icon,
    String? displayLabel,
    String? hostTitle,
    @JsonKey(fromJson: _toInt) required int equbsJoined,
    @JsonKey(fromJson: _toInt) required int equbsCompleted,
    @JsonKey(fromJson: _toInt) @Default(0) int equbsLeftEarly,
    @JsonKey(fromJson: _toInt) required int equbsHosted,
    @JsonKey(fromJson: _toInt) required int hostedEqubsCompleted,
    @JsonKey(fromJson: _toInt) required int onTimePayments,
    @JsonKey(fromJson: _toInt) required int latePayments,
    @JsonKey(fromJson: _toInt) required int missedPayments,
    @JsonKey(fromJson: _toInt) @Default(0) int turnsParticipated,
    @JsonKey(fromJson: _toInt) required int payoutsReceived,
    @JsonKey(fromJson: _toInt) required int payoutsConfirmed,
    @JsonKey(fromJson: _toInt) required int removalsCount,
    @JsonKey(fromJson: _toInt) required int disputesCount,
    @JsonKey(fromJson: _toInt) @Default(0) int cancelledGroupsCount,
    @JsonKey(fromJson: _toInt) @Default(0) int hostDisputesCount,
    required ReputationComponentsModel components,
    double? baseScore,
    double? activityFactor,
    double? adjustedScore,
    double? confidenceFactor,
    DateTime? lastEqubActivityAt,
    double? onTimePaymentRate,
    double? hostedCompletionRate,
    required DateTime updatedAt,
    required ReputationEligibilityModel eligibility,
    @Default(<ReputationBadgeModel>[]) List<ReputationBadgeModel> badges,
  }) = _ReputationProfileModel;

  factory ReputationProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ReputationProfileModelFromJson(json);

  int get totalPayments => onTimePayments + latePayments + missedPayments;

  bool get hasEarnedLevel => (displayLabel ?? '').trim().isNotEmpty;
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
