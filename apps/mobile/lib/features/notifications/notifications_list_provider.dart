import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../data/models/notification_model.dart';
import '../../data/notifications/notifications_repository.dart';
import '../../shared/utils/api_error_mapper.dart';

class NotificationsListState {
  const NotificationsListState({
    required this.items,
    required this.total,
    required this.offset,
    required this.limit,
    required this.isLoading,
    required this.isRefreshing,
    required this.isLoadingMore,
    this.errorMessage,
  });

  const NotificationsListState.initial()
    : this(
        items: const <NotificationModel>[],
        total: 0,
        offset: 0,
        limit: 20,
        isLoading: false,
        isRefreshing: false,
        isLoadingMore: false,
      );

  final List<NotificationModel> items;
  final int total;
  final int offset;
  final int limit;
  final bool isLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? errorMessage;

  bool get hasData => items.isNotEmpty;
  bool get hasMore => items.length < total;

  NotificationsListState copyWith({
    List<NotificationModel>? items,
    int? total,
    int? offset,
    int? limit,
    bool? isLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationsListState(
      items: items ?? this.items,
      total: total ?? this.total,
      offset: offset ?? this.offset,
      limit: limit ?? this.limit,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final notificationsListProvider =
    StateNotifierProvider<NotificationsListController, NotificationsListState>((
      ref,
    ) {
      final repository = ref.watch(notificationsRepositoryProvider);
      return NotificationsListController(repository: repository);
    });

class NotificationsListController
    extends StateNotifier<NotificationsListState> {
  NotificationsListController({required NotificationsRepository repository})
    : _repository = repository,
      super(const NotificationsListState.initial()) {
    Future<void>.microtask(loadInitial);
  }

  final NotificationsRepository _repository;

  Future<void> loadInitial() async {
    state = state.copyWith(
      isLoading: true,
      isRefreshing: false,
      isLoadingMore: false,
      clearError: true,
    );

    try {
      final result = await _repository.listNotifications(limit: state.limit);
      state = state.copyWith(
        items: result.items,
        total: result.total,
        offset: result.offset,
        limit: result.limit,
        isLoading: false,
        isRefreshing: false,
        isLoadingMore: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        isLoadingMore: false,
        errorMessage: mapApiErrorToMessage(error),
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(
      isRefreshing: true,
      isLoading: false,
      isLoadingMore: false,
      clearError: true,
    );

    try {
      final result = await _repository.listNotifications(limit: state.limit);
      state = state.copyWith(
        items: result.items,
        total: result.total,
        offset: result.offset,
        limit: result.limit,
        isLoading: false,
        isRefreshing: false,
        isLoadingMore: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: mapApiErrorToMessage(error),
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore ||
        state.isLoading ||
        state.isRefreshing ||
        state.isLoadingMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final result = await _repository.listNotifications(
        offset: state.items.length,
        limit: state.limit,
      );

      state = state.copyWith(
        items: <NotificationModel>[...state.items, ...result.items],
        total: result.total,
        offset: result.offset,
        limit: result.limit,
        isLoadingMore: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: mapApiErrorToMessage(error),
      );
    }
  }

  void upsert(NotificationModel notification) {
    final index = state.items.indexWhere((item) => item.id == notification.id);
    if (index == -1) {
      return;
    }

    final updatedItems = List<NotificationModel>.from(state.items);
    updatedItems[index] = notification;
    state = state.copyWith(items: updatedItems);
  }
}
