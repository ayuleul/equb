// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HealthResponse _$HealthResponseFromJson(Map<String, dynamic> json) =>
    _HealthResponse(
      status: json['status'] as String,
      checks: HealthChecks.fromJson(json['checks'] as Map<String, dynamic>),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$HealthResponseToJson(_HealthResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'checks': instance.checks,
      'timestamp': instance.timestamp.toIso8601String(),
    };

_HealthChecks _$HealthChecksFromJson(Map<String, dynamic> json) =>
    _HealthChecks(
      database: json['database'] as String,
      redis: json['redis'] as String,
    );

Map<String, dynamic> _$HealthChecksToJson(_HealthChecks instance) =>
    <String, dynamic>{'database': instance.database, 'redis': instance.redis};
