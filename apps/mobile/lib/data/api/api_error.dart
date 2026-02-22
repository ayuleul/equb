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
  const ApiError({
    required this.type,
    required this.message,
    this.statusCode,
    this.reasonCode,
  });

  final ApiErrorType type;
  final String message;
  final int? statusCode;
  final String? reasonCode;

  factory ApiError.fromDioException(DioException exception) {
    final statusCode = exception.response?.statusCode;
    final payload = exception.response?.data;

    String? payloadMessage;
    String? payloadReasonCode;
    if (payload is Map<String, dynamic>) {
      final message = payload['message'];
      if (message is String) {
        payloadMessage = message;
      } else if (message is List) {
        for (final item in message) {
          if (item is String && item.isNotEmpty) {
            payloadMessage = item;
            break;
          }
        }
      }

      final reasonCode = payload['reasonCode'];
      if (reasonCode is String && reasonCode.trim().isNotEmpty) {
        payloadReasonCode = reasonCode.trim();
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
          reasonCode: payloadReasonCode,
        );
      case 401:
        return ApiError(
          type: ApiErrorType.unauthorized,
          message: payloadMessage ?? 'Unauthorized.',
          statusCode: statusCode,
          reasonCode: payloadReasonCode,
        );
      case 403:
        return ApiError(
          type: ApiErrorType.forbidden,
          message: payloadMessage ?? 'Forbidden.',
          statusCode: statusCode,
          reasonCode: payloadReasonCode,
        );
      case 404:
        return ApiError(
          type: ApiErrorType.notFound,
          message: payloadMessage ?? 'Not found.',
          statusCode: statusCode,
          reasonCode: payloadReasonCode,
        );
      case 409:
        return ApiError(
          type: ApiErrorType.badRequest,
          message: payloadMessage ?? 'Conflict.',
          statusCode: statusCode,
          reasonCode: payloadReasonCode,
        );
      case 429:
        return ApiError(
          type: ApiErrorType.badRequest,
          message:
              payloadMessage ?? 'Too many requests. Please wait and try again.',
          statusCode: statusCode,
          reasonCode: payloadReasonCode,
        );
      default:
        if (statusCode != null && statusCode >= 500) {
          return ApiError(
            type: ApiErrorType.server,
            message: payloadMessage ?? 'Server error. Please try again later.',
            statusCode: statusCode,
            reasonCode: payloadReasonCode,
          );
        }

        return ApiError(
          type: ApiErrorType.unknown,
          message:
              payloadMessage ?? exception.message ?? 'Unexpected API error.',
          statusCode: statusCode,
          reasonCode: payloadReasonCode,
        );
    }
  }

  @override
  String toString() =>
      'ApiError(type: $type, statusCode: $statusCode, reasonCode: $reasonCode, message: $message)';
}
