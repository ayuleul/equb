import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../data/models/notification_model.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../deeplink_mapper.dart';
import '../notification_actions_controller.dart';
import '../notifications_list_provider.dart';

final DateFormat _timestampFormat = DateFormat('d MMM yyyy, h:mm a');

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsListProvider);
    final actionsState = ref.watch(notificationActionsControllerProvider);

    ref.listen(notificationsListProvider, (previous, next) {
      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;
      if (nextError != null &&
          nextError.isNotEmpty &&
          previousError != nextError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(nextError)));
      }
    });

    ref.listen(notificationActionsControllerProvider, (previous, next) {
      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;
      if (nextError != null &&
          nextError.isNotEmpty &&
          previousError != nextError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(nextError)));
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No details available.')));
        return;
      }

      context.go(location);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () =>
                ref.read(notificationsListProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: _NotificationsBody(
          state: state,
          actionsState: actionsState,
          onRefresh: onRefresh,
          onRetry: () =>
              ref.read(notificationsListProvider.notifier).loadInitial(),
          onLoadMore: () =>
              ref.read(notificationsListProvider.notifier).loadMore(),
          onTapNotification: onTapNotification,
        ),
      ),
    );
  }
}

class _NotificationsBody extends StatelessWidget {
  const _NotificationsBody({
    required this.state,
    required this.actionsState,
    required this.onRefresh,
    required this.onRetry,
    required this.onLoadMore,
    required this.onTapNotification,
  });

  final NotificationsListState state;
  final NotificationActionsState actionsState;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;
  final Future<void> Function(NotificationModel notification) onTapNotification;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && !state.hasData) {
      return const LoadingView(message: 'Loading notifications...');
    }

    if (state.errorMessage != null && !state.hasData) {
      return ErrorView(message: state.errorMessage!, onRetry: onRetry);
    }

    if (!state.hasData) {
      return Center(
        child: Text(
          'No notifications yet',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: state.items.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            if (!state.hasMore) {
              return const SizedBox.shrink();
            }

            return Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: state.isLoadingMore ? null : onLoadMore,
                child: Text(state.isLoadingMore ? 'Loading...' : 'Load more'),
              ),
            );
          }

          final notification = state.items[index];
          final isLoading =
              actionsState.isLoading &&
              actionsState.activeNotificationId == notification.id;

          return Card(
            child: ListTile(
              onTap: isLoading ? null : () => onTapNotification(notification),
              leading: _UnreadIndicator(isUnread: notification.isUnread),
              title: Text(notification.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xs),
                  Text(notification.body),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _timestampFormat.format(notification.createdAt.toLocal()),
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

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        shape: BoxShape.circle,
      ),
    );
  }
}
