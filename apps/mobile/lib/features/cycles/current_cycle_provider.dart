import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../data/models/cycle_model.dart';

final currentCycleProvider = FutureProvider.family<CycleModel?, String>((
  ref,
  groupId,
) async {
  final repository = ref.watch(cyclesRepositoryProvider);
  return repository.getCurrentCycle(groupId);
});
