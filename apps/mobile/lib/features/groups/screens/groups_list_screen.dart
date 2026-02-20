import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/group_model.dart';
import '../../../features/auth/auth_controller.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../groups_list_controller.dart';

class GroupsListScreen extends ConsumerWidget {
  const GroupsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(groupsListProvider);
    final authState = ref.watch(authControllerProvider);

    ref.listen(groupsListProvider, (previous, next) {
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
      return ref.read(groupsListProvider.notifier).refresh();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => context.go(AppRoutePaths.notifications),
            icon: const Icon(Icons.notifications_outlined),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: authState.isLoggingOut
                ? null
                : () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  FilledButton.icon(
                    onPressed: () => context.go(AppRoutePaths.groupsCreate),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Group'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.go(AppRoutePaths.groupsJoin),
                    icon: const Icon(Icons.group_add),
                    label: const Text('Join Group'),
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
        ),
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
      return const LoadingView(message: 'Loading groups...');
    }

    if (state.errorMessage != null && !state.hasData) {
      return ErrorView(message: state.errorMessage!, onRetry: onRetry);
    }

    if (!state.hasData) {
      return const _EmptyGroupsView();
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        itemCount: state.items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final group = state.items[index];
          return _GroupCard(group: group);
        },
      ),
    );
  }
}

class _EmptyGroupsView extends StatelessWidget {
  const _EmptyGroupsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'You are not in any group yet. Create one or join by invite code.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group});

  final GroupModel group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final frequency = switch (group.frequency) {
      GroupFrequencyModel.weekly => 'WEEKLY',
      GroupFrequencyModel.monthly => 'MONTHLY',
      GroupFrequencyModel.unknown => 'UNKNOWN',
    };

    return Card(
      child: ListTile(
        onTap: () => context.go(AppRoutePaths.groupDetail(group.id)),
        title: Text(group.name, style: theme.textTheme.titleMedium),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${group.contributionAmount} ${group.currency}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Chip(label: Text(frequency)),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
