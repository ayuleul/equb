import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../data/models/group_model.dart';
import '../../../data/models/member_model.dart';
import '../../../shared/ui/ui.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../group_detail_controller.dart';

class GroupMembersScreen extends ConsumerWidget {
  const GroupMembersScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(groupMembersProvider(groupId));

    return AppScaffold(
      title: 'Members',
      child: membersAsync.when(
        loading: () => const LoadingView(message: 'Loading members...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () =>
              ref.read(groupDetailControllerProvider).refreshMembers(groupId),
        ),
        data: (members) => _MembersList(groupId: groupId, members: members),
      ),
    );
  }
}

class _MembersList extends ConsumerWidget {
  const _MembersList({required this.groupId, required this.members});

  final String groupId;
  final List<MemberModel> members;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (members.isEmpty) {
      return const EmptyState(
        icon: Icons.people_outline,
        title: 'No members yet',
        message: 'No members were found for this group.',
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(groupDetailControllerProvider).refreshMembers(groupId),
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        itemCount: members.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final member = members[index];
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

          return EqubCard(
            child: EqubListTile(
              title: member.displayName,
              subtitle: member.payoutPosition == null
                  ? null
                  : 'Payout #${member.payoutPosition}',
              showChevron: false,
              trailing: Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  StatusBadge.fromLabel(roleLabel),
                  StatusBadge.fromLabel(statusLabel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
