import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_response.freezed.dart';
part 'health_response.g.dart';

@freezed
sealed class HealthResponse with _$HealthResponse {
  const factory HealthResponse({
    required String status,
    required HealthChecks checks,
    required DateTime timestamp,
  }) = _HealthResponse;

  factory HealthResponse.fromJson(Map<String, dynamic> json) =>
      _$HealthResponseFromJson(json);
}

@freezed
sealed class HealthChecks with _$HealthChecks {
  const factory HealthChecks({
    required String database,
    required String redis,
  }) = _HealthChecks;

  factory HealthChecks.fromJson(Map<String, dynamic> json) =>
      _$HealthChecksFromJson(json);
}
