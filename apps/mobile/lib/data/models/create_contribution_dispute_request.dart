import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_contribution_dispute_request.freezed.dart';
part 'create_contribution_dispute_request.g.dart';

@freezed
sealed class CreateContributionDisputeRequest
    with _$CreateContributionDisputeRequest {
  const factory CreateContributionDisputeRequest({
    required String reason,
    String? note,
  }) = _CreateContributionDisputeRequest;

  factory CreateContributionDisputeRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$CreateContributionDisputeRequestFromJson(json);
}
