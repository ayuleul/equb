import '../api/api_client.dart';

abstract class ProfileApi {
  Future<Map<String, dynamic>> getMe();
  Future<Map<String, dynamic>> getReputation(String userId);
  Future<Map<String, dynamic>> getReputationHistory(
    String userId, {
    int page = 1,
    int limit = 10,
  });
  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String middleName,
    String? lastName,
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
  Future<Map<String, dynamic>> getReputation(String userId) {
    return _apiClient.getMap('/users/$userId/reputation');
  }

  @override
  Future<Map<String, dynamic>> getReputationHistory(
    String userId, {
    int page = 1,
    int limit = 10,
  }) {
    return _apiClient.getMap(
      '/users/$userId/reputation/history',
      queryParameters: <String, dynamic>{'page': page, 'limit': limit},
    );
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String middleName,
    String? lastName,
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
