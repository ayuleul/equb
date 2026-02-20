// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InviteModel _$InviteModelFromJson(Map<String, dynamic> json) => _InviteModel(
  code: json['code'] as String,
  joinUrl: json['joinUrl'] as String?,
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  maxUses: _toNullableInt(json['maxUses']),
  usedCount: _toNullableInt(json['usedCount']),
);

Map<String, dynamic> _$InviteModelToJson(_InviteModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'joinUrl': instance.joinUrl,
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'maxUses': instance.maxUses,
      'usedCount': instance.usedCount,
    };
