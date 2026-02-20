// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_group_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateGroupRequest _$CreateGroupRequestFromJson(Map<String, dynamic> json) =>
    _CreateGroupRequest(
      name: json['name'] as String,
      contributionAmount: (json['contributionAmount'] as num).toInt(),
      frequency: $enumDecode(
        _$GroupFrequencyModelEnumMap,
        json['frequency'],
        unknownValue: GroupFrequencyModel.unknown,
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      currency: json['currency'] as String? ?? 'ETB',
    );

Map<String, dynamic> _$CreateGroupRequestToJson(_CreateGroupRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'contributionAmount': instance.contributionAmount,
      'frequency': _$GroupFrequencyModelEnumMap[instance.frequency]!,
      'startDate': _dateToIsoString(instance.startDate),
      'currency': instance.currency,
    };

const _$GroupFrequencyModelEnumMap = {
  GroupFrequencyModel.weekly: 'WEEKLY',
  GroupFrequencyModel.monthly: 'MONTHLY',
  GroupFrequencyModel.unknown: 'unknown',
};
