import '../../../core/network/api_client.dart';
import 'health_response.dart';

class HealthRepository {
  const HealthRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<HealthResponse> getHealth() async {
    final payload = await _apiClient.getMap('/health');
    return HealthResponse.fromJson(payload);
  }
}
