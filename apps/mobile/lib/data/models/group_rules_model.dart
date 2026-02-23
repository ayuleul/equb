import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_rules_model.freezed.dart';
part 'group_rules_model.g.dart';

enum GroupRuleFrequencyModel {
  @JsonValue('WEEKLY')
  weekly,
  @JsonValue('MONTHLY')
  monthly,
  @JsonValue('CUSTOM_INTERVAL')
  customInterval,
  unknown,
}

enum GroupRuleFineTypeModel {
  @JsonValue('NONE')
  none,
  @JsonValue('FIXED_AMOUNT')
  fixedAmount,
  unknown,
}

enum GroupRulePayoutModeModel {
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

enum GroupPaymentMethodModel {
  @JsonValue('BANK')
  bank,
  @JsonValue('TELEBIRR')
  telebirr,
  @JsonValue('CASH_ACK')
  cashAck,
  unknown,
}

@freezed
sealed class GroupRulesModel with _$GroupRulesModel {
  const factory GroupRulesModel({
    required String groupId,
    @JsonKey(fromJson: _toInt) required int contributionAmount,
    @JsonKey(unknownEnumValue: GroupRuleFrequencyModel.unknown)
    required GroupRuleFrequencyModel frequency,
    @JsonKey(fromJson: _toNullableInt) int? customIntervalDays,
    @JsonKey(fromJson: _toInt) required int graceDays,
    @JsonKey(unknownEnumValue: GroupRuleFineTypeModel.unknown)
    required GroupRuleFineTypeModel fineType,
    @JsonKey(fromJson: _toInt) required int fineAmount,
    @JsonKey(unknownEnumValue: GroupRulePayoutModeModel.unknown)
    required GroupRulePayoutModeModel payoutMode,
    @JsonKey(fromJson: _paymentMethodsFromJson, toJson: _paymentMethodsToJson)
    required List<GroupPaymentMethodModel> paymentMethods,
    required bool requiresMemberVerification,
    required bool strictCollection,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _GroupRulesModel;

  factory GroupRulesModel.fromJson(Map<String, dynamic> json) =>
      _$GroupRulesModelFromJson(json);
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

List<GroupPaymentMethodModel> _paymentMethodsFromJson(Object? value) {
  if (value is! List) {
    return const <GroupPaymentMethodModel>[];
  }

  return value
      .map(
        (item) => switch (item) {
          'BANK' => GroupPaymentMethodModel.bank,
          'TELEBIRR' => GroupPaymentMethodModel.telebirr,
          'CASH_ACK' => GroupPaymentMethodModel.cashAck,
          _ => GroupPaymentMethodModel.unknown,
        },
      )
      .toList(growable: false);
}

List<String> _paymentMethodsToJson(List<GroupPaymentMethodModel> methods) {
  return methods
      .where((method) => method != GroupPaymentMethodModel.unknown)
      .map(
        (method) => switch (method) {
          GroupPaymentMethodModel.bank => 'BANK',
          GroupPaymentMethodModel.telebirr => 'TELEBIRR',
          GroupPaymentMethodModel.cashAck => 'CASH_ACK',
          GroupPaymentMethodModel.unknown => 'UNKNOWN',
        },
      )
      .toList(growable: false);
}
