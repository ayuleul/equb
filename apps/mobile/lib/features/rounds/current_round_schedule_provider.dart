import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../data/models/current_round_schedule_model.dart';

final currentRoundScheduleProvider =
    FutureProvider.family<CurrentRoundScheduleModel?, String>((
      ref,
      groupId,
    ) async {
      final repository = ref.watch(cyclesRepositoryProvider);
      return repository.getCurrentRoundSchedule(groupId);
    });
