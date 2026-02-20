import '../api/api_client.dart';
import '../models/signed_upload_request.dart';

abstract class FilesApi {
  Future<Map<String, dynamic>> createSignedUpload(SignedUploadRequest request);
  Future<Map<String, dynamic>> createSignedDownload(String key);
}

class DioFilesApi implements FilesApi {
  DioFilesApi(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Map<String, dynamic>> createSignedUpload(SignedUploadRequest request) {
    return _apiClient.postMap('/files/signed-upload', data: request.toJson());
  }

  @override
  Future<Map<String, dynamic>> createSignedDownload(String key) {
    return _apiClient.getMap(
      '/files/signed-download',
      queryParameters: <String, dynamic>{'key': key},
    );
  }
}
