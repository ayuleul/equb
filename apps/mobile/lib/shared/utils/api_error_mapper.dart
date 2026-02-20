import 'package:dio/dio.dart';

import '../../data/api/api_error.dart';

String mapApiErrorToMessage(Object error) {
  if (error is ApiError) {
    return _mapApiError(error);
  }

  if (error is DioException) {
    final mapped = ApiError.fromDioException(error);
    return _mapApiError(mapped);
  }

  return 'Something went wrong. Please try again.';
}

String _mapApiError(ApiError error) {
  final message = error.message.trim();
  final normalized = message.toLowerCase();

  if (normalized.contains('invalid otp')) {
    return 'Invalid OTP code. Please try again.';
  }

  if (normalized.contains('otp expired') ||
      normalized.contains('expired otp')) {
    return 'OTP expired. Request a new code.';
  }

  if (normalized.contains('otp attempts exceeded')) {
    return 'Too many invalid OTP attempts. Request a new code.';
  }

  if (normalized.contains('otp not found')) {
    return 'No active OTP found. Request a new code.';
  }

  if (normalized.contains('too many')) {
    return 'Too many requests. Please wait and try again.';
  }

  switch (error.type) {
    case ApiErrorType.timeout:
      return 'Request timed out. Please retry.';
    case ApiErrorType.network:
      return 'Network error. Check your connection and try again.';
    case ApiErrorType.badRequest:
      return message.isNotEmpty ? message : 'Invalid request.';
    case ApiErrorType.unauthorized:
      return message.isNotEmpty ? message : 'Unauthorized request.';
    case ApiErrorType.forbidden:
      return 'You do not have access to this action.';
    case ApiErrorType.notFound:
      return 'Requested resource was not found.';
    case ApiErrorType.server:
      return 'Server error. Please try again shortly.';
    case ApiErrorType.sessionExpired:
      return 'Session expired. Please log in again.';
    case ApiErrorType.unknown:
      return message.isNotEmpty
          ? message
          : 'Unexpected error. Please try again.';
  }
}
