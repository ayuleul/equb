// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_group_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateGroupRequest _$CreateGroupRequestFromJson(Map<String, dynamic> json) =>
    _CreateGroupRequest(
      name: json['name'] as String,
      description: json['description'] as String?,
      contributionAmount: (json['contributionAmount'] as num?)?.toInt(),
      frequency: $enumDecodeNullable(
        _$GroupFrequencyModelEnumMap,
        json['frequency'],
        unknownValue: GroupFrequencyModel.unknown,
      ),
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      currency: json['currency'] as String? ?? 'ETB',
      visibility:
          $enumDecodeNullable(
            _$GroupVisibilityModelEnumMap,
            json['visibility'],
            unknownValue: GroupVisibilityModel.private,
          ) ??
          GroupVisibilityModel.private,
    );

Map<String, dynamic> _$CreateGroupRequestToJson(_CreateGroupRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'contributionAmount': instance.contributionAmount,
      'frequency': _$GroupFrequencyModelEnumMap[instance.frequency],
      'startDate': _nullableDateToIsoString(instance.startDate),
      'currency': instance.currency,
      'visibility': _$GroupVisibilityModelEnumMap[instance.visibility]!,
    };

const _$GroupFrequencyModelEnumMap = {
  GroupFrequencyModel.weekly: 'WEEKLY',
  GroupFrequencyModel.monthly: 'MONTHLY',
  GroupFrequencyModel.unknown: 'unknown',
};

const _$GroupVisibilityModelEnumMap = {
  GroupVisibilityModel.private: 'PRIVATE',
  GroupVisibilityModel.public: 'PUBLIC',
  GroupVisibilityModel.unknown: 'unknown',
};
