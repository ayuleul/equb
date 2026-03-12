import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/cycle_model.dart';
import '../../../data/models/group_model.dart';
import '../../../data/models/join_request_model.dart';
import '../../../data/models/member_model.dart';
import '../../../data/models/member_status_utils.dart';
import '../../../shared/copy/lottery_copy.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/utils/api_error_mapper.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/utils/reputation_presenter.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/reputation_badge.dart';
import '../../cycles/current_cycle_provider.dart';
import '../../cycles/cycles_list_provider.dart';
import '../group_detail_controller.dart';
import '../public_groups_controller.dart';
import '../widgets/group_invite_sheet.dart';
import '../widgets/group_more_actions_button.dart';

class GroupOverviewScreen extends ConsumerWidget {
  const GroupOverviewScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupDetailProvider(groupId));
    final group = groupAsync.valueOrNull;
    final isAdmin = group?.membership?.role == MemberRoleModel.admin;

    return KitScaffold(
      appBar: KitAppBar(
        title: group?.name ?? 'Group overview',
        actions: [
          if (group != null)
            _GroupOverviewMenuButton(group: group, isAdmin: isAdmin),
        ],
      ),
      child: groupAsync.when(
        loading: () => const LoadingView(message: 'Loading group...'),
        error: (error, _) => ErrorView(
          message: mapFriendlyError(error),
          onRetry: () =>
              ref.read(groupDetailControllerProvider).refreshAll(groupId),
        ),
        data: (group) => _GroupOverviewBody(group: group),
      ),
    );
  }
}

class _GroupOverviewBody extends ConsumerWidget {
  const _GroupOverviewBody({required this.group});

  final GroupModel group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(groupMembersProvider(group.id));
    final currentCycleAsync = ref.watch(currentCycleProvider(group.id));
    final cyclesAsync = ref.watch(cyclesListProvider(group.id));
    final isAdmin = group.membership?.role == MemberRoleModel.admin;

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(groupDetailControllerProvider)
            .refreshGroupPage(
              group.id,
              cycleId: currentCycleAsync.valueOrNull?.id,
            );
        if (isAdmin) {
          await ref
              .read(publicGroupsControllerProvider)
              .refreshJoinRequests(group.id);
        }
      },
      child: ListView(
        children: [
          if (isAdmin && !group.rulesetConfigured) ...[
            KitBanner(
              title: 'Rules setup required',
              message:
                  'Save group rules before inviting members or starting the first cycle.',
              tone: KitBadgeTone.warning,
              icon: Icons.rule_folder_outlined,
              ctaLabel: 'Open setup',
              onCtaPressed: () =>
                  context.push(AppRoutePaths.groupSetup(group.id)),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          _GroupInfoCard(
            group: group,
            membersAsync: membersAsync,
            currentCycleAsync: currentCycleAsync,
            cyclesAsync: cyclesAsync,
          ),
          const SizedBox(height: AppSpacing.md),
          _GroupTrustCard(group: group),
          const SizedBox(height: AppSpacing.md),
          _MembersCard(
            groupId: group.id,
            isAdmin: isAdmin,
            canInviteMembers: group.canInviteMembers,
            membersAsync: membersAsync,
          ),
          if (isAdmin) ...[
            const SizedBox(height: AppSpacing.md),
            _JoinRequestsCard(groupId: group.id),
          ],
        ],
      ),
    );
  }
}

class _GroupInfoCard extends StatelessWidget {
  const _GroupInfoCard({
    required this.group,
    required this.membersAsync,
    required this.currentCycleAsync,
    required this.cyclesAsync,
  });

  final GroupModel group;
  final AsyncValue<List<MemberModel>> membersAsync;
  final AsyncValue<CycleModel?> currentCycleAsync;
  final AsyncValue<List<CycleModel>> cyclesAsync;

