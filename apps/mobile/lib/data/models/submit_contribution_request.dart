import 'package:freezed_annotation/freezed_annotation.dart';

import 'group_rules_model.dart';

part 'submit_contribution_request.freezed.dart';
part 'submit_contribution_request.g.dart';

@freezed
sealed class SubmitContributionRequest with _$SubmitContributionRequest {
  const factory SubmitContributionRequest({
    required GroupPaymentMethodModel method,
    @JsonKey(includeIfNull: false) int? amount,
    @JsonKey(includeIfNull: false) String? receiptFileKey,
    @JsonKey(includeIfNull: false) String? reference,
    // legacy compatibility aliases retained by backend
    @JsonKey(includeIfNull: false) String? proofFileKey,
    @JsonKey(includeIfNull: false) String? paymentRef,
    @JsonKey(includeIfNull: false) String? note,
  }) = _SubmitContributionRequest;

  factory SubmitContributionRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitContributionRequestFromJson(json);
}
