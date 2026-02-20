import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../data/models/payout_model.dart';

final cyclePayoutProvider = FutureProvider.family<PayoutModel?, String>((
  ref,
  cycleId,
) async {
  final repository = ref.watch(payoutsRepositoryProvider);
  return repository.getPayout(cycleId);
});
