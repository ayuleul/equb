import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/bootstrap.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/cycle_model.dart';
import '../../../data/models/group_model.dart';
import '../../../data/models/member_model.dart';
import '../../../data/models/member_status_utils.dart';
import '../../../shared/copy/lottery_copy.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../cycles/current_cycle_provider.dart';
import '../../cycles/cycles_list_provider.dart';
import '../group_detail_controller.dart';

class GroupOverviewScreen extends ConsumerWidget {
  const GroupOverviewScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupDetailProvider(groupId));
    final group = groupAsync.valueOrNull;

    return KitScaffold(
      appBar: KitAppBar(title: group?.name ?? 'Group overview'),
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
        await ref.read(groupDetailControllerProvider).refreshAll(group.id);
        ref.read(cyclesRepositoryProvider).invalidateGroupCache(group.id);
        ref.invalidate(currentCycleProvider(group.id));
        ref.invalidate(cyclesListProvider(group.id));
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
          _GroupSummaryCard(
            group: group,
            membersCount: membersAsync.valueOrNull?.length,
            currentCycle: currentCycleAsync.valueOrNull,
          ),
          const SizedBox(height: AppSpacing.md),
          _LotterySummaryCard(
            groupId: group.id,
            membersAsync: membersAsync,
            currentCycleAsync: currentCycleAsync,
            cyclesAsync: cyclesAsync,
          ),
          const SizedBox(height: AppSpacing.md),
          _WinnerHistoryCard(groupId: group.id, cyclesAsync: cyclesAsync),
          const SizedBox(height: AppSpacing.md),
          _MembersCard(
            groupId: group.id,
            isAdmin: isAdmin,
            canInviteMembers: group.canInviteMembers,
            membersAsync: membersAsync,
          ),
          if (isAdmin) ...[
            const SizedBox(height: AppSpacing.md),
            _OverviewAdminActionsCard(
              groupId: group.id,
              hasOpenCycle: currentCycleAsync.valueOrNull != null,
              canInviteMembers: group.canInviteMembers,
              canStartCycle: group.canStartCycle,
            ),
          ],
        ],
      ),
    );
  }
}

class _GroupSummaryCard extends StatelessWidget {
  const _GroupSummaryCard({
    required this.group,
    required this.membersCount,
    required this.currentCycle,
  });

  final GroupModel group;
  final int? membersCount;
  final CycleModel? currentCycle;

  @override
  Widget build(BuildContext context) {
    final roundStatus = switch (currentCycle) {
      null =>
        group.status == GroupStatusModel.archived ? 'Completed' : 'Not started',
      final cycle =>
        cycle.status == CycleStatusModel.closed ? 'Completed' : 'In progress',
    };

    return KitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Group summary',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(
            label: 'Contribution',
            value: formatCurrency(group.contributionAmount, group.currency),
          ),
          _SummaryRow(
            label: 'Frequency',
            value: _frequencyLabel(group.frequency),
          ),
          _SummaryRow(label: 'Members', value: '${membersCount ?? '-'}'),
          const _SummaryRow(label: 'Payout mode', value: LotteryCopy.label),
          _SummaryRow(label: 'Round status', value: roundStatus),
        ],
      ),
    );
  }
}

class _LotterySummaryCard extends StatelessWidget {
  const _LotterySummaryCard({
    required this.groupId,
    required this.membersAsync,
    required this.currentCycleAsync,
    required this.cyclesAsync,
  });

  final String groupId;
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
        message: mapFriendlyError(error ?? 'Unable to load lottery summary.'),
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
      currentCycle: currentCycle,
      cycles: cycles,
    );

    return KitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LotteryCopy.summaryTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(
            label: LotteryCopy.turnsCompletedLabel,
            value: '${summary.turnsCompleted} / ${summary.totalTurns}',
          ),
          _SummaryRow(
            label: LotteryCopy.lastWinnerLabel,
            value: summary.lastWinnerName,
          ),
          _SummaryRow(
            label: LotteryCopy.statusLabel,
            value: summary.roundStatus,
          ),
          if (summary.isCompleted) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              LotteryCopy.completedRoundMessage,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  _LotterySummaryData _buildLotterySummary({
    required int activeMemberCount,
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

    return _LotterySummaryData(
      turnsCompleted: turnsCompleted,
      totalTurns: totalTurns,
      roundStatus: isCompleted
          ? LotteryCopy.statusCompleted
          : LotteryCopy.statusInProgress,
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
    required this.roundStatus,
    required this.isCompleted,
  });

  final int turnsCompleted;
  final int totalTurns;
  final String lastWinnerName;
  final String roundStatus;
  final bool isCompleted;
}

