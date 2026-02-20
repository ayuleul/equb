// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_payout_order_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SetPayoutOrderRequest _$SetPayoutOrderRequestFromJson(
  Map<String, dynamic> json,
) => _SetPayoutOrderRequest(
  items: (json['items'] as List<dynamic>)
      .map((e) => PayoutOrderItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SetPayoutOrderRequestToJson(
  _SetPayoutOrderRequest instance,
) => <String, dynamic>{'items': instance.items};