  @override
  Widget build(BuildContext context) {
    if (membersAsync.isLoading ||
        cyclesAsync.isLoading ||
        currentCycleAsync.isLoading) {
      return const KitCard(
        child: SizedBox(height: 180, child: KitSkeletonList(itemCount: 4)),
      );
    }

    if (membersAsync.hasError ||
        cyclesAsync.hasError ||
        currentCycleAsync.hasError) {
      final error =
          membersAsync.error ?? cyclesAsync.error ?? currentCycleAsync.error;
      return ErrorView(
        message: mapFriendlyError(error ?? 'Unable to load group info.'),
      );
    }

    final members = membersAsync.valueOrNull ?? const <MemberModel>[];
    final activeMemberCount = members
        .where((member) => isParticipatingMemberStatus(member.status))
        .length;
    final cycles = cyclesAsync.valueOrNull ?? const <CycleModel>[];
    final currentCycle = currentCycleAsync.valueOrNull;

    final summary = _buildLotterySummary(
      activeMemberCount: activeMemberCount,
      group: group,
      currentCycle: currentCycle,
      cycles: cycles,
    );

    return KitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Group Info', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(
            label: 'Contribution',
            value: formatCurrency(group.contributionAmount, group.currency),
          ),
          _SummaryRow(
            label: 'Frequency',
            value: _frequencyLabel(group.frequency),
          ),
          _SummaryRow(label: 'Members', value: '$activeMemberCount'),
          const _SummaryRow(label: 'Payout mode', value: LotteryCopy.label),
          _SummaryRow(
            label: 'Cycle progress',
            value:
                '${summary.turnsCompleted} / ${summary.totalTurns} completed',
          ),
          _SummaryRow(label: 'Last winner', value: summary.lastWinnerName),
          _StatusSummaryRow(status: summary.status),
        ],
      ),
    );
  }

  _LotterySummaryData _buildLotterySummary({
    required int activeMemberCount,
    required GroupModel group,
    required CycleModel? currentCycle,
    required List<CycleModel> cycles,
  }) {
    final latestRoundId =
        currentCycle?.roundId ??
        (cycles.isNotEmpty ? cycles.first.roundId : null);
    final roundCycles = latestRoundId == null
        ? <CycleModel>[]
        : cycles
              .where((cycle) => cycle.roundId == latestRoundId)
              .toList(growable: true);
    roundCycles.sort((a, b) => b.cycleNo.compareTo(a.cycleNo));

    final turnsCompleted = roundCycles.length;
    final totalTurns = activeMemberCount;
    final isCompleted =
        totalTurns > 0 && turnsCompleted >= totalTurns && currentCycle == null;
    final hasStarted = roundCycles.isNotEmpty || currentCycle != null;

    return _LotterySummaryData(
      turnsCompleted: turnsCompleted,
      totalTurns: totalTurns,
      status: _groupOverviewStatus(
        group: group,
        isCompleted: isCompleted,
        hasStarted: hasStarted,
        currentCycle: currentCycle,
      ),
      isCompleted: isCompleted,
      lastWinnerName: roundCycles.isEmpty
          ? LotteryCopy.noWinnerYet
          : _cycleWinnerLabel(roundCycles.first),
    );
  }
}

class _LotterySummaryData {
  const _LotterySummaryData({
    required this.turnsCompleted,
    required this.totalTurns,
    required this.lastWinnerName,
    required this.status,
    required this.isCompleted,
  });

  final int turnsCompleted;
  final int totalTurns;
  final String lastWinnerName;
  final _OverviewStatus status;
  final bool isCompleted;
}

class _MembersCard extends ConsumerWidget {
  const _MembersCard({
    required this.groupId,
    required this.isAdmin,
    required this.canInviteMembers,
    required this.membersAsync,
  });

  final String groupId;
  final bool isAdmin;
  final bool canInviteMembers;
  final AsyncValue<List<MemberModel>> membersAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberCount = membersAsync.valueOrNull?.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KitSectionHeader(
          title: 'Members${memberCount == null ? '' : ' ($memberCount)'}',
        ),
        membersAsync.when(
          loading: () => const KitCard(
            child: Column(
              children: [
                KitSkeletonBox(height: AppSpacing.lg, width: double.infinity),
                SizedBox(height: AppSpacing.sm),
                KitSkeletonBox(height: AppSpacing.lg, width: double.infinity),
                SizedBox(height: AppSpacing.sm),
                KitSkeletonBox(height: AppSpacing.lg, width: double.infinity),
              ],
            ),
          ),
          error: (error, _) => ErrorView(
            message: mapFriendlyError(error),
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

            return KitCard(
              child: Column(
                children: [
                  for (var i = 0; i < members.length; i++) ...[
                    _MemberListRow(member: members[i]),
                    if (i != members.length - 1)
                      Divider(
                        height: AppSpacing.lg,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                  ],
                ],
              ),
            );
          },
        ),
        if (isAdmin) ...[
          const SizedBox(height: AppSpacing.sm),
          KitPrimaryButton(
            label: 'Invite member',
            icon: Icons.person_add_alt_1_rounded,
            onPressed: canInviteMembers
                ? () => showGroupInviteSheet(
                    context: context,
                    ref: ref,
                    groupId: groupId,
                  )
                : () => context.push(AppRoutePaths.groupSetup(groupId)),
          ),
          if (!canInviteMembers)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                'Complete rules setup to enable invites.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ],
    );
  }
}

