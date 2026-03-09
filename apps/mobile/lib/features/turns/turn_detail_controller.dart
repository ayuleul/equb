import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../contributions/cycle_contributions_provider.dart';
import '../cycles/cycle_bids_provider.dart';
import '../cycles/cycle_detail_provider.dart';
import '../payouts/cycle_payout_provider.dart';
import 'turn_disputes_provider.dart';

final turnDetailControllerProvider = Provider<TurnDetailController>((ref) {
  return TurnDetailController(ref);
});

class TurnDetailController {
  TurnDetailController(this._ref);

  final Ref _ref;

  Future<void> refreshTurnState(String groupId, String turnId) async {
    final args = (groupId: groupId, cycleId: turnId);

    _ref.read(cyclesRepositoryProvider).invalidateCycleDetail(groupId, turnId);
    _ref.read(payoutsRepositoryProvider).invalidatePayout(turnId);

    _ref.invalidate(cycleDetailProvider(args));
    _ref.invalidate(cycleContributionsProvider(args));
    _ref.invalidate(cyclePayoutProvider(turnId));

    await Future.wait([
      _ref.read(cycleDetailProvider(args).future),
      _ref.read(cycleContributionsProvider(args).future),
      _ref.read(cyclePayoutProvider(turnId).future),
    ]);
  }

  Future<void> refreshDisputes(String groupId, String turnId) async {
    _ref.invalidate(turnDisputesProvider((groupId: groupId, cycleId: turnId)));
    await _ref.read(
      turnDisputesProvider((groupId: groupId, cycleId: turnId)).future,
    );
  }

  Future<void> refreshBids(String turnId) async {
    _ref.invalidate(cycleBidsProvider(turnId));
    await _ref.read(cycleBidsProvider(turnId).future);
  }

  Future<void> refreshTurn(String groupId, String turnId) async {
    await Future.wait([
      refreshTurnState(groupId, turnId),
      refreshDisputes(groupId, turnId),
      refreshBids(turnId),
    ]);
  }
}
