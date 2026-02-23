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
  roundId: json['roundId'] as String?,
  cycleNo: _toInt(json['cycleNo']),
  dueDate: DateTime.parse(json['dueDate'] as String),
  dueAt: json['dueAt'] == null ? null : DateTime.parse(json['dueAt'] as String),
  state: $enumDecodeNullable(
    _$CycleStateModelEnumMap,
    json['state'],
    unknownValue: CycleStateModel.unknown,
  ),
  scheduledPayoutUserId: json['scheduledPayoutUserId'] as String?,
  finalPayoutUserId: json['finalPayoutUserId'] as String?,
  payoutUserId: json['payoutUserId'] as String,
  auctionStatus: $enumDecodeNullable(
    _$AuctionStatusModelEnumMap,
    json['auctionStatus'],
    unknownValue: AuctionStatusModel.unknown,
  ),
  winningBidAmount: _toNullableInt(json['winningBidAmount']),
  winningBidUserId: json['winningBidUserId'] as String?,
  status: $enumDecode(
    _$CycleStatusModelEnumMap,
    json['status'],
    unknownValue: CycleStatusModel.unknown,
  ),
  createdByUserId: json['createdByUserId'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  scheduledPayoutUser: json['scheduledPayoutUser'] == null
      ? null
      : CyclePayoutUserModel.fromJson(
          json['scheduledPayoutUser'] as Map<String, dynamic>,
        ),
  finalPayoutUser: json['finalPayoutUser'] == null
      ? null
      : CyclePayoutUserModel.fromJson(
          json['finalPayoutUser'] as Map<String, dynamic>,
        ),
  winningBidUser: json['winningBidUser'] == null
      ? null
      : CyclePayoutUserModel.fromJson(
          json['winningBidUser'] as Map<String, dynamic>,
        ),
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
      'roundId': instance.roundId,
      'cycleNo': instance.cycleNo,
      'dueDate': instance.dueDate.toIso8601String(),
      'dueAt': instance.dueAt?.toIso8601String(),
      'state': _$CycleStateModelEnumMap[instance.state],
      'scheduledPayoutUserId': instance.scheduledPayoutUserId,
      'finalPayoutUserId': instance.finalPayoutUserId,
      'payoutUserId': instance.payoutUserId,
      'auctionStatus': _$AuctionStatusModelEnumMap[instance.auctionStatus],
      'winningBidAmount': instance.winningBidAmount,
      'winningBidUserId': instance.winningBidUserId,
      'status': _$CycleStatusModelEnumMap[instance.status]!,
      'createdByUserId': instance.createdByUserId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'scheduledPayoutUser': instance.scheduledPayoutUser,
      'finalPayoutUser': instance.finalPayoutUser,
      'winningBidUser': instance.winningBidUser,
      'payoutUser': instance.payoutUser,
    };

const _$CycleStateModelEnumMap = {
  CycleStateModel.due: 'DUE',
  CycleStateModel.collecting: 'COLLECTING',
  CycleStateModel.readyForPayout: 'READY_FOR_PAYOUT',
  CycleStateModel.disbursed: 'DISBURSED',
  CycleStateModel.closed: 'CLOSED',
  CycleStateModel.unknown: 'unknown',
};

const _$AuctionStatusModelEnumMap = {
  AuctionStatusModel.none: 'NONE',
  AuctionStatusModel.open: 'OPEN',
  AuctionStatusModel.closed: 'CLOSED',
  AuctionStatusModel.unknown: 'unknown',
};

const _$CycleStatusModelEnumMap = {
  CycleStatusModel.open: 'OPEN',
  CycleStatusModel.closed: 'CLOSED',
  CycleStatusModel.unknown: 'unknown',
};
