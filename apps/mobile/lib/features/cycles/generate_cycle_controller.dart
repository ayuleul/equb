import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../data/cycles/cycles_repository.dart';
import '../../data/models/cycle_model.dart';
import '../../shared/utils/api_error_mapper.dart';
import '../groups/group_detail_controller.dart';
import 'current_cycle_provider.dart';
import 'cycles_list_provider.dart';

class GenerateCycleState {
  const GenerateCycleState({required this.isSubmitting, this.errorMessage});

  const GenerateCycleState.initial() : this(isSubmitting: false);

  final bool isSubmitting;
  final String? errorMessage;

  bool get isRoundCompleted {
    final message = errorMessage?.toLowerCase() ?? '';
    return message.contains('round completed');
  }

  GenerateCycleState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GenerateCycleState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final generateCycleControllerProvider =
    StateNotifierProvider.family<
      GenerateCycleController,
      GenerateCycleState,
      String
    >((ref, groupId) {
      final repository = ref.watch(cyclesRepositoryProvider);
      return GenerateCycleController(
        ref: ref,
        groupId: groupId,
        repository: repository,
      );
    });

class GenerateCycleController extends StateNotifier<GenerateCycleState> {
  GenerateCycleController({
    required Ref ref,
    required this.groupId,
    required CyclesRepository repository,
  }) : _ref = ref,
       _repository = repository,
       super(const GenerateCycleState.initial());

  final Ref _ref;
  final String groupId;
  final CyclesRepository _repository;

  Future<CycleModel?> generateNextCycle() async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final generated = await _repository.generateNextCycle(groupId);

      _repository.invalidateGroupCache(groupId);
      _ref.invalidate(currentCycleProvider(groupId));
      _ref.invalidate(cyclesListProvider(groupId));
      _ref.invalidate(groupDetailProvider(groupId));

      state = state.copyWith(isSubmitting: false, clearError: true);
      return generated;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: mapApiErrorToMessage(error),
      );
      return null;
    }
  }
}
