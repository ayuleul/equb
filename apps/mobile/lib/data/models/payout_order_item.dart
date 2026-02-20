import 'package:freezed_annotation/freezed_annotation.dart';

part 'payout_order_item.freezed.dart';
part 'payout_order_item.g.dart';

@freezed
sealed class PayoutOrderItem with _$PayoutOrderItem {
  const factory PayoutOrderItem({
    required String userId,
    @JsonKey(fromJson: _toInt) required int payoutPosition,
  }) = _PayoutOrderItem;

  factory PayoutOrderItem.fromJson(Map<String, dynamic> json) =>
      _$PayoutOrderItemFromJson(json);
}

int _toInt(Object? value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return 0;
}
