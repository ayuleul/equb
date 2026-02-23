// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resolve_dispute_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ResolveDisputeRequest _$ResolveDisputeRequestFromJson(
  Map<String, dynamic> json,
) => _ResolveDisputeRequest(
  outcome: json['outcome'] as String,
  note: json['note'] as String?,
);

Map<String, dynamic> _$ResolveDisputeRequestToJson(
  _ResolveDisputeRequest instance,
) => <String, dynamic>{'outcome': instance.outcome, 'note': instance.note};
