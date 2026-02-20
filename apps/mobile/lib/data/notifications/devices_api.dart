import '../api/api_client.dart';
import '../models/register_device_token_request.dart';

abstract class DevicesApi {
  Future<Map<String, dynamic>> registerToken(
    RegisterDeviceTokenRequest request,
  );
}

class DioDevicesApi implements DevicesApi {
  DioDevicesApi(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Map<String, dynamic>> registerToken(
    RegisterDeviceTokenRequest request,
  ) {
    return _apiClient.postMap(
      '/devices/register-token',
      data: request.toJson(),
    );
  }
}
