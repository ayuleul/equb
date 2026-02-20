import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../data/contributions/contributions_repository.dart';
import '../../shared/utils/api_error_mapper.dart';
import '../cycles/cycle_detail_provider.dart';
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
    this.activeContributionId,
    this.errorMessage,
  });

  const AdminContributionActionsState.initial() : this(isLoading: false);

  final bool isLoading;
  final String? activeContributionId;
  final String? errorMessage;

  AdminContributionActionsState copyWith({
    bool? isLoading,
    String? activeContributionId,
    bool clearActiveContributionId = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdminContributionActionsState(
      isLoading: isLoading ?? this.isLoading,
      activeContributionId: clearActiveContributionId
          ? null
          : (activeContributionId ?? this.activeContributionId),
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

  Future<bool> confirm(String contributionId, {String? note}) async {
    state = state.copyWith(
      isLoading: true,
      activeContributionId: contributionId,
      clearError: true,
    );

    try {
      await repository.confirmContribution(contributionId, note: note);
      _ref.invalidate(cycleContributionsProvider(args));
      _ref.invalidate(
        cycleDetailProvider((groupId: args.groupId, cycleId: args.cycleId)),
      );

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

  Future<bool> reject(String contributionId, String reason) async {
    state = state.copyWith(
      isLoading: true,
      activeContributionId: contributionId,
      clearError: true,
    );

    try {
      await repository.rejectContribution(contributionId, reason);
      _ref.invalidate(cycleContributionsProvider(args));
      _ref.invalidate(
        cycleDetailProvider((groupId: args.groupId, cycleId: args.cycleId)),
      );

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
}
