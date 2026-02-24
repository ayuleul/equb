import '../models/confirm_payout_request.dart';
import '../models/create_payout_request.dart';
import '../models/payout_model.dart';
import 'payouts_api.dart';

class PayoutsRepository {
  PayoutsRepository(this._api);

  final PayoutsApi _api;

  final Map<String, PayoutModel?> _cyclePayoutCache = <String, PayoutModel?>{};

  Future<void> selectWinner(String cycleId, {String? userId}) async {
    await _api.selectWinner(cycleId, userId: userId);
    _cyclePayoutCache.remove(cycleId);
  }

  Future<PayoutModel> disbursePayout(
    String cycleId, {
    String? proofFileKey,
    String? paymentRef,
    String? note,
  }) async {
    final payload = await _api.disbursePayout(
      cycleId,
      proofFileKey: proofFileKey,
      paymentRef: paymentRef,
      note: note,
    );
    final payout = PayoutModel.fromJson(payload);
    _cyclePayoutCache[cycleId] = payout;
    return payout;
  }

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

  Future<Map<String, dynamic>> closeCycle(
    String cycleId, {
    bool autoNext = false,
  }) async {
    final payload = await _api.closeCycle(cycleId, autoNext: autoNext);
    final success = payload['success'] == true;
    if (success) {
      _cyclePayoutCache.remove(cycleId);
    }

    return payload;
  }

  void invalidatePayout(String cycleId) {
    _cyclePayoutCache.remove(cycleId);
  }
}
