// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payout_order_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PayoutOrderItem _$PayoutOrderItemFromJson(Map<String, dynamic> json) =>
    _PayoutOrderItem(
      userId: json['userId'] as String,
      payoutPosition: _toInt(json['payoutPosition']),
    );

Map<String, dynamic> _$PayoutOrderItemToJson(_PayoutOrderItem instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'payoutPosition': instance.payoutPosition,
    };
