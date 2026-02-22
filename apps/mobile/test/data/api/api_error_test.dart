import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/api/api_error.dart';

void main() {
  group('ApiError.fromDioException', () {
    test('maps 429 to friendly too-many-requests error', () {
      final request = RequestOptions(path: '/groups/group-1');
      final exception = DioException(
        requestOptions: request,
        response: Response<dynamic>(
          requestOptions: request,
          statusCode: 429,
          data: <String, dynamic>{'message': 'Too Many Requests'},
        ),
        type: DioExceptionType.badResponse,
      );

      final mapped = ApiError.fromDioException(exception);

      expect(mapped.statusCode, 429);
      expect(mapped.type, ApiErrorType.badRequest);
      expect(mapped.message.toLowerCase(), contains('too many requests'));
    });
  });
}
