import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/group_model.dart';
import '../../../shared/ui/ui.dart';
import '../../../shared/widgets/error_view.dart';
import '../groups_list_controller.dart';

class GroupsListScreen extends ConsumerWidget {
  const GroupsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(groupsListProvider);

    ref.listen(groupsListProvider, (previous, next) {
      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;
      if (nextError != null &&
          nextError.isNotEmpty &&
          previousError != nextError) {
        AppSnackbars.error(context, nextError);
      }
    });

    Future<void> onRefresh() {
      return ref.read(groupsListProvider.notifier).refresh();
    }

    return AppScaffold(
      title: 'Groups',
      subtitle: 'Track your Equb groups and payment cycles',
      actions: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: () => context.push(AppRoutePaths.notifications),
          icon: const Icon(Icons.notifications_outlined),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FilledButton.icon(
                onPressed: () => context.push(AppRoutePaths.groupsCreate),
                icon: const Icon(Icons.add),
                label: const Text('Create group'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push(AppRoutePaths.groupsJoin),
                icon: const Icon(Icons.group_add_outlined),
                label: const Text('Join'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: _GroupsBody(
              state: state,
              onRetry: () => ref.read(groupsListProvider.notifier).load(),
              onRefresh: onRefresh,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupsBody extends StatelessWidget {
  const _GroupsBody({
    required this.state,
    required this.onRetry,
    required this.onRefresh,
  });

  final GroupsListState state;
  final VoidCallback onRetry;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && !state.hasData) {
      return ListView.separated(
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) => const EqubCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(height: 18, width: 180),
              SizedBox(height: AppSpacing.sm),
              SkeletonBox(height: 14, width: 120),
            ],
          ),
        ),
      );
    }

    if (state.errorMessage != null && !state.hasData) {
      return ErrorView(message: state.errorMessage!, onRetry: onRetry);
    }

    if (!state.hasData) {
      return EmptyState(
        icon: Icons.groups_2_outlined,
        title: 'No groups yet',
        message: 'Create a group or join one with an invite code.',
        ctaLabel: 'Create group',
        onCtaPressed: () => context.push(AppRoutePaths.groupsCreate),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        itemCount: state.items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) => _GroupCard(group: state.items[index]),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group});

  final GroupModel group;

  @override
  Widget build(BuildContext context) {
    final frequency = switch (group.frequency) {
      GroupFrequencyModel.weekly => 'WEEKLY',
      GroupFrequencyModel.monthly => 'MONTHLY',
      GroupFrequencyModel.unknown => 'UNKNOWN',
    };

    return EqubCard(
      onTap: () => context.push(AppRoutePaths.groupDetail(group.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  group.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              StatusBadge.fromLabel(frequency),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          AmountText(
            amount: group.contributionAmount,
            currency: group.currency,
          ),
        ],
      ),
    );
  }
}
