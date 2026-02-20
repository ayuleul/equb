import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/files/files_api.dart';
import 'package:mobile/data/files/files_repository.dart';

void main() {
  test(
    'uploadToSignedUrl uses unauthenticated client and exact content-type',
    () async {
      final uploadDio = Dio();

      String? authorizationHeader;
      String? contentTypeHeader;

      uploadDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            authorizationHeader = options.headers['Authorization'] as String?;
            contentTypeHeader =
                options.headers[Headers.contentTypeHeader] as String?;

            handler.resolve(
              Response<void>(requestOptions: options, statusCode: 200),
            );
          },
        ),
      );

      final repository = FilesRepository(_FakeFilesApi(), uploadDio: uploadDio);

      await repository.uploadToSignedUrl(
        'https://upload.test/path/object.jpg',
        Uint8List.fromList(<int>[1, 2, 3, 4]),
        'image/jpeg',
      );

      expect(authorizationHeader, isNull);
      expect(contentTypeHeader, 'image/jpeg');
    },
  );
}

class _FakeFilesApi implements FilesApi {
  @override
  Future<Map<String, dynamic>> createSignedDownload(String key) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> createSignedUpload(request) {
    throw UnimplementedError();
  }
}
