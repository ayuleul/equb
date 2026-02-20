import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../data/groups/groups_repository.dart';
import '../../data/models/group_model.dart';
import '../../shared/utils/api_error_mapper.dart';

class GroupsListState {
  const GroupsListState({
    required this.items,
    required this.isLoading,
    required this.isRefreshing,
    this.errorMessage,
  });

  const GroupsListState.initial()
    : this(items: const <GroupModel>[], isLoading: false, isRefreshing: false);

  final List<GroupModel> items;
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;

  bool get hasData => items.isNotEmpty;

  GroupsListState copyWith({
    List<GroupModel>? items,
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GroupsListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final groupsListProvider =
    StateNotifierProvider<GroupsListController, GroupsListState>((ref) {
      final repository = ref.watch(groupsRepositoryProvider);
      return GroupsListController(repository: repository);
    });

class GroupsListController extends StateNotifier<GroupsListState> {
  GroupsListController({required this.repository})
    : super(const GroupsListState.initial()) {
    Future<void>.microtask(load);
  }

  final GroupsRepository repository;

  Future<void> load() async {
    state = state.copyWith(
      isLoading: true,
      isRefreshing: false,
      clearError: true,
    );

    try {
      final groups = await repository.listMyGroups();
      state = state.copyWith(
        items: groups,
        isLoading: false,
        isRefreshing: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        errorMessage: mapApiErrorToMessage(error),
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, clearError: true);

    try {
      final groups = await repository.listMyGroups();
      state = state.copyWith(
        items: groups,
        isLoading: false,
        isRefreshing: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: mapApiErrorToMessage(error),
      );
    }
  }
}
