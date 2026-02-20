import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/group_model.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../group_detail_controller.dart';

class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupDetailProvider(groupId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Detail'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () =>
                ref.read(groupDetailControllerProvider).refreshAll(groupId),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: groupAsync.when(
          loading: () => const LoadingView(message: 'Loading group...'),
          error: (error, _) => ErrorView(
            message: error.toString(),
            onRetry: () =>
                ref.read(groupDetailControllerProvider).refreshAll(groupId),
          ),
          data: (group) => _GroupDetailContent(group: group),
        ),
      ),
    );
  }
}

class _GroupDetailContent extends StatelessWidget {
  const _GroupDetailContent({required this.group});

  final GroupModel group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final roleLabel = switch (group.membership?.role) {
      MemberRoleModel.admin => 'ADMIN',
      MemberRoleModel.member => 'MEMBER',
      MemberRoleModel.unknown => 'UNKNOWN',
      null => 'UNKNOWN',
    };

    final isAdmin = group.membership?.role == MemberRoleModel.admin;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(group.name, style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Contribution: ${group.contributionAmount} ${group.currency}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Frequency: ${switch (group.frequency) {
                    GroupFrequencyModel.weekly => 'WEEKLY',
                    GroupFrequencyModel.monthly => 'MONTHLY',
                    GroupFrequencyModel.unknown => 'UNKNOWN',
                  }}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text('Role: $roleLabel', style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton.icon(
          onPressed: () => context.go(AppRoutePaths.groupMembers(group.id)),
          icon: const Icon(Icons.people),
          label: const Text('Members'),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (isAdmin)
          FilledButton.icon(
            onPressed: () => context.go(AppRoutePaths.groupInvite(group.id)),
            icon: const Icon(Icons.share),
            label: const Text('Create Invite'),
          ),
        const SizedBox(height: AppSpacing.sm),
        FilledButton.icon(
          onPressed: () => context.go(AppRoutePaths.groupCycles(group.id)),
          icon: const Icon(Icons.timelapse),
          label: const Text('Cycles'),
        ),
        if (isAdmin) ...[
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () =>
                context.go(AppRoutePaths.groupPayoutOrder(group.id)),
            icon: const Icon(Icons.swap_vert),
            label: const Text('Payout order'),
          ),
        ],
      ],
    );
  }
}
