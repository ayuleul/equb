import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../data/models/cycle_bid_model.dart';

final cycleBidsProvider = FutureProvider.family<List<CycleBidModel>, String>((
  ref,
  cycleId,
) async {
  final repository = ref.watch(auctionRepositoryProvider);
  return repository.listBids(cycleId);
});
