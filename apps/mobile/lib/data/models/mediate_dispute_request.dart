import 'package:freezed_annotation/freezed_annotation.dart';

part 'mediate_dispute_request.freezed.dart';
part 'mediate_dispute_request.g.dart';

@freezed
sealed class MediateDisputeRequest with _$MediateDisputeRequest {
  const factory MediateDisputeRequest({required String note}) =
      _MediateDisputeRequest;

  factory MediateDisputeRequest.fromJson(Map<String, dynamic> json) =>
      _$MediateDisputeRequestFromJson(json);
}
