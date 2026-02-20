import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../data/models/notification_model.dart';
import '../../data/notifications/notifications_repository.dart';
import '../../shared/utils/api_error_mapper.dart';
import 'notifications_list_provider.dart';

class NotificationActionsState {
  const NotificationActionsState({
    required this.isLoading,
    this.activeNotificationId,
    this.errorMessage,
  });

  const NotificationActionsState.initial() : this(isLoading: false);

  final bool isLoading;
  final String? activeNotificationId;
  final String? errorMessage;

  NotificationActionsState copyWith({
    bool? isLoading,
    String? activeNotificationId,
    String? errorMessage,
    bool clearActiveId = false,
    bool clearError = false,
  }) {
    return NotificationActionsState(
      isLoading: isLoading ?? this.isLoading,
      activeNotificationId: clearActiveId
          ? null
          : (activeNotificationId ?? this.activeNotificationId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final notificationActionsControllerProvider =
    StateNotifierProvider<
      NotificationActionsController,
      NotificationActionsState
    >((ref) {
      final repository = ref.watch(notificationsRepositoryProvider);
      return NotificationActionsController(ref: ref, repository: repository);
    });

class NotificationActionsController
    extends StateNotifier<NotificationActionsState> {
  NotificationActionsController({
    required Ref ref,
    required NotificationsRepository repository,
  }) : _ref = ref,
       _repository = repository,
       super(const NotificationActionsState.initial());

  final Ref _ref;
  final NotificationsRepository _repository;

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<NotificationModel?> markRead(NotificationModel notification) async {
    if (!notification.isUnread) {
      return notification;
    }

    state = state.copyWith(
      isLoading: true,
      activeNotificationId: notification.id,
      clearError: true,
    );

    try {
      final updated = await _repository.markRead(notification.id);
      _ref.read(notificationsListProvider.notifier).upsert(updated);
      state = state.copyWith(
        isLoading: false,
        clearActiveId: true,
        clearError: true,
      );
      return updated;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        clearActiveId: true,
        errorMessage: mapApiErrorToMessage(error),
      );
      return null;
    }
  }
}
