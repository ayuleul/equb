import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../data/cycles/cycles_repository.dart';
import '../../data/models/cycle_model.dart';
import '../../shared/utils/api_error_mapper.dart';
import '../groups/group_detail_controller.dart';
import 'current_cycle_provider.dart';
import 'cycles_list_provider.dart';

class StartCycleState {
  const StartCycleState({required this.isSubmitting, this.errorMessage});

  const StartCycleState.initial() : this(isSubmitting: false);

  final bool isSubmitting;
  final String? errorMessage;

  StartCycleState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StartCycleState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final startCycleControllerProvider =
    StateNotifierProvider.family<StartCycleController, StartCycleState, String>(
      (ref, groupId) {
        final repository = ref.watch(cyclesRepositoryProvider);
        return StartCycleController(
          ref: ref,
          groupId: groupId,
          repository: repository,
        );
      },
    );

class StartCycleController extends StateNotifier<StartCycleState> {
  StartCycleController({
    required Ref ref,
    required this.groupId,
    required CyclesRepository repository,
  }) : _ref = ref,
       _repository = repository,
       super(const StartCycleState.initial());

  final Ref _ref;
  final String groupId;
  final CyclesRepository _repository;

  Future<CycleModel?> startCycle() async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final createdCycle = await _repository.startCycle(groupId);

      _repository.invalidateGroupCache(groupId);
      _ref.invalidate(currentCycleProvider(groupId));
      _ref.invalidate(cyclesListProvider(groupId));
      _ref.invalidate(groupDetailProvider(groupId));

      state = state.copyWith(isSubmitting: false, clearError: true);
      return createdCycle;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: mapApiErrorToMessage(error),
      );
      return null;
    }
  }
}