class _GroupTrustCard extends StatelessWidget {
  const _GroupTrustCard({required this.group});

  final GroupModel group;

  @override
  Widget build(BuildContext context) {
    final trust = group.trustSummary;
    if (trust == null) {
      return const SizedBox.shrink();
    }

    return KitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Group trust', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _SummaryRow(
                  label: 'Group trust level',
                  value: trust.groupTrustLevel,
                ),
              ),
              ReputationBadge(trustLevel: trust.host.trustLevel),
            ],
          ),
          _SummaryRow(label: 'Host score', value: '${trust.hostScore}'),
          _SummaryRow(
            label: 'Average member score',
            value: trust.averageMemberScore == null
                ? 'Not enough data'
                : '${trust.averageMemberScore!.round()}',
          ),
        ],
      ),
    );
  }
}

class _MemberListRow extends StatelessWidget {
  const _MemberListRow({required this.member});

  final MemberModel member;

  @override
  Widget build(BuildContext context) {
    final roleLabel = switch (member.role) {
      MemberRoleModel.admin => 'ADMIN',
      MemberRoleModel.member => 'MEMBER',
      MemberRoleModel.unknown => 'UNKNOWN',
    };
    final statusLabel = switch (member.status) {
      _ => memberStatusLabel(member.status),
    };

    return Row(
      children: [
        KitAvatar(name: member.displayName, size: KitAvatarSize.sm),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.displayName,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if (member.reputation != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Score ${member.reputation!.trustScore}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        if (member.reputation != null) ...[
          ReputationBadge(trustLevel: member.reputation!.trustLevel),
          const SizedBox(width: AppSpacing.xs),
        ],
        StatusPill.fromLabel(roleLabel),
        if (!isParticipatingMemberStatus(member.status)) ...[
          const SizedBox(width: AppSpacing.xs),
          StatusPill.fromLabel(statusLabel),
        ],
      ],
    );
  }
}

class _JoinRequestsCard extends ConsumerWidget {
  const _JoinRequestsCard({required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(pendingJoinRequestsProvider(groupId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KitSectionHeader(title: 'Join Requests'),
        requestsAsync.when(
          loading: () => const KitCard(
            child: Column(
              children: [
                KitSkeletonBox(height: AppSpacing.lg, width: double.infinity),
                SizedBox(height: AppSpacing.sm),
                KitSkeletonBox(height: AppSpacing.lg, width: double.infinity),
              ],
            ),
          ),
          error: (error, _) => ErrorView(
            message: mapFriendlyError(error),
            onRetry: () => ref.invalidate(pendingJoinRequestsProvider(groupId)),
          ),
          data: (requests) {
            if (requests.isEmpty) {
              return const KitCard(
                child: Text('No pending join requests right now.'),
              );
            }

            return KitCard(
              child: Column(
                children: [
                  for (var i = 0; i < requests.length; i++) ...[
                    _JoinRequestRow(groupId: groupId, request: requests[i]),
                    if (i != requests.length - 1)
                      Divider(
                        height: AppSpacing.lg,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _JoinRequestRow extends ConsumerStatefulWidget {
  const _JoinRequestRow({required this.groupId, required this.request});

  final String groupId;
  final JoinRequestModel request;

  @override
  ConsumerState<_JoinRequestRow> createState() => _JoinRequestRowState();
}

class _JoinRequestRowState extends ConsumerState<_JoinRequestRow> {
  bool _isWorking = false;

  Future<void> _review(bool approve) async {
    setState(() => _isWorking = true);
    try {
      final controller = ref.read(publicGroupsControllerProvider);
      if (approve) {
        await controller.approveJoinRequest(widget.groupId, widget.request.id);
      } else {
        await controller.rejectJoinRequest(widget.groupId, widget.request.id);
      }

      if (!mounted) {
        return;
      }

      KitToast.success(
        context,
        approve ? 'Join request approved.' : 'Join request rejected.',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      KitToast.error(context, mapApiErrorToMessage(error));
    } finally {
      if (mounted) {
        setState(() => _isWorking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reputation = widget.request.user?.reputation;
    final onTimeRate = formatOnTimeRate(reputation?.onTimePaymentRate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.request.requesterName,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            if (reputation != null)
              ReputationBadge(trustLevel: reputation.trustLevel),
          ],
        ),
        if (reputation != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Trust score: ${reputation.trustScore} • ${reputation.trustLevel}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Completed Equbs: ${reputation.equbsCompleted} • On-time payments: $onTimeRate • Hosted Equbs: ${reputation.equbsHosted}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if ((widget.request.message ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(widget.request.message!),
        ],
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: KitSecondaryButton(
                label: _isWorking ? 'Working...' : 'Reject',
                onPressed: _isWorking ? null : () => _review(false),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: KitPrimaryButton(
                label: _isWorking ? 'Working...' : 'Approve',
                onPressed: _isWorking ? null : () => _review(true),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusSummaryRow extends StatelessWidget {
  const _StatusSummaryRow({required this.status});

  final _OverviewStatus status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Status',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 10, color: status.color),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    status.label,
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupOverviewMenuButton extends StatelessWidget {
  const _GroupOverviewMenuButton({required this.group, required this.isAdmin});

  final GroupModel group;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    if (!isAdmin) {
      return GroupMoreActionsButton(groupName: group.name, isAdmin: false);
    }

    return PopupMenuButton<_OverviewMenuAction>(
      tooltip: 'More actions',
      offset: const Offset(0, 10),
      onSelected: (value) => _handleSelected(context, value),
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _OverviewMenuAction.edit,
          child: _OverviewMenuRow(
            icon: Icons.edit_outlined,
            label: 'Edit group',
          ),
        ),
        PopupMenuItem(
          value: _OverviewMenuAction.close,
          child: _OverviewMenuRow(
            icon: Icons.lock_outline_rounded,
            label: 'Close group',
            isDestructive: true,
          ),
        ),
      ],
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Icon(
          Icons.grid_view_rounded,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 24,
        ),
      ),
    );
  }

  Future<void> _handleSelected(
    BuildContext context,
    _OverviewMenuAction action,
  ) async {
    switch (action) {
      case _OverviewMenuAction.edit:
        context.push(AppRoutePaths.groupSetup(group.id));
        return;
      case _OverviewMenuAction.close:
        KitToast.info(
          context,
          'Close group for "${group.name}" is coming soon.',
        );
        return;
    }
  }
}

enum _OverviewMenuAction { edit, close }

class _OverviewMenuRow extends StatelessWidget {
  const _OverviewMenuRow({
    required this.icon,
    required this.label,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onSurface;
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _OverviewStatus {
  const _OverviewStatus({required this.label, required this.color});

  final String label;
  final Color color;
}

String _frequencyLabel(GroupFrequencyModel frequency) {
  return switch (frequency) {
    GroupFrequencyModel.weekly => 'Weekly',
    GroupFrequencyModel.monthly => 'Monthly',
    GroupFrequencyModel.unknown => 'Unknown',
  };
}

String _cycleWinnerLabel(CycleModel cycle) {
  final fullName = cycle.finalPayoutUser?.fullName?.trim();
  if (fullName != null && fullName.isNotEmpty) {
    return fullName;
  }

  final phone = cycle.finalPayoutUser?.phone?.trim();
  if (phone != null && phone.isNotEmpty) {
    return phone;
  }

  return cycle.finalPayoutUserId ?? cycle.payoutUserId;
}

_OverviewStatus _groupOverviewStatus({
  required GroupModel group,
  required bool isCompleted,
  required bool hasStarted,
  required CycleModel? currentCycle,
}) {
  if (group.status == GroupStatusModel.archived) {
    return const _OverviewStatus(label: 'Closed', color: Color(0xFF7A7F87));
  }
  if (isCompleted) {
    return const _OverviewStatus(label: 'Completed', color: Color(0xFF1E8E5A));
  }
  if (currentCycle != null || hasStarted) {
    return const _OverviewStatus(
      label: 'In progress',
      color: Color(0xFF2F6FED),
    );
  }
  return const _OverviewStatus(label: 'Not started', color: Color(0xFFC77700));
}
