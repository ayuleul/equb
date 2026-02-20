import '../api/api_client.dart';
import '../models/confirm_payout_request.dart';
import '../models/create_payout_request.dart';

abstract class PayoutsApi {
  Future<Map<String, dynamic>> createPayout(
    String cycleId,
    CreatePayoutRequest request,
  );

  Future<Map<String, dynamic>> confirmPayout(
    String payoutId,
    ConfirmPayoutRequest request,
  );

  Future<Map<String, dynamic>?> getPayout(String cycleId);

  Future<Map<String, dynamic>> closeCycle(String cycleId);
}

class DioPayoutsApi implements PayoutsApi {
  DioPayoutsApi(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Map<String, dynamic>> createPayout(
    String cycleId,
    CreatePayoutRequest request,
  ) {
    return _apiClient.postMap(
      '/cycles/$cycleId/payout',
      data: request.toJson(),
    );
  }

  @override
  Future<Map<String, dynamic>> confirmPayout(
    String payoutId,
    ConfirmPayoutRequest request,
  ) {
    return _apiClient.patchMap(
      '/payouts/$payoutId/confirm',
      data: request.toJson(),
    );
  }

  @override
  Future<Map<String, dynamic>?> getPayout(String cycleId) async {
    final payload = await _apiClient.getObject('/cycles/$cycleId/payout');
    if (payload == null) {
      return null;
    }

    if (payload is Map<String, dynamic>) {
      return payload;
    }

    if (payload is Map) {
      return Map<String, dynamic>.from(payload);
    }

    return null;
  }

  @override
  Future<Map<String, dynamic>> closeCycle(String cycleId) {
    return _apiClient.postMap(
      '/cycles/$cycleId/close',
      data: <String, dynamic>{},
    );
  }
}
