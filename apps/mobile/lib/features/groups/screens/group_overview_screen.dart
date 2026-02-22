import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/bootstrap.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/cycle_model.dart';
import '../../../data/models/group_model.dart';
import '../../../data/models/member_model.dart';
import '../../../shared/copy/fair_draw_copy.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/ui/ui.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../cycles/current_cycle_provider.dart';
import '../group_detail_controller.dart';
import '../../rounds/current_round_schedule_provider.dart';
import '../../rounds/round_draw_reveal_state.dart';
import '../../rounds/start_round_controller.dart';
import '../../rounds/start_round_flow.dart';
import '../../rounds/widgets/round_order_card.dart';

class GroupOverviewScreen extends ConsumerWidget {
  const GroupOverviewScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupDetailProvider(groupId));
    final group = groupAsync.valueOrNull;
    ref.listen(startRoundControllerProvider(groupId), (previous, next) {
      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;
      if (nextError != null &&
          nextError.isNotEmpty &&
          previousError != nextError) {
        AppSnackbars.error(context, nextError);
      }
    });

    return KitScaffold(
      appBar: KitAppBar(title: group?.name ?? 'Group overview'),
      child: groupAsync.when(
        loading: () => const LoadingView(message: 'Loading group...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () =>
              ref.read(groupDetailControllerProvider).refreshAll(groupId),
        ),
        data: (group) => _GroupOverviewBody(group: group),
      ),
    );
  }
}

class _GroupOverviewBody extends ConsumerStatefulWidget {
  const _GroupOverviewBody({required this.group});

  final GroupModel group;

  @override
  ConsumerState<_GroupOverviewBody> createState() => _GroupOverviewBodyState();
}

class _GroupOverviewBodyState extends ConsumerState<_GroupOverviewBody> {
  final _roundOrderKey = GlobalKey();
  var _didAutoScrollForReveal = false;

  void _scrollToRoundOrderIfNeeded(bool shouldAutoPlay) {
    if (!shouldAutoPlay) {
      _didAutoScrollForReveal = false;
      return;
    }
    if (_didAutoScrollForReveal) {
      return;
    }
    _didAutoScrollForReveal = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetContext = _roundOrderKey.currentContext;
      if (targetContext == null || !mounted) {
        return;
      }

      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        alignment: 0.08,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final membersAsync = ref.watch(groupMembersProvider(group.id));
    final currentCycleAsync = ref.watch(currentCycleProvider(group.id));
    final shouldAutoPlay = ref.watch(roundJustStartedProvider(group.id));
    final isAdmin = group.membership?.role == MemberRoleModel.admin;
    _scrollToRoundOrderIfNeeded(shouldAutoPlay);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(groupDetailControllerProvider).refreshAll(group.id);
        ref.read(cyclesRepositoryProvider).invalidateGroupCache(group.id);
        ref.invalidate(currentCycleProvider(group.id));
        ref.invalidate(currentRoundScheduleProvider(group.id));
      },
      child: ListView(
        children: [
          _GroupSummaryCard(
            group: group,
            membersCount: membersAsync.valueOrNull?.length,
            currentCycle: currentCycleAsync.valueOrNull,
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            key: _roundOrderKey,
            child: RoundOrderCard(groupId: group.id),
          ),
          const SizedBox(height: AppSpacing.md),
          _MembersCard(
            groupId: group.id,
            isAdmin: isAdmin,
            membersAsync: membersAsync,
          ),
          if (isAdmin) ...[
            const SizedBox(height: AppSpacing.md),
            _OverviewAdminActionsCard(
              groupId: group.id,
              hasOpenCycle: currentCycleAsync.valueOrNull != null,
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
        cycle.status == CycleStatusModel.closed ? 'Completed' : 'Active',
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
          const _SummaryRow(label: 'Payout mode', value: FairDrawCopy.label),
          _SummaryRow(label: 'Round status', value: roundStatus),
        ],
      ),
    );
  }
}

class _MembersCard extends ConsumerWidget {
  const _MembersCard({
    required this.groupId,
    required this.isAdmin,
    required this.membersAsync,
  });

  final String groupId;
  final bool isAdmin;
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
            onPressed: () => context.push(AppRoutePaths.groupInvite(groupId)),
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

class _OverviewAdminActionsCard extends ConsumerWidget {
  const _OverviewAdminActionsCard({
    required this.groupId,
    required this.hasOpenCycle,
  });

  final String groupId;
  final bool hasOpenCycle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startRoundState = ref.watch(startRoundControllerProvider(groupId));
    final hasLockedOrder =
        ref
            .watch(currentRoundScheduleProvider(groupId))
            .valueOrNull
            ?.schedule
            .isNotEmpty ==
        true;

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
                onPressed: () =>
                    context.push(AppRoutePaths.groupInvite(groupId)),
              ),
              if (!hasOpenCycle && !hasLockedOrder) ...[
                const SizedBox(height: AppSpacing.sm),
                KitPrimaryButton(
                  label: startRoundState.isSubmitting
                      ? 'Starting round...'
                      : 'Start round',
                  icon: Icons.play_arrow_rounded,
                  isLoading: startRoundState.isSubmitting,
                  onPressed: startRoundState.isSubmitting
                      ? null
                      : () => startFairDrawFlow(
                          context: context,
                          ref: ref,
                          groupId: groupId,
                          navigateToOverview: false,
                        ),
                ),
              ],
              if (!hasOpenCycle) ...[
                const SizedBox(height: AppSpacing.sm),
                KitSecondaryButton(
                  label: 'Generate next cycle',
                  icon: Icons.add_circle_outline,
                  onPressed: () =>
                      context.push(AppRoutePaths.groupCyclesGenerate(groupId)),
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
      MemberStatusModel.active => 'ACTIVE',
      MemberStatusModel.invited => 'INVITED',
      MemberStatusModel.left => 'LEFT',
      MemberStatusModel.removed => 'REMOVED',
      MemberStatusModel.unknown => 'UNKNOWN',
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
        if (member.status != MemberStatusModel.active) ...[
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
