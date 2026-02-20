// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroupMembershipModel _$GroupMembershipModelFromJson(
  Map<String, dynamic> json,
) => _GroupMembershipModel(
  role: $enumDecode(
    _$MemberRoleModelEnumMap,
    json['role'],
    unknownValue: MemberRoleModel.unknown,
  ),
  status: $enumDecode(
    _$MemberStatusModelEnumMap,
    json['status'],
    unknownValue: MemberStatusModel.unknown,
  ),
);

Map<String, dynamic> _$GroupMembershipModelToJson(
  _GroupMembershipModel instance,
) => <String, dynamic>{
  'role': _$MemberRoleModelEnumMap[instance.role]!,
  'status': _$MemberStatusModelEnumMap[instance.status]!,
};

const _$MemberRoleModelEnumMap = {
  MemberRoleModel.admin: 'ADMIN',
  MemberRoleModel.member: 'MEMBER',
  MemberRoleModel.unknown: 'unknown',
};

const _$MemberStatusModelEnumMap = {
  MemberStatusModel.invited: 'INVITED',
  MemberStatusModel.active: 'ACTIVE',
  MemberStatusModel.left: 'LEFT',
  MemberStatusModel.removed: 'REMOVED',
  MemberStatusModel.unknown: 'unknown',
};

_GroupModel _$GroupModelFromJson(Map<String, dynamic> json) => _GroupModel(
  id: json['id'] as String,
  name: json['name'] as String,
  currency: json['currency'] as String,
  contributionAmount: _toInt(json['contributionAmount']),
  frequency: $enumDecode(
    _$GroupFrequencyModelEnumMap,
    json['frequency'],
    unknownValue: GroupFrequencyModel.unknown,
  ),
  startDate: DateTime.parse(json['startDate'] as String),
  status: $enumDecode(
    _$GroupStatusModelEnumMap,
    json['status'],
    unknownValue: GroupStatusModel.unknown,
  ),
  createdByUserId: json['createdByUserId'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  strictPayout: json['strictPayout'] as bool?,
  timezone: json['timezone'] as String?,
  membership: json['membership'] == null
      ? null
      : GroupMembershipModel.fromJson(
          json['membership'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$GroupModelToJson(_GroupModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'currency': instance.currency,
      'contributionAmount': instance.contributionAmount,
      'frequency': _$GroupFrequencyModelEnumMap[instance.frequency]!,
      'startDate': instance.startDate.toIso8601String(),
      'status': _$GroupStatusModelEnumMap[instance.status]!,
      'createdByUserId': instance.createdByUserId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'strictPayout': instance.strictPayout,
      'timezone': instance.timezone,
      'membership': instance.membership,
    };

const _$GroupFrequencyModelEnumMap = {
  GroupFrequencyModel.weekly: 'WEEKLY',
  GroupFrequencyModel.monthly: 'MONTHLY',
  GroupFrequencyModel.unknown: 'unknown',
};

const _$GroupStatusModelEnumMap = {
  GroupStatusModel.active: 'ACTIVE',
  GroupStatusModel.archived: 'ARCHIVED',
  GroupStatusModel.unknown: 'unknown',
};
