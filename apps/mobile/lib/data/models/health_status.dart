import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_status.freezed.dart';
part 'health_status.g.dart';

@freezed
sealed class HealthStatus with _$HealthStatus {
  const factory HealthStatus({
    required String status,
    required HealthChecks checks,
    required DateTime timestamp,
  }) = _HealthStatus;

  factory HealthStatus.fromJson(Map<String, dynamic> json) =>
      _$HealthStatusFromJson(json);
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
