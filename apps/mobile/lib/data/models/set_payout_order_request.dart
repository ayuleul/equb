import 'package:freezed_annotation/freezed_annotation.dart';

import 'payout_order_item.dart';

part 'set_payout_order_request.freezed.dart';
part 'set_payout_order_request.g.dart';

@freezed
sealed class SetPayoutOrderRequest with _$SetPayoutOrderRequest {
  const SetPayoutOrderRequest._();

  const factory SetPayoutOrderRequest({required List<PayoutOrderItem> items}) =
      _SetPayoutOrderRequest;

  factory SetPayoutOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$SetPayoutOrderRequestFromJson(json);

  List<Map<String, dynamic>> toRequestBody() {
    return items.map((item) => item.toJson()).toList(growable: false);
  }
}
