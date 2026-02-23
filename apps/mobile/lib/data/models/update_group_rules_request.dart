import 'package:freezed_annotation/freezed_annotation.dart';

import 'group_rules_model.dart';

part 'update_group_rules_request.freezed.dart';
part 'update_group_rules_request.g.dart';

@freezed
sealed class UpdateGroupRulesRequest with _$UpdateGroupRulesRequest {
  const factory UpdateGroupRulesRequest({
    required int contributionAmount,
    @JsonKey(unknownEnumValue: GroupRuleFrequencyModel.unknown)
    required GroupRuleFrequencyModel frequency,
    int? customIntervalDays,
    required int graceDays,
    @JsonKey(unknownEnumValue: GroupRuleFineTypeModel.unknown)
    required GroupRuleFineTypeModel fineType,
    required int fineAmount,
    @JsonKey(unknownEnumValue: GroupRulePayoutModeModel.unknown)
    required GroupRulePayoutModeModel payoutMode,
    @JsonKey(fromJson: _paymentMethodsFromJson, toJson: _paymentMethodsToJson)
    required List<GroupPaymentMethodModel> paymentMethods,
    required bool requiresMemberVerification,
    required bool strictCollection,
  }) = _UpdateGroupRulesRequest;

  factory UpdateGroupRulesRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateGroupRulesRequestFromJson(json);
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
