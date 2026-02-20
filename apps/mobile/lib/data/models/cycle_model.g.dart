// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cycle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CyclePayoutUserModel _$CyclePayoutUserModelFromJson(
  Map<String, dynamic> json,
) => _CyclePayoutUserModel(
  id: json['id'] as String,
  phone: json['phone'] as String?,
  fullName: json['fullName'] as String?,
);

Map<String, dynamic> _$CyclePayoutUserModelToJson(
  _CyclePayoutUserModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'phone': instance.phone,
  'fullName': instance.fullName,
};

_CycleModel _$CycleModelFromJson(Map<String, dynamic> json) => _CycleModel(
  id: json['id'] as String,
  groupId: json['groupId'] as String,
  cycleNo: _toInt(json['cycleNo']),
  dueDate: DateTime.parse(json['dueDate'] as String),
  payoutUserId: json['payoutUserId'] as String,
  status: $enumDecode(
    _$CycleStatusModelEnumMap,
    json['status'],
    unknownValue: CycleStatusModel.unknown,
  ),
  createdByUserId: json['createdByUserId'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  payoutUser: json['payoutUser'] == null
      ? null
      : CyclePayoutUserModel.fromJson(
          json['payoutUser'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$CycleModelToJson(_CycleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'cycleNo': instance.cycleNo,
      'dueDate': instance.dueDate.toIso8601String(),
      'payoutUserId': instance.payoutUserId,
      'status': _$CycleStatusModelEnumMap[instance.status]!,
      'createdByUserId': instance.createdByUserId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'payoutUser': instance.payoutUser,
    };

const _$CycleStatusModelEnumMap = {
  CycleStatusModel.open: 'OPEN',
  CycleStatusModel.closed: 'CLOSED',
  CycleStatusModel.unknown: 'unknown',
};
