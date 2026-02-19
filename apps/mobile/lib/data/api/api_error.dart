import 'package:dio/dio.dart';

enum ApiErrorType {
  timeout,
  network,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  server,
  sessionExpired,
  unknown,
}

class ApiError implements Exception {
  const ApiError({required this.type, required this.message, this.statusCode});

  final ApiErrorType type;
  final String message;
  final int? statusCode;

  factory ApiError.fromDioException(DioException exception) {
    final statusCode = exception.response?.statusCode;
    final payload = exception.response?.data;

    String? payloadMessage;
    if (payload is Map<String, dynamic>) {
      final message = payload['message'];
      if (message is String) {
        payloadMessage = message;
      }
    }

    if (exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.sendTimeout ||
        exception.type == DioExceptionType.receiveTimeout) {
      return const ApiError(
        type: ApiErrorType.timeout,
        message: 'Request timed out. Please retry.',
      );
    }

    if (exception.type == DioExceptionType.connectionError) {
      return const ApiError(
        type: ApiErrorType.network,
        message: 'Network error. Please check your connection.',
      );
    }

    switch (statusCode) {
      case 400:
        return ApiError(
          type: ApiErrorType.badRequest,
          message: payloadMessage ?? 'Bad request.',
          statusCode: statusCode,
        );
      case 401:
        return ApiError(
          type: ApiErrorType.unauthorized,
          message: payloadMessage ?? 'Unauthorized.',
          statusCode: statusCode,
        );
      case 403:
        return ApiError(
          type: ApiErrorType.forbidden,
          message: payloadMessage ?? 'Forbidden.',
          statusCode: statusCode,
        );
      case 404:
        return ApiError(
          type: ApiErrorType.notFound,
          message: payloadMessage ?? 'Not found.',
          statusCode: statusCode,
        );
      default:
        if (statusCode != null && statusCode >= 500) {
          return ApiError(
            type: ApiErrorType.server,
            message: payloadMessage ?? 'Server error. Please try again later.',
            statusCode: statusCode,
          );
        }

        return ApiError(
          type: ApiErrorType.unknown,
          message:
              payloadMessage ?? exception.message ?? 'Unexpected API error.',
          statusCode: statusCode,
        );
    }
  }

  @override
  String toString() =>
      'ApiError(type: $type, statusCode: $statusCode, message: $message)';
}
