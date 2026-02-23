// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MemberUserModel _$MemberUserModelFromJson(Map<String, dynamic> json) =>
    _MemberUserModel(
      id: json['id'] as String,
      phone: json['phone'] as String?,
      fullName: json['fullName'] as String?,
    );

Map<String, dynamic> _$MemberUserModelToJson(_MemberUserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'phone': instance.phone,
      'fullName': instance.fullName,
    };

_MemberModel _$MemberModelFromJson(Map<String, dynamic> json) => _MemberModel(
  id: _readMemberId(json, 'id') as String,
  userId: _readUserId(json, 'userId') as String,
  groupId: json['groupId'] as String?,
  user: MemberUserModel.fromJson(json['user'] as Map<String, dynamic>),
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
  payoutPosition: _toNullableInt(json['payoutPosition']),
  joinedAt: json['joinedAt'] == null
      ? null
      : DateTime.parse(json['joinedAt'] as String),
  verifiedAt: json['verifiedAt'] == null
      ? null
      : DateTime.parse(json['verifiedAt'] as String),
  verifiedByUserId: json['verifiedByUserId'] as String?,
);

Map<String, dynamic> _$MemberModelToJson(_MemberModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'groupId': instance.groupId,
      'user': instance.user,
      'role': _$MemberRoleModelEnumMap[instance.role]!,
      'status': _$MemberStatusModelEnumMap[instance.status]!,
      'payoutPosition': instance.payoutPosition,
      'joinedAt': instance.joinedAt?.toIso8601String(),
      'verifiedAt': instance.verifiedAt?.toIso8601String(),
      'verifiedByUserId': instance.verifiedByUserId,
    };

const _$MemberRoleModelEnumMap = {
  MemberRoleModel.admin: 'ADMIN',
  MemberRoleModel.member: 'MEMBER',
  MemberRoleModel.unknown: 'unknown',
};

const _$MemberStatusModelEnumMap = {
  MemberStatusModel.invited: 'INVITED',
  MemberStatusModel.joined: 'JOINED',
  MemberStatusModel.verified: 'VERIFIED',
  MemberStatusModel.suspended: 'SUSPENDED',
  MemberStatusModel.active: 'ACTIVE',
  MemberStatusModel.left: 'LEFT',
  MemberStatusModel.removed: 'REMOVED',
  MemberStatusModel.unknown: 'unknown',
};
