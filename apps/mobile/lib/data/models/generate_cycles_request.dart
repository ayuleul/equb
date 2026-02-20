import 'package:freezed_annotation/freezed_annotation.dart';

part 'generate_cycles_request.freezed.dart';
part 'generate_cycles_request.g.dart';

@freezed
sealed class GenerateCyclesRequest with _$GenerateCyclesRequest {
  const factory GenerateCyclesRequest({
    @JsonKey(includeIfNull: false) int? count,
  }) = _GenerateCyclesRequest;

  factory GenerateCyclesRequest.fromJson(Map<String, dynamic> json) =>
      _$GenerateCyclesRequestFromJson(json);
}
