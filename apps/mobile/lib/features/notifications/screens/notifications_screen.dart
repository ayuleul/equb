import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/notification_model.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/error_view.dart';
import '../deeplink_mapper.dart';
import '../notification_actions_controller.dart';
import '../notifications_list_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _showUnreadOnly = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsListProvider);
    final actionsState = ref.watch(notificationActionsControllerProvider);

    ref.listen(notificationsListProvider, (previous, next) {
      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;
      if (nextError != null &&
          nextError.isNotEmpty &&
          previousError != nextError) {
        KitToast.error(context, nextError);
      }
    });

    ref.listen(notificationActionsControllerProvider, (previous, next) {
      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;
      if (nextError != null &&
          nextError.isNotEmpty &&
          previousError != nextError) {
        KitToast.error(context, nextError);
      }
    });

    Future<void> onRefresh() {
      return ref.read(notificationsListProvider.notifier).refresh();
    }

    Future<void> onTapNotification(NotificationModel notification) async {
      final updated = await ref
          .read(notificationActionsControllerProvider.notifier)
          .markRead(notification);

      if (!context.mounted || updated == null) {
        return;
      }

      final location = mapNotificationPayloadToLocation(
        updated.deepLinkPayload,
      );
      if (location == null) {
        KitToast.info(context, 'No details available.');
        return;
      }

      navigateToDeepLinkFromContext(context, location);
    }

    final unreadCount = state.items.where((item) => item.isUnread).length;
    final visibleItems = _showUnreadOnly
        ? state.items.where((item) => item.isUnread).toList(growable: false)
        : state.items;

    return KitScaffold(
      title: 'Notifications',
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: () =>
              ref.read(notificationsListProvider.notifier).refresh(),
          icon: const Icon(Icons.refresh),
        ),
      ],
      child: _NotificationsBody(
        state: state,
        actionsState: actionsState,
        unreadCount: unreadCount,
        showUnreadOnly: _showUnreadOnly,
        visibleItems: visibleItems,
        onToggleUnread: (value) => setState(() => _showUnreadOnly = value),
        onRefresh: onRefresh,
        onRetry: () =>
            ref.read(notificationsListProvider.notifier).loadInitial(),
        onLoadMore: () =>
            ref.read(notificationsListProvider.notifier).loadMore(),
        onTapNotification: onTapNotification,
      ),
    );
  }
}

class _NotificationsBody extends StatelessWidget {
  const _NotificationsBody({
    required this.state,
    required this.actionsState,
    required this.unreadCount,
    required this.showUnreadOnly,
    required this.visibleItems,
    required this.onToggleUnread,
    required this.onRefresh,
    required this.onRetry,
    required this.onLoadMore,
    required this.onTapNotification,
  });

  final NotificationsListState state;
  final NotificationActionsState actionsState;
  final int unreadCount;
  final bool showUnreadOnly;
  final List<NotificationModel> visibleItems;
  final ValueChanged<bool> onToggleUnread;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;
  final Future<void> Function(NotificationModel notification) onTapNotification;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && !state.hasData) {
      return const SizedBox(height: 340, child: KitSkeletonList(itemCount: 4));
    }

    if (state.errorMessage != null && !state.hasData) {
      return ErrorView(message: state.errorMessage!, onRetry: onRetry);
    }

    if (!state.hasData) {
      return const KitEmptyState(
        icon: Icons.notifications_none,
        title: 'No notifications yet',
        message: 'You will see member and payment updates here.',
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        itemCount: visibleItems.length + 2,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  FilterChip(
                    label: Text('Unread only ($unreadCount)'),
                    selected: showUnreadOnly,
                    onSelected: onToggleUnread,
                  ),
                ],
              ),
            );
          }

          if (index == visibleItems.length + 1) {
            if (!state.hasMore || showUnreadOnly) {
              return const SizedBox.shrink();
            }

            return Align(
              alignment: Alignment.centerLeft,
              child: KitSecondaryButton(
                onPressed: state.isLoadingMore ? null : onLoadMore,
                label: state.isLoadingMore ? 'Loading...' : 'Load more',
                expand: false,
              ),
            );
          }

          final notification = visibleItems[index - 1];
          final isLoading =
              actionsState.isLoading &&
              actionsState.activeNotificationId == notification.id;

          return KitCard(
            child: ListTile(
              onTap: isLoading ? null : () => onTapNotification(notification),
              minVerticalPadding: AppSpacing.sm,
              leading: _UnreadIndicator(isUnread: notification.isUnread),
              title: Text(notification.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xs),
                  Text(notification.body),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    formatRelativeTime(notification.createdAt),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
              trailing: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
}

class _UnreadIndicator extends StatelessWidget {
  const _UnreadIndicator({required this.isUnread});

  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (!isUnread) {
      return Icon(
        Icons.notifications_none,
        color: colorScheme.onSurfaceVariant,
      );
    }

    return const KitBadge(isDot: true, tone: KitBadgeTone.info);
  }
}
