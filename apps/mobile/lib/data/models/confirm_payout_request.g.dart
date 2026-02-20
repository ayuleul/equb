// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confirm_payout_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConfirmPayoutRequest _$ConfirmPayoutRequestFromJson(
  Map<String, dynamic> json,
) => _ConfirmPayoutRequest(
  proofFileKey: json['proofFileKey'] as String?,
  paymentRef: json['paymentRef'] as String?,
  note: json['note'] as String?,
);

Map<String, dynamic> _$ConfirmPayoutRequestToJson(
  _ConfirmPayoutRequest instance,
) => <String, dynamic>{
  'proofFileKey': ?instance.proofFileKey,
  'paymentRef': ?instance.paymentRef,
  'note': ?instance.note,
};
