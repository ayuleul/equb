import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_spacing.dart';
import '../../data/models/group_model.dart';
import '../../data/models/notification_model.dart';
import '../../shared/kit/kit.dart';
import '../../shared/ui/ui.dart';
import '../../shared/utils/formatters.dart';
import '../groups/groups_list_controller.dart';
import '../notifications/notifications_list_provider.dart';
import '../auth/auth_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(currentUserProvider);
    final groupsState = ref.watch(groupsListProvider);
    final notificationsState = ref.watch(notificationsListProvider);
    final displayName = user?.firstName ?? user?.phone ?? 'there';
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
    final nextDueLabel = upcomingGroup == null
        ? 'No due date'
        : formatDate(upcomingGroup.startDate);

    return KitScaffold(
      child: RefreshIndicator(
        onRefresh: () => ref.read(groupsListProvider.notifier).refresh(),
        child: ListView(
          children: [
            KitSectionHeader(
              title: 'Dashboard',
              kicker: 'Overview',
              subtitle: 'Track your groups, contributions, and due dates.',
              action: IconButton(
                tooltip: 'Notifications',
                onPressed: () => context.push(AppRoutePaths.notifications),
                icon: const Icon(Icons.notifications_outlined),
              ),
            ),
            KitCard(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.05),
                      colorScheme.secondary.withValues(alpha: 0.04),
                    ],
                  ),
                  borderRadius: AppRadius.inputRounded,
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, $displayName',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Your Equb dashboard at a glance.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        color: colorScheme.primary,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
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
            const SizedBox(height: AppSpacing.sm),
            _StatCard(
              label: 'Next due',
              value: nextDueLabel,
              icon: Icons.event_note_outlined,
            ),
            const SizedBox(height: AppSpacing.md),
            KitSectionHeader(
              title: 'Upcoming due cycle',
              kicker: 'Next',
              actionLabel: 'View equbs',
              onActionPressed: () => context.go(AppRoutePaths.groups),
            ),
            if (groupsState.isLoading && groupsState.items.isEmpty)
              const KitCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KitSkeletonBox(height: 18, width: 180),
                    SizedBox(height: AppSpacing.sm),
                    KitSkeletonBox(height: 14, width: 120),
                  ],
                ),
              )
            else if (upcomingGroup != null)
              KitCard(
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
              const KitCard(
                child: Text(
                  'No cycle data yet. Create or join an equb to see upcoming cycles.',
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            const KitSectionHeader(title: 'Recent activity', kicker: 'Feed'),
            const KitCard(
              child: Text(
                'Activity feed will appear here as members contribute and payouts are confirmed.',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (groupsState.items.isEmpty && !groupsState.isLoading)
              KitEmptyState(
                icon: Icons.dashboard_outlined,
                title: 'No equbs yet',
                message: 'Create a new equb or join one with an invite code.',
                ctaLabel: 'Go to My Equbs',
                onCtaPressed: () => context.go(AppRoutePaths.groups),
              )
            else
              KitPrimaryButton(
                label: 'Go to My Equbs',
                onPressed: () => context.go(AppRoutePaths.groups),
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
    final colorScheme = Theme.of(context).colorScheme;

    return KitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: colorScheme.primary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
