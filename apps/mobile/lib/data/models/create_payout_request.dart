import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_payout_request.freezed.dart';
part 'create_payout_request.g.dart';

@freezed
sealed class CreatePayoutRequest with _$CreatePayoutRequest {
  const factory CreatePayoutRequest({
    @JsonKey(includeIfNull: false) int? amount,
    @JsonKey(includeIfNull: false) String? proofFileKey,
    @JsonKey(includeIfNull: false) String? paymentRef,
    @JsonKey(includeIfNull: false) String? note,
  }) = _CreatePayoutRequest;

  factory CreatePayoutRequest.fromJson(Map<String, dynamic> json) =>
      _$CreatePayoutRequestFromJson(json);
}
