import 'package:freezed_annotation/freezed_annotation.dart';

part 'confirm_payout_request.freezed.dart';
part 'confirm_payout_request.g.dart';

@freezed
sealed class ConfirmPayoutRequest with _$ConfirmPayoutRequest {
  const factory ConfirmPayoutRequest({
    @JsonKey(includeIfNull: false) String? proofFileKey,
    @JsonKey(includeIfNull: false) String? paymentRef,
    @JsonKey(includeIfNull: false) String? note,
  }) = _ConfirmPayoutRequest;

  factory ConfirmPayoutRequest.fromJson(Map<String, dynamic> json) =>
      _$ConfirmPayoutRequestFromJson(json);
}
