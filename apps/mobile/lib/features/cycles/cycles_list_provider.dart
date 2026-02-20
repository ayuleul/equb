import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../data/models/cycle_model.dart';

final cyclesListProvider = FutureProvider.family<List<CycleModel>, String>((
  ref,
  groupId,
) async {
  final repository = ref.watch(cyclesRepositoryProvider);
  return repository.listCycles(groupId);
});
