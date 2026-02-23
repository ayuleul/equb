import 'package:freezed_annotation/freezed_annotation.dart';

part 'resolve_dispute_request.freezed.dart';
part 'resolve_dispute_request.g.dart';

@freezed
sealed class ResolveDisputeRequest with _$ResolveDisputeRequest {
  const factory ResolveDisputeRequest({
    required String outcome,
    String? note,
  }) = _ResolveDisputeRequest;

  factory ResolveDisputeRequest.fromJson(Map<String, dynamic> json) =>
      _$ResolveDisputeRequestFromJson(json);
}
