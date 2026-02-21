import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../data/models/group_model.dart';
import '../../../data/models/member_model.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../group_detail_controller.dart';

class GroupMembersTab extends ConsumerWidget {
  const GroupMembersTab({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(groupMembersProvider(groupId));

    return KitCard(
      child: membersAsync.when(
        loading: () => const LoadingView(message: 'Loading members...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () =>
              ref.read(groupDetailControllerProvider).refreshMembers(groupId),
        ),
        data: (members) {
          if (members.isEmpty) {
            return const KitEmptyState(
              icon: Icons.people_outline,
              title: 'No members yet',
              message: 'No members were found for this group.',
            );
          }

          return Column(
            children: [
              for (var i = 0; i < members.length; i++) ...[
                _MemberListRow(member: members[i], index: i),
                if (i != members.length - 1)
                  Divider(
                    height: AppSpacing.lg,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _MemberListRow extends StatelessWidget {
  const _MemberListRow({required this.member, required this.index});

  final MemberModel member;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final roleLabel = switch (member.role) {
      MemberRoleModel.admin => 'ADMIN',
      MemberRoleModel.member => 'MEMBER',
      MemberRoleModel.unknown => 'UNKNOWN',
    };
    final statusLabel = switch (member.status) {
      MemberStatusModel.active => 'ACTIVE',
      MemberStatusModel.invited => 'INVITED',
      MemberStatusModel.left => 'LEFT',
      MemberStatusModel.removed => 'REMOVED',
      MemberStatusModel.unknown => 'UNKNOWN',
    };
    final payoutLabel = member.payoutPosition == null
        ? 'Payout order not set'
        : 'Payout #${member.payoutPosition}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.displayName,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                payoutLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  StatusPill.fromLabel(roleLabel),
                  StatusPill.fromLabel(statusLabel),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
