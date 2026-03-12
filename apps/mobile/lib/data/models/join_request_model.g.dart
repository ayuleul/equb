// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'join_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_JoinRequestUserModel _$JoinRequestUserModelFromJson(
  Map<String, dynamic> json,
) => _JoinRequestUserModel(
  id: json['id'] as String,
  phone: json['phone'] as String?,
  fullName: json['fullName'] as String?,
);

Map<String, dynamic> _$JoinRequestUserModelToJson(
  _JoinRequestUserModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'phone': instance.phone,
  'fullName': instance.fullName,
};

_JoinRequestModel _$JoinRequestModelFromJson(Map<String, dynamic> json) =>
    _JoinRequestModel(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      userId: json['userId'] as String,
      status: $enumDecode(
        _$JoinRequestStatusModelEnumMap,
        json['status'],
        unknownValue: JoinRequestStatusModel.unknown,
      ),
      message: json['message'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      reviewedAt: json['reviewedAt'] == null
          ? null
          : DateTime.parse(json['reviewedAt'] as String),
      reviewedByUserId: json['reviewedByUserId'] as String?,
      retryAvailableAt: json['retryAvailableAt'] == null
          ? null
          : DateTime.parse(json['retryAvailableAt'] as String),
      user: json['user'] == null
          ? null
          : JoinRequestUserModel.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$JoinRequestModelToJson(_JoinRequestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'userId': instance.userId,
      'status': _$JoinRequestStatusModelEnumMap[instance.status]!,
      'message': instance.message,
      'createdAt': instance.createdAt.toIso8601String(),
      'reviewedAt': instance.reviewedAt?.toIso8601String(),
      'reviewedByUserId': instance.reviewedByUserId,
      'retryAvailableAt': instance.retryAvailableAt?.toIso8601String(),
      'user': instance.user,
    };

const _$JoinRequestStatusModelEnumMap = {
  JoinRequestStatusModel.requested: 'REQUESTED',
  JoinRequestStatusModel.approved: 'APPROVED',
  JoinRequestStatusModel.rejected: 'REJECTED',
  JoinRequestStatusModel.withdrawn: 'WITHDRAWN',
  JoinRequestStatusModel.unknown: 'unknown',
};
