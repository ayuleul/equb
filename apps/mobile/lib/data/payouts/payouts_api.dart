import '../api/api_client.dart';
import '../models/confirm_payout_request.dart';
import '../models/create_payout_request.dart';

abstract class PayoutsApi {
  Future<Map<String, dynamic>> selectWinner(String cycleId, {String? userId});

  Future<Map<String, dynamic>> disbursePayout(
    String cycleId, {
    String? proofFileKey,
    String? paymentRef,
    String? note,
  });

  Future<Map<String, dynamic>> createPayout(
    String cycleId,
    CreatePayoutRequest request,
  );

  Future<Map<String, dynamic>> confirmPayout(
    String payoutId,
    ConfirmPayoutRequest request,
  );

  Future<Map<String, dynamic>?> getPayout(String cycleId);

  Future<Map<String, dynamic>> closeCycle(String cycleId, {bool autoNext});
}

class DioPayoutsApi implements PayoutsApi {
  DioPayoutsApi(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Map<String, dynamic>> selectWinner(String cycleId, {String? userId}) {
    final data = <String, dynamic>{};
    if (userId != null) {
      data['userId'] = userId;
    }
    return _apiClient.postMap('/cycles/$cycleId/winner/select', data: data);
  }

  @override
  Future<Map<String, dynamic>> disbursePayout(
    String cycleId, {
    String? proofFileKey,
    String? paymentRef,
    String? note,
  }) {
    final data = <String, dynamic>{};
    if (proofFileKey != null) {
      data['proofFileKey'] = proofFileKey;
    }
    if (paymentRef != null) {
      data['paymentRef'] = paymentRef;
    }
    if (note != null) {
      data['note'] = note;
    }
    return _apiClient.postMap('/cycles/$cycleId/payout/disburse', data: data);
  }

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
  Future<Map<String, dynamic>> closeCycle(
    String cycleId, {
    bool autoNext = false,
  }) {
    return _apiClient.postMap(
      '/cycles/$cycleId/close',
      data: <String, dynamic>{'autoNext': autoNext},
    );
  }
}
