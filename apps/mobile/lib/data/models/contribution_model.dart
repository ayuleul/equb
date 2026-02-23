import 'package:freezed_annotation/freezed_annotation.dart';

import 'group_rules_model.dart';

part 'contribution_model.freezed.dart';
part 'contribution_model.g.dart';

enum ContributionStatusModel {
  @JsonValue('PENDING')
  pending,
  @JsonValue('LATE')
  late,
  @JsonValue('PAID_SUBMITTED')
  paidSubmitted,
  @JsonValue('VERIFIED')
  verified,
  @JsonValue('SUBMITTED')
  submitted,
  @JsonValue('CONFIRMED')
  confirmed,
  @JsonValue('REJECTED')
  rejected,
  unknown,
}

@freezed
sealed class ContributionUserModel with _$ContributionUserModel {
  const factory ContributionUserModel({
    required String id,
    String? fullName,
    String? phone,
  }) = _ContributionUserModel;

  factory ContributionUserModel.fromJson(Map<String, dynamic> json) =>
      _$ContributionUserModelFromJson(json);
}

@freezed
sealed class ContributionModel with _$ContributionModel {
  const ContributionModel._();

  const factory ContributionModel({
    required String id,
    required String groupId,
    required String cycleId,
    required String userId,
    @JsonKey(fromJson: _toInt) required int amount,
    @JsonKey(unknownEnumValue: ContributionStatusModel.unknown)
    required ContributionStatusModel status,
    @JsonKey(unknownEnumValue: GroupPaymentMethodModel.unknown)
    GroupPaymentMethodModel? paymentMethod,
    String? proofFileKey,
    String? paymentRef,
    String? note,
    DateTime? submittedAt,
    DateTime? confirmedAt,
    DateTime? rejectedAt,
    String? rejectReason,
    DateTime? lateMarkedAt,
    DateTime? createdAt,
    required ContributionUserModel user,
  }) = _ContributionModel;

  factory ContributionModel.fromJson(Map<String, dynamic> json) =>
      _$ContributionModelFromJson(json);

  String get displayName {
    final fullName = user.fullName?.trim();
    if (fullName != null && fullName.isNotEmpty) {
      return fullName;
    }

    final phone = user.phone?.trim();
    if (phone != null && phone.isNotEmpty) {
      return phone;
    }

    return 'Member';
  }
}

@freezed
sealed class ContributionSummaryModel with _$ContributionSummaryModel {
  const factory ContributionSummaryModel({
    @JsonKey(fromJson: _toInt) @Default(0) int total,
    @JsonKey(fromJson: _toInt) @Default(0) int pending,
    @JsonKey(fromJson: _toInt) @Default(0) int submitted,
    @JsonKey(fromJson: _toInt) @Default(0) int confirmed,
    @JsonKey(fromJson: _toInt) @Default(0) int rejected,
    @JsonKey(fromJson: _toInt) @Default(0) int paidSubmitted,
    @JsonKey(fromJson: _toInt) @Default(0) int verified,
    @JsonKey(fromJson: _toInt) @Default(0) int late,
  }) = _ContributionSummaryModel;

  factory ContributionSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$ContributionSummaryModelFromJson(json);
}

@freezed
sealed class ContributionListModel with _$ContributionListModel {
  const factory ContributionListModel({
    @Default(<ContributionModel>[]) List<ContributionModel> items,
    required ContributionSummaryModel summary,
  }) = _ContributionListModel;

  factory ContributionListModel.fromJson(Map<String, dynamic> json) =>
      _$ContributionListModelFromJson(json);
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
