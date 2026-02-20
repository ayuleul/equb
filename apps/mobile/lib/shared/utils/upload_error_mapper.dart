import 'package:dio/dio.dart';

import '../../data/api/api_error.dart';
import 'api_error_mapper.dart';

String mapUploadErrorToMessage(Object error) {
  if (error is ApiError) {
    return mapApiErrorToMessage(error);
  }

  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Upload failed due to network issues. Please retry.';
      case DioExceptionType.badResponse:
        return 'Upload URL expired or invalid. Please pick the file again.';
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        return 'Upload failed. Please try again.';
    }
  }

  return 'Upload failed. Please try again.';
}
