import 'package:freezed_annotation/freezed_annotation.dart';

part 'reject_contribution_request.freezed.dart';
part 'reject_contribution_request.g.dart';

@freezed
sealed class RejectContributionRequest with _$RejectContributionRequest {
  const factory RejectContributionRequest({required String reason}) =
      _RejectContributionRequest;

  factory RejectContributionRequest.fromJson(Map<String, dynamic> json) =>
      _$RejectContributionRequestFromJson(json);
}
