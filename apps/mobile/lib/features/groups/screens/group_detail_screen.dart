import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/group_model.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/ui/ui.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../group_detail_controller.dart';

class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupDetailProvider(groupId));
    final membersAsync = ref.watch(groupMembersProvider(groupId));

    return KitScaffold(
      appBar: KitAppBar(
        title: 'Group detail',
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () =>
                ref.read(groupDetailControllerProvider).refreshAll(groupId),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      child: groupAsync.when(
        loading: () => const LoadingView(message: 'Loading group...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () =>
              ref.read(groupDetailControllerProvider).refreshAll(groupId),
        ),
        data: (group) => _GroupDetailContent(
          group: group,
          memberCount: membersAsync.valueOrNull?.length,
        ),
      ),
    );
  }
}

class _GroupDetailContent extends StatelessWidget {
  const _GroupDetailContent({required this.group, this.memberCount});

  final GroupModel group;
  final int? memberCount;

  @override
  Widget build(BuildContext context) {
    final isAdmin = group.membership?.role == MemberRoleModel.admin;
    final roleLabel = switch (group.membership?.role) {
      MemberRoleModel.admin => 'ADMIN',
      MemberRoleModel.member => 'MEMBER',
      _ => 'UNKNOWN',
    };
    final frequency = switch (group.frequency) {
      GroupFrequencyModel.weekly => 'WEEKLY',
      GroupFrequencyModel.monthly => 'MONTHLY',
      GroupFrequencyModel.unknown => 'UNKNOWN',
    };

    return ListView(
      children: [
        KitCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      group.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  StatusPill.fromLabel(roleLabel),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _StatItem(
                    label: 'Contribution',
                    child: AmountText(
                      amount: group.contributionAmount,
                      currency: group.currency,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  _StatItem(label: 'Frequency', child: Text(frequency)),
                  _StatItem(
                    label: 'Members',
                    child: Text(memberCount == null ? '-' : '$memberCount'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const KitSectionHeader(title: 'Actions'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 1.9,
          children: [
            _ActionTile(
              icon: Icons.people_outline,
              label: 'Members',
              onTap: () => context.push(AppRoutePaths.groupMembers(group.id)),
            ),
            _ActionTile(
              icon: Icons.timelapse_outlined,
              label: 'Cycles',
              onTap: () => context.push(AppRoutePaths.groupCycles(group.id)),
            ),
            if (isAdmin)
              _ActionTile(
                icon: Icons.share_outlined,
                label: 'Invite',
                onTap: () => context.push(AppRoutePaths.groupInvite(group.id)),
              ),
            if (isAdmin)
              _ActionTile(
                icon: Icons.swap_vert_rounded,
                label: 'Payout order',
                onTap: () =>
                    context.push(AppRoutePaths.groupPayoutOrder(group.id)),
              ),
          ],
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return KitCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: SizedBox(
        width: 110,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            child,
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return KitCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}
