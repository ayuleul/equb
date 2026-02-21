import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/group_model.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../group_detail_controller.dart';
import '../widgets/group_cycles_tab.dart';
import '../widgets/group_detail_header_cards.dart';
import '../widgets/group_detail_tab_bar.dart';
import '../widgets/group_members_tab.dart';
import '../widgets/group_more_actions_button.dart';
import '../widgets/group_payout_order_tab.dart';

class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupDetailProvider(groupId));
    final membersAsync = ref.watch(groupMembersProvider(groupId));
    final group = groupAsync.valueOrNull;
    final statusText = _groupStatusLabel(group?.status);
    final isAdmin = group?.membership?.role == MemberRoleModel.admin;

    return KitScaffold(
      appBar: KitAppBar(
        title: group?.name ?? 'Group detail',
        subtitle: group == null ? null : statusText,
        actions: [
          if (group != null)
            GroupMoreActionsButton(groupName: group.name, isAdmin: isAdmin),
          if (group == null)
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

class _GroupDetailContent extends StatefulWidget {
  const _GroupDetailContent({required this.group, this.memberCount});

  final GroupModel group;
  final int? memberCount;

  @override
  State<_GroupDetailContent> createState() => _GroupDetailContentState();
}

class _GroupDetailContentState extends State<_GroupDetailContent> {
  var _selectedTab = GroupDetailTab.members;

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final isAdmin = group.membership?.role == MemberRoleModel.admin;
    final statusLabel = _groupStatusLabel(group.status);
    final frequencyLabel = switch (group.frequency) {
      GroupFrequencyModel.weekly => 'WEEKLY',
      GroupFrequencyModel.monthly => 'MONTHLY',
      GroupFrequencyModel.unknown => 'UNKNOWN',
    };
    final overviewText =
        'This group runs on a ${frequencyLabel.toLowerCase()} schedule. '
        'Each member contributes ${formatCurrency(group.contributionAmount, group.currency)}.';

    return ListView(
      children: [
        GroupInviteBannerCard(
          isAdmin: isAdmin,
          onInviteTap: () => context.push(AppRoutePaths.groupInvite(group.id)),
        ),
        const SizedBox(height: AppSpacing.md),
        GroupOverviewCard(
          statusLabel: statusLabel,
          frequencyLabel: frequencyLabel,
          memberCount: widget.memberCount ?? 0,
          overviewText: overviewText,
        ),
        const SizedBox(height: AppSpacing.md),
        GroupDetailTabBar(
          selectedTab: _selectedTab,
          isAdmin: isAdmin,
          onSelected: _selectTab,
        ),
        const SizedBox(height: AppSpacing.md),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: _tabContent(groupId: group.id, isAdmin: isAdmin),
        ),
      ],
    );
  }

  Widget _tabContent({required String groupId, required bool isAdmin}) {
    return KeyedSubtree(
      key: ValueKey(_selectedTab.name),
      child: switch (_selectedTab) {
        GroupDetailTab.members => GroupMembersTab(groupId: groupId),
        GroupDetailTab.cycles => GroupCyclesTab(
          groupId: groupId,
          isAdmin: isAdmin,
        ),
        GroupDetailTab.payoutOrder => GroupPayoutOrderTab(
          groupId: groupId,
          isAdmin: isAdmin,
        ),
      },
    );
  }

  void _selectTab(GroupDetailTab tab) {
    if (_selectedTab == tab) {
      return;
    }
    setState(() => _selectedTab = tab);
  }
}

String _groupStatusLabel(GroupStatusModel? status) {
  return switch (status) {
    GroupStatusModel.active => 'Active',
    GroupStatusModel.archived => 'Archived',
    _ => 'Unknown',
  };
}
