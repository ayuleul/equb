import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../data/models/contribution_dispute_model.dart';

final contributionDisputesProvider =
    FutureProvider.family<List<ContributionDisputeModel>, String>((
      ref,
      contributionId,
    ) async {
      final repository = ref.watch(contributionsRepositoryProvider);
      return repository.listContributionDisputes(contributionId);
    });
