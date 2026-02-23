// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submit_contribution_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubmitContributionRequest _$SubmitContributionRequestFromJson(
  Map<String, dynamic> json,
) => _SubmitContributionRequest(
  method: $enumDecode(_$GroupPaymentMethodModelEnumMap, json['method']),
  amount: (json['amount'] as num?)?.toInt(),
  receiptFileKey: json['receiptFileKey'] as String?,
  reference: json['reference'] as String?,
  proofFileKey: json['proofFileKey'] as String?,
  paymentRef: json['paymentRef'] as String?,
  note: json['note'] as String?,
);

Map<String, dynamic> _$SubmitContributionRequestToJson(
  _SubmitContributionRequest instance,
) => <String, dynamic>{
  'method': _$GroupPaymentMethodModelEnumMap[instance.method]!,
  'amount': ?instance.amount,
  'receiptFileKey': ?instance.receiptFileKey,
  'reference': ?instance.reference,
  'proofFileKey': ?instance.proofFileKey,
  'paymentRef': ?instance.paymentRef,
  'note': ?instance.note,
};

const _$GroupPaymentMethodModelEnumMap = {
  GroupPaymentMethodModel.bank: 'BANK',
  GroupPaymentMethodModel.telebirr: 'TELEBIRR',
  GroupPaymentMethodModel.cashAck: 'CASH_ACK',
  GroupPaymentMethodModel.unknown: 'unknown',
};
