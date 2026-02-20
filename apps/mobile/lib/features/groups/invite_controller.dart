import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../data/groups/groups_repository.dart';
import '../../data/models/invite_model.dart';
import '../../shared/utils/api_error_mapper.dart';

class InviteState {
  const InviteState({required this.isLoading, this.invite, this.errorMessage});

  const InviteState.initial() : this(isLoading: false);

  final bool isLoading;
  final InviteModel? invite;
  final String? errorMessage;

  InviteState copyWith({
    bool? isLoading,
    InviteModel? invite,
    String? errorMessage,
    bool clearError = false,
  }) {
    return InviteState(
      isLoading: isLoading ?? this.isLoading,
      invite: invite ?? this.invite,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final inviteProvider =
    StateNotifierProvider.family<InviteController, InviteState, String>((
      ref,
      groupId,
    ) {
      final repository = ref.watch(groupsRepositoryProvider);
      return InviteController(groupId: groupId, repository: repository);
    });

class InviteController extends StateNotifier<InviteState> {
  InviteController({required this.groupId, required this.repository})
    : super(const InviteState.initial());

  final String groupId;
  final GroupsRepository repository;

  Future<void> createInvite() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final invite = await repository.createInvite(groupId);
      state = state.copyWith(
        isLoading: false,
        invite: invite,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: mapApiErrorToMessage(error),
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
