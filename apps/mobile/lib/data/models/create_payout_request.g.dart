// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_payout_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreatePayoutRequest _$CreatePayoutRequestFromJson(Map<String, dynamic> json) =>
    _CreatePayoutRequest(
      amount: (json['amount'] as num?)?.toInt(),
      proofFileKey: json['proofFileKey'] as String?,
      paymentRef: json['paymentRef'] as String?,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$CreatePayoutRequestToJson(
  _CreatePayoutRequest instance,
) => <String, dynamic>{
  'amount': ?instance.amount,
  'proofFileKey': ?instance.proofFileKey,
  'paymentRef': ?instance.paymentRef,
  'note': ?instance.note,
};
