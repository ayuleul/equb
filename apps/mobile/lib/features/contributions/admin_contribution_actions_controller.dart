import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../data/contributions/contributions_repository.dart';
import '../../data/models/cycle_collection_evaluation_model.dart';
import '../../data/realtime/socket_sync_policy.dart';
import '../../shared/utils/api_error_mapper.dart';
import '../cycles/cycle_detail_provider.dart';
import '../groups/group_detail_controller.dart';
import 'cycle_contributions_provider.dart';

final adminContributionActionsControllerProvider =
    StateNotifierProvider.family<
      AdminContributionActionsController,
      AdminContributionActionsState,
      CycleContributionsArgs
    >((ref, args) {
      final repository = ref.watch(contributionsRepositoryProvider);
      return AdminContributionActionsController(
        ref: ref,
        args: args,
        repository: repository,
      );
    });

class AdminContributionActionsState {
  const AdminContributionActionsState({
    required this.isLoading,
    required this.isEvaluating,
    this.activeContributionId,
    this.lastEvaluation,
    this.errorMessage,
  });

  const AdminContributionActionsState.initial()
    : this(isLoading: false, isEvaluating: false);

  final bool isLoading;
  final bool isEvaluating;
  final String? activeContributionId;
  final CycleCollectionEvaluationModel? lastEvaluation;
  final String? errorMessage;

  AdminContributionActionsState copyWith({
    bool? isLoading,
    bool? isEvaluating,
    String? activeContributionId,
    bool clearActiveContributionId = false,
    CycleCollectionEvaluationModel? lastEvaluation,
    bool clearLastEvaluation = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdminContributionActionsState(
      isLoading: isLoading ?? this.isLoading,
      isEvaluating: isEvaluating ?? this.isEvaluating,
      activeContributionId: clearActiveContributionId
          ? null
          : (activeContributionId ?? this.activeContributionId),
      lastEvaluation: clearLastEvaluation
          ? null
          : (lastEvaluation ?? this.lastEvaluation),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AdminContributionActionsController
    extends StateNotifier<AdminContributionActionsState> {
  AdminContributionActionsController({
    required Ref ref,
    required this.args,
    required this.repository,
  }) : _ref = ref,
       super(const AdminContributionActionsState.initial());

  final Ref _ref;
  final CycleContributionsArgs args;
  final ContributionsRepository repository;

  Future<bool> confirm(
    String contributionId, {
    String? note,
    bool preferSocketSync = false,
  }) async {
    state = state.copyWith(
      isLoading: true,
      activeContributionId: contributionId,
      clearError: true,
    );

    try {
      await repository.confirmContribution(contributionId, note: note);
      if (preferSocketSync) {
        unawaited(
          _ref
              .read(socketSyncPolicyProvider)
              .waitForSocketOrFallback(
                eventTypes: const {'contribution.updated'},
                groupId: args.groupId,
                turnId: args.cycleId,
                entityId: contributionId,
                fallback: _fallbackRefresh,
              ),
        );
      } else {
        await _fallbackRefresh();
      }

      state = state.copyWith(
        isLoading: false,
        clearActiveContributionId: true,
        clearError: true,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        clearActiveContributionId: true,
        errorMessage: mapApiErrorToMessage(error),
      );
      return false;
    }
  }

  Future<bool> reject(
    String contributionId,
    String reason, {
    bool preferSocketSync = false,
  }) async {
    state = state.copyWith(
      isLoading: true,
      activeContributionId: contributionId,
      clearError: true,
    );

    try {
      await repository.rejectContribution(contributionId, reason);
      if (preferSocketSync) {
        unawaited(
          _ref
              .read(socketSyncPolicyProvider)
              .waitForSocketOrFallback(
                eventTypes: const {'contribution.updated'},
                groupId: args.groupId,
                turnId: args.cycleId,
                entityId: contributionId,
                fallback: _fallbackRefresh,
              ),
        );
      } else {
        await _fallbackRefresh();
      }

      state = state.copyWith(
        isLoading: false,
        clearActiveContributionId: true,
        clearError: true,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        clearActiveContributionId: true,
        errorMessage: mapApiErrorToMessage(error),
      );
      return false;
    }
  }

  Future<CycleCollectionEvaluationModel?> evaluateCycleCollection({
    bool preferSocketSync = false,
  }) async {
    state = state.copyWith(
      isEvaluating: true,
      clearError: true,
      clearLastEvaluation: true,
    );

    try {
      final evaluation = await repository.evaluateCycleCollection(args.cycleId);
      if (preferSocketSync) {
        unawaited(
          _ref
              .read(socketSyncPolicyProvider)
              .waitForSocketOrFallback(
                eventTypes: const {'contribution.updated', 'turn.updated'},
                groupId: args.groupId,
                turnId: args.cycleId,
                fallback: _fallbackRefresh,
              ),
        );
      } else {
        await _fallbackRefresh();
      }

      state = state.copyWith(
        isEvaluating: false,
        lastEvaluation: evaluation,
        clearError: true,
      );
      return evaluation;
    } catch (error) {
      state = state.copyWith(
        isEvaluating: false,
        errorMessage: mapApiErrorToMessage(error),
      );
      return null;
    }
  }

  Future<void> _fallbackRefresh() async {
    _ref.invalidate(cycleContributionsProvider(args));
    _ref.invalidate(
      cycleDetailProvider((groupId: args.groupId, cycleId: args.cycleId)),
    );
    await Future.wait([
      _ref.read(cycleContributionsProvider(args).future),
      _ref.read(
        cycleDetailProvider((
          groupId: args.groupId,
          cycleId: args.cycleId,
        )).future,
      ),
      _ref
          .read(groupDetailControllerProvider)
          .refreshCurrentTurnState(args.groupId, cycleId: args.cycleId),
    ]);
  }
}
