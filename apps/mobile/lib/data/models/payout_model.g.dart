// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payout_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PayoutUserModel _$PayoutUserModelFromJson(Map<String, dynamic> json) =>
    _PayoutUserModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$PayoutUserModelToJson(_PayoutUserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'phone': instance.phone,
    };

_PayoutModel _$PayoutModelFromJson(Map<String, dynamic> json) => _PayoutModel(
  id: json['id'] as String,
  groupId: json['groupId'] as String,
  cycleId: json['cycleId'] as String,
  toUserId: json['toUserId'] as String,
  amount: _toInt(json['amount']),
  status: $enumDecode(
    _$PayoutStatusModelEnumMap,
    json['status'],
    unknownValue: PayoutStatusModel.unknown,
  ),
  proofFileKey: json['proofFileKey'] as String?,
  paymentRef: json['paymentRef'] as String?,
  note: json['note'] as String?,
  createdByUserId: json['createdByUserId'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  confirmedByUserId: json['confirmedByUserId'] as String?,
  confirmedAt: json['confirmedAt'] == null
      ? null
      : DateTime.parse(json['confirmedAt'] as String),
  toUser: PayoutUserModel.fromJson(json['toUser'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PayoutModelToJson(_PayoutModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'cycleId': instance.cycleId,
      'toUserId': instance.toUserId,
      'amount': instance.amount,
      'status': _$PayoutStatusModelEnumMap[instance.status]!,
      'proofFileKey': instance.proofFileKey,
      'paymentRef': instance.paymentRef,
      'note': instance.note,
      'createdByUserId': instance.createdByUserId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'confirmedByUserId': instance.confirmedByUserId,
      'confirmedAt': instance.confirmedAt?.toIso8601String(),
      'toUser': instance.toUser,
    };

const _$PayoutStatusModelEnumMap = {
  PayoutStatusModel.pending: 'PENDING',
  PayoutStatusModel.confirmed: 'CONFIRMED',
  PayoutStatusModel.unknown: 'unknown',
};
