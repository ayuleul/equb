import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_spacing.dart';
import '../../data/models/group_model.dart';
import '../../data/models/notification_model.dart';
import '../../shared/ui/ui.dart';
import '../../shared/utils/formatters.dart';
import '../groups/groups_list_controller.dart';
import '../notifications/notifications_list_provider.dart';
import '../auth/auth_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final groupsState = ref.watch(groupsListProvider);
    final notificationsState = ref.watch(notificationsListProvider);
    final displayName = user?.fullName?.trim().isNotEmpty == true
        ? user!.fullName!.trim()
        : (user?.phone ?? 'there');
    final activeGroupsCount = groupsState.items
        .where((group) => group.status == GroupStatusModel.active)
        .length;
    final pendingContributionsCount = notificationsState.items
        .where(
          (notification) =>
              notification.isUnread &&
              _isPendingContributionType(notification.type),
        )
        .length;
    final upcomingGroup = _resolveUpcomingGroup(groupsState.items);

    return AppScaffold(
      title: 'Home',
      subtitle: 'Welcome back, $displayName',
      actions: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: () => context.push(AppRoutePaths.notifications),
          icon: const Icon(Icons.notifications_outlined),
        ),
      ],
      child: RefreshIndicator(
        onRefresh: () => ref.read(groupsListProvider.notifier).refresh(),
        child: ListView(
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Active equbs',
                    value: '$activeGroupsCount',
                    icon: Icons.groups_2_outlined,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _StatCard(
                    label: 'Pending contributions',
                    value: '$pendingContributionsCount',
                    icon: Icons.pending_actions_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SectionHeader(
              title: 'Upcoming due cycle',
              actionLabel: 'View equbs',
              onActionPressed: () => context.go(AppRoutePaths.groups),
            ),
            if (groupsState.isLoading && groupsState.items.isEmpty)
              const EqubCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(height: 18, width: 180),
                    SizedBox(height: AppSpacing.sm),
                    SkeletonBox(height: 14, width: 120),
                  ],
                ),
              )
            else if (upcomingGroup != null)
              EqubCard(
                onTap: () =>
                    context.push(AppRoutePaths.groupDetail(upcomingGroup.id)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      upcomingGroup.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AmountText(
                      amount: upcomingGroup.contributionAmount,
                      currency: upcomingGroup.currency,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Start date: ${formatDate(upcomingGroup.startDate)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              )
            else
              const EqubCard(
                child: Text(
                  'No cycle data yet. Create or join an equb to see upcoming cycles.',
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            const SectionHeader(title: 'Recent activity'),
            const EqubCard(
              child: Text(
                'Activity feed will appear here as members contribute and payouts are confirmed.',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (groupsState.items.isEmpty && !groupsState.isLoading)
              EmptyState(
                icon: Icons.dashboard_outlined,
                title: 'No equbs yet',
                message: 'Create a new equb or join one with an invite code.',
                ctaLabel: 'Go to My Equbs',
                onCtaPressed: () => context.go(AppRoutePaths.groups),
              )
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go(AppRoutePaths.groups),
                  child: const Text('Go to My Equbs'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

GroupModel? _resolveUpcomingGroup(List<GroupModel> groups) {
  if (groups.isEmpty) {
    return null;
  }

  final activeGroups = groups
      .where((group) => group.status == GroupStatusModel.active)
      .toList(growable: false);
  if (activeGroups.isEmpty) {
    return groups.first;
  }

  activeGroups.sort((a, b) => a.startDate.compareTo(b.startDate));
  final now = DateTime.now();
  for (final group in activeGroups) {
    if (group.startDate.isAfter(now)) {
      return group;
    }
  }

  return activeGroups.first;
}

bool _isPendingContributionType(NotificationTypeModel type) {
  return type == NotificationTypeModel.dueReminder ||
      type == NotificationTypeModel.contributionRejected;
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return EqubCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
