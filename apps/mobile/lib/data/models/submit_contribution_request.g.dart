// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submit_contribution_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubmitContributionRequest _$SubmitContributionRequestFromJson(
  Map<String, dynamic> json,
) => _SubmitContributionRequest(
  amount: (json['amount'] as num?)?.toInt(),
  proofFileKey: json['proofFileKey'] as String?,
  paymentRef: json['paymentRef'] as String?,
  note: json['note'] as String?,
);

Map<String, dynamic> _$SubmitContributionRequestToJson(
  _SubmitContributionRequest instance,
) => <String, dynamic>{
  'amount': ?instance.amount,
  'proofFileKey': ?instance.proofFileKey,
  'paymentRef': ?instance.paymentRef,
  'note': ?instance.note,
};
