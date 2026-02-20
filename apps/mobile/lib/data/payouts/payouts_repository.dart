import '../models/confirm_payout_request.dart';
import '../models/create_payout_request.dart';
import '../models/payout_model.dart';
import 'payouts_api.dart';

class PayoutsRepository {
  PayoutsRepository(this._api);

  final PayoutsApi _api;

  final Map<String, PayoutModel?> _cyclePayoutCache = <String, PayoutModel?>{};

  Future<PayoutModel> createPayout(
    String cycleId,
    CreatePayoutRequest request,
  ) async {
    final payload = await _api.createPayout(cycleId, request);
    final payout = PayoutModel.fromJson(payload);
    _cyclePayoutCache[cycleId] = payout;
    return payout;
  }

  Future<PayoutModel> confirmPayout(
    String payoutId,
    ConfirmPayoutRequest request,
  ) async {
    final payload = await _api.confirmPayout(payoutId, request);
    final payout = PayoutModel.fromJson(payload);
    _cyclePayoutCache[payout.cycleId] = payout;
    return payout;
  }

  Future<PayoutModel?> getPayout(
    String cycleId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cyclePayoutCache.containsKey(cycleId)) {
      return _cyclePayoutCache[cycleId];
    }

    final payload = await _api.getPayout(cycleId);
    if (payload == null || payload.isEmpty) {
      _cyclePayoutCache[cycleId] = null;
      return null;
    }

    final payout = PayoutModel.fromJson(payload);
    _cyclePayoutCache[cycleId] = payout;
    return payout;
  }

  Future<bool> closeCycle(String cycleId) async {
    final payload = await _api.closeCycle(cycleId);
    final success = payload['success'] == true;
    if (success) {
      _cyclePayoutCache.remove(cycleId);
    }

    return success;
  }

  void invalidatePayout(String cycleId) {
    _cyclePayoutCache.remove(cycleId);
  }
}
