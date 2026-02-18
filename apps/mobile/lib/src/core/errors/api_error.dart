import 'package:dio/dio.dart';

enum ApiErrorType {
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  server,
  network,
  configuration,
  unknown,
}

class ApiError implements Exception {
  const ApiError({required this.type, required this.message, this.statusCode});

  final ApiErrorType type;
  final String message;
  final int? statusCode;

  factory ApiError.fromDioException(DioException exception) {
    final statusCode = exception.response?.statusCode;
    final responseData = exception.response?.data;

    final responseMessage =
        responseData is Map<String, dynamic> &&
            responseData['message'] is String
        ? responseData['message'] as String
        : null;

    switch (statusCode) {
      case 400:
        return ApiError(
          type: ApiErrorType.badRequest,
          message: responseMessage ?? 'Bad request.',
          statusCode: statusCode,
        );
      case 401:
        return ApiError(
          type: ApiErrorType.unauthorized,
          message: responseMessage ?? 'Unauthorized.',
          statusCode: statusCode,
        );
      case 403:
        return ApiError(
          type: ApiErrorType.forbidden,
          message: responseMessage ?? 'Forbidden.',
          statusCode: statusCode,
        );
      case 404:
        return ApiError(
          type: ApiErrorType.notFound,
          message: responseMessage ?? 'Resource not found.',
          statusCode: statusCode,
        );
      default:
        if (statusCode != null && statusCode >= 500) {
          return ApiError(
            type: ApiErrorType.server,
            message: responseMessage ?? 'Server error. Please try again.',
            statusCode: statusCode,
          );
        }

        if (exception.type == DioExceptionType.connectionError ||
            exception.type == DioExceptionType.connectionTimeout ||
            exception.type == DioExceptionType.receiveTimeout ||
            exception.type == DioExceptionType.sendTimeout) {
          return const ApiError(
            type: ApiErrorType.network,
            message: 'Network error. Please check your connection.',
          );
        }

        return ApiError(
          type: ApiErrorType.unknown,
          message: responseMessage ?? exception.message ?? 'Unexpected error.',
          statusCode: statusCode,
        );
    }
  }

  @override
  String toString() =>
      'ApiError(type: $type, statusCode: $statusCode, message: $message)';
}
