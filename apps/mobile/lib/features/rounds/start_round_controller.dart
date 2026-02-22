import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../data/cycles/cycles_repository.dart';
import '../../shared/utils/api_error_mapper.dart';
import '../cycles/current_cycle_provider.dart';
import '../cycles/cycles_list_provider.dart';
import '../groups/group_detail_controller.dart';
import 'current_round_schedule_provider.dart';
import 'round_draw_reveal_state.dart';

class StartRoundState {
  const StartRoundState({required this.isSubmitting, this.errorMessage});

  const StartRoundState.initial() : this(isSubmitting: false);

  final bool isSubmitting;
  final String? errorMessage;

  StartRoundState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StartRoundState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final startRoundControllerProvider =
    StateNotifierProvider.family<StartRoundController, StartRoundState, String>(
      (ref, groupId) {
        final repository = ref.watch(cyclesRepositoryProvider);
        return StartRoundController(
          ref: ref,
          groupId: groupId,
          repository: repository,
        );
      },
    );

class StartRoundController extends StateNotifier<StartRoundState> {
  StartRoundController({
    required Ref ref,
    required this.groupId,
    required CyclesRepository repository,
  }) : _ref = ref,
       _repository = repository,
       super(const StartRoundState.initial());

  final Ref _ref;
  final String groupId;
  final CyclesRepository _repository;

  Future<bool> startRound() async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      await _repository.startRound(groupId);

      _ref.invalidate(groupDetailProvider(groupId));
      _ref.invalidate(currentCycleProvider(groupId));
      _ref.invalidate(cyclesListProvider(groupId));
      _ref.invalidate(currentRoundScheduleProvider(groupId));
      _ref.read(roundJustStartedProvider(groupId).notifier).state = true;

      state = state.copyWith(isSubmitting: false, clearError: true);
      return true;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: mapApiErrorToMessage(error),
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
