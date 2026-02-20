import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../models/signed_upload_request.dart';
import '../models/signed_upload_response.dart';
import 'files_api.dart';

class FilesRepository {
  FilesRepository(
    this._filesApi, {
    Dio? uploadDio,
    Duration timeout = const Duration(seconds: 20),
  }) : _uploadDio =
           uploadDio ??
           Dio(
             BaseOptions(
               connectTimeout: timeout,
               receiveTimeout: timeout,
               sendTimeout: timeout,
             ),
           );

  final FilesApi _filesApi;
  final Dio _uploadDio;

  Future<SignedUploadResponse> requestSignedUpload({
    required UploadPurposeModel purpose,
    required String groupId,
    required String cycleId,
    required String fileName,
    required String contentType,
  }) async {
    final payload = await _filesApi.createSignedUpload(
      SignedUploadRequest(
        purpose: purpose,
        groupId: groupId,
        cycleId: cycleId,
        fileName: fileName,
        contentType: contentType,
      ),
    );

    return SignedUploadResponse.fromJson(payload);
  }

  Future<void> uploadToSignedUrl(
    String uploadUrl,
    Uint8List bytes,
    String contentType, {
    void Function(double progress)? onProgress,
  }) async {
    const maxAttempts = 2;
    var attempt = 0;

    while (attempt < maxAttempts) {
      attempt += 1;
      try {
        await _uploadDio.put<void>(
          uploadUrl,
          data: bytes,
          options: Options(
            headers: <String, dynamic>{Headers.contentTypeHeader: contentType},
            validateStatus: (status) {
              return status != null && status >= 200 && status < 300;
            },
          ),
          onSendProgress: (sent, total) {
            if (onProgress == null) {
              return;
            }

            if (total <= 0) {
              onProgress(0);
              return;
            }

            onProgress(sent / total);
          },
        );

        return;
      } on DioException catch (error) {
        final shouldRetry = _isRetryableNetworkError(error);
        final hasMoreAttempts = attempt < maxAttempts;
        if (!shouldRetry || !hasMoreAttempts) {
          rethrow;
        }
      }
    }
  }

  Future<String> getSignedDownloadUrl(String key) async {
    final payload = await _filesApi.createSignedDownload(key);
    final response = SignedDownloadResponse.fromJson(payload);
    return response.downloadUrl;
  }

  bool _isRetryableNetworkError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return true;
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        return false;
    }
  }
}
