import '../api/api_client.dart';

abstract class ProfileApi {
  Future<Map<String, dynamic>> getMe();
  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String middleName,
    required String lastName,
  });
}

class DioProfileApi implements ProfileApi {
  DioProfileApi(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Map<String, dynamic>> getMe() {
    return _apiClient.getMap('/me');
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String middleName,
    required String lastName,
  }) {
    return _apiClient.patchMap(
      '/me/profile',
      data: <String, dynamic>{
        'firstName': firstName,
        'middleName': middleName,
        'lastName': lastName,
      },
    );
  }
}
