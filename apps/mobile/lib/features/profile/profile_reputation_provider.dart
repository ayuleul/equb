import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../data/models/reputation_model.dart';
import '../auth/auth_controller.dart';

final currentUserReputationProvider = FutureProvider<ReputationProfileModel?>((
  ref,
) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return null;
  }

  final repository = ref.watch(profileRepositoryProvider);
  return repository.getReputation(user.id);
});

final currentUserReputationHistoryProvider =
    FutureProvider<ReputationHistoryPageModel?>((ref) async {
      final user = ref.watch(currentUserProvider);
      if (user == null) {
        return null;
      }

      final repository = ref.watch(profileRepositoryProvider);
      return repository.getReputationHistory(user.id, limit: 8);
    });