class _WinnerHistoryCard extends ConsumerWidget {
  const _WinnerHistoryCard({required this.groupId, required this.cyclesAsync});

  final String groupId;
  final AsyncValue<List<CycleModel>> cyclesAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KitSectionHeader(title: 'Winner history'),
        cyclesAsync.when(
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
            onRetry: () => ref.invalidate(cyclesListProvider(groupId)),
          ),
          data: (cycles) {
            if (cycles.isEmpty) {
              return const KitEmptyState(
                icon: Icons.emoji_events_outlined,
                title: 'No winners yet',
                message:
                    'Winners will appear here after cycle winner selection.',
              );
            }

            final sortedCycles = [...cycles]
              ..sort((a, b) => b.cycleNo.compareTo(a.cycleNo));
            return KitCard(
              child: Column(
                children: [
                  for (var i = 0; i < sortedCycles.length; i++) ...[
                    _WinnerHistoryRow(cycle: sortedCycles[i]),
                    if (i != sortedCycles.length - 1)
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

class _WinnerHistoryRow extends StatelessWidget {
  const _WinnerHistoryRow({required this.cycle});

  final CycleModel cycle;

  @override
  Widget build(BuildContext context) {
    final statusLabel = switch (cycle.status) {
      CycleStatusModel.open => 'OPEN',
      CycleStatusModel.closed => 'CLOSED',
      CycleStatusModel.unknown => 'UNKNOWN',
    };
    final winnerLabel = _cycleWinnerLabel(cycle);

    return Row(
      children: [
        KitAvatar(name: winnerLabel, size: KitAvatarSize.sm),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(winnerLabel, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Turn ${cycle.cycleNo} • Due ${formatDate(cycle.dueDate)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        StatusPill.fromLabel(statusLabel),
      ],
    );
  }
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KitSectionHeader(title: 'Members'),
        if (isAdmin) ...[
          KitPrimaryButton(
            label: 'Invite members',
            icon: Icons.person_add_alt_1_rounded,
            onPressed: canInviteMembers
                ? () => context.push(AppRoutePaths.groupInvite(groupId))
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
          const SizedBox(height: AppSpacing.sm),
        ],
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
      ],
    );
  }
}

class _OverviewAdminActionsCard extends StatelessWidget {
  const _OverviewAdminActionsCard({
    required this.groupId,
    required this.hasOpenCycle,
    required this.canInviteMembers,
    required this.canStartCycle,
  });

  final String groupId;
  final bool hasOpenCycle;
  final bool canInviteMembers;
  final bool canStartCycle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KitSectionHeader(title: 'Admin actions'),
        KitCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KitSecondaryButton(
                label: 'Invite members',
                icon: Icons.person_add_alt_1_rounded,
                onPressed: canInviteMembers
                    ? () => context.push(AppRoutePaths.groupInvite(groupId))
                    : () => context.push(AppRoutePaths.groupSetup(groupId)),
              ),
              if (!hasOpenCycle) ...[
                const SizedBox(height: AppSpacing.sm),
                KitPrimaryButton(
                  label: canStartCycle
                      ? 'Go to current turn'
                      : 'Complete setup to start',
                  icon: canStartCycle
                      ? Icons.play_arrow_rounded
                      : Icons.rule_folder_outlined,
                  onPressed: canStartCycle
                      ? () => context.push(AppRoutePaths.groupDetail(groupId))
                      : () => context.push(AppRoutePaths.groupSetup(groupId)),
                ),
              ],
            ],
          ),
        ),
      ],
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
          child: Text(
            member.displayName,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        StatusPill.fromLabel(roleLabel),
        if (!isParticipatingMemberStatus(member.status)) ...[
          const SizedBox(width: AppSpacing.xs),
          StatusPill.fromLabel(statusLabel),
        ],
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
