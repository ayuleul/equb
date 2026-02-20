import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../data/models/contribution_model.dart';

typedef CycleContributionsArgs = ({String groupId, String cycleId});

final cycleContributionsProvider =
    FutureProvider.family<ContributionListModel, CycleContributionsArgs>((
      ref,
      args,
    ) async {
      final repository = ref.watch(contributionsRepositoryProvider);
      return repository.listCycleContributions(args.groupId, args.cycleId);
    });
