import 'package:dio/dio.dart';

import '../models/health_status.dart';
import 'api_error.dart';

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<HealthStatus> getHealth() async {
    final payload = await getMap('/health');
    return HealthStatus.fromJson(payload);
  }

  Future<Map<String, dynamic>> getMap(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );

      return response.data ?? <String, dynamic>{};
    } on DioException catch (error) {
      throw _toApiError(error);
    }
  }

  Future<Map<String, dynamic>> postMap(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return response.data ?? <String, dynamic>{};
    } on DioException catch (error) {
      throw _toApiError(error);
    }
  }

  ApiError _toApiError(DioException error) {
    final inner = error.error;
    if (inner is ApiError) {
      return inner;
    }

    return ApiError.fromDioException(error);
  }
}
