import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../data/models/cycle_model.dart';

typedef CycleDetailArgs = ({String groupId, String cycleId});

final cycleDetailProvider = FutureProvider.family<CycleModel, CycleDetailArgs>((
  ref,
  args,
) async {
  final repository = ref.watch(cyclesRepositoryProvider);
  return repository.getCycle(args.groupId, args.cycleId);
});
