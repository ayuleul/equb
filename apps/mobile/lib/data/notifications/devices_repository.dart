import '../models/register_device_token_request.dart';
import 'devices_api.dart';

class DevicesRepository {
  DevicesRepository(this._api);

  final DevicesApi _api;

  Future<void> registerToken({
    required String token,
    required DevicePlatformModel platform,
  }) async {
    final request = RegisterDeviceTokenRequest(
      token: token,
      platform: platform,
    );
    await _api.registerToken(request);
  }
}
