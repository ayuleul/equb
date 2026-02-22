import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../data/cycles/cycles_repository.dart';
import '../../data/models/cycle_model.dart';
import '../../shared/utils/api_error_mapper.dart';
import 'current_cycle_provider.dart';
import 'cycles_list_provider.dart';

class GenerateCycleState {
  const GenerateCycleState({
    required this.count,
    required this.isSubmitting,
    this.errorMessage,
  });

  const GenerateCycleState.initial() : this(count: 1, isSubmitting: false);

  final int count;
  final bool isSubmitting;
  final String? errorMessage;

  GenerateCycleState copyWith({
    int? count,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GenerateCycleState(
      count: count ?? this.count,
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

  void setCount(int value) {
    final clamped = value.clamp(1, 12);
    state = state.copyWith(count: clamped, clearError: true);
  }

  Future<List<CycleModel>?> generate() async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      List<CycleModel> generated;
      try {
        generated = await _repository.generateCycles(
          groupId,
          count: state.count,
        );
      } catch (error) {
        if (!_requiresActiveRound(error)) {
          rethrow;
        }

        try {
          await _repository.startRound(groupId);
        } catch (roundError) {
          if (!_activeRoundAlreadyExists(roundError)) {
            rethrow;
          }
        }

        generated = await _repository.generateCycles(
          groupId,
          count: state.count,
        );
      }

      _repository.invalidateGroupCache(groupId);
      _ref.invalidate(currentCycleProvider(groupId));
      _ref.invalidate(cyclesListProvider(groupId));

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

  bool _requiresActiveRound(Object error) {
    final message = mapApiErrorToMessage(error).toLowerCase();
    return message.contains('active round is required');
  }

  bool _activeRoundAlreadyExists(Object error) {
    final message = mapApiErrorToMessage(error).toLowerCase();
    return message.contains('active round already exists');
  }
}
