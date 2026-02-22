import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/bootstrap.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/contribution_model.dart';
import '../../../data/models/cycle_model.dart';
import '../../../data/models/group_model.dart';
import '../../../data/models/payout_model.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/ui/ui.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/utils/round_status_mapper.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../auth/auth_controller.dart';
import '../../contributions/cycle_contributions_provider.dart';
import '../../cycles/current_cycle_provider.dart';
import '../../payouts/cycle_payout_provider.dart';
import '../group_detail_controller.dart';
import '../widgets/group_more_actions_button.dart';
import '../../rounds/start_round_controller.dart';
import '../../rounds/current_round_schedule_provider.dart';
import '../../rounds/start_round_flow.dart';

class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupDetailProvider(groupId));
    final group = groupAsync.valueOrNull;
    final isAdmin = group?.membership?.role == MemberRoleModel.admin;
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
      appBar: KitAppBar(
        title: group?.name ?? 'Group detail',
        subtitle: group == null ? null : 'Tap for details',
        onTitleTap: group == null
            ? null
            : () => context.push(AppRoutePaths.groupOverview(groupId)),
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
        data: (group) => _GroupRoundHub(group: group),
      ),
    );
  }
}

class _GroupRoundHub extends ConsumerWidget {
  const _GroupRoundHub({required this.group});

  final GroupModel group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCycleAsync = ref.watch(currentCycleProvider(group.id));
    final isAdmin = group.membership?.role == MemberRoleModel.admin;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(groupDetailControllerProvider).refreshAll(group.id);
        ref.read(cyclesRepositoryProvider).invalidateGroupCache(group.id);
        final refreshedCycle = await ref.refresh(
          currentCycleProvider(group.id).future,
        );
        if (refreshedCycle != null) {
          ref.invalidate(
            cycleContributionsProvider((
              groupId: group.id,
              cycleId: refreshedCycle.id,
            )),
          );
          ref.invalidate(cyclePayoutProvider(refreshedCycle.id));
        }
      },
      child: ListView(
        children: [
          _CurrentRoundCard(
            group: group,
            currentCycleAsync: currentCycleAsync,
            isAdmin: isAdmin,
          ),
          const SizedBox(height: AppSpacing.md),
          _ContributionsSummaryCard(
            groupId: group.id,
            currentCycleAsync: currentCycleAsync,
          ),
          const SizedBox(height: AppSpacing.md),
          _RoundTimelineCard(
            groupId: group.id,
            currentCycleAsync: currentCycleAsync,
          ),
          if (isAdmin) ...[
            const SizedBox(height: AppSpacing.md),
            _AdminActionsCard(
              groupId: group.id,
              currentCycleAsync: currentCycleAsync,
            ),
          ],
        ],
      ),
    );
  }
}

class _CurrentRoundCard extends ConsumerWidget {
  const _CurrentRoundCard({
    required this.group,
    required this.currentCycleAsync,
    required this.isAdmin,
  });

  final GroupModel group;
  final AsyncValue<CycleModel?> currentCycleAsync;
  final bool isAdmin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startRoundState = ref.watch(startRoundControllerProvider(group.id));
    final hasLockedOrder =
        ref
            .watch(currentRoundScheduleProvider(group.id))
            .valueOrNull
            ?.schedule
            .isNotEmpty ==
        true;

    return KitCard(
      child: currentCycleAsync.when(
        loading: () => const _CurrentRoundSkeleton(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(currentCycleProvider(group.id)),
        ),
        data: (cycle) {
          if (cycle == null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current round',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Round not started',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'The first round will appear here once an admin starts it.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                KitPrimaryButton(
                  label: isAdmin
                      ? (hasLockedOrder
                            ? 'Generate next cycle'
                            : (startRoundState.isSubmitting
                                  ? 'Starting round...'
                                  : 'Start round'))
                      : 'Round not started',
                  icon: isAdmin
                      ? (hasLockedOrder
                            ? Icons.add_circle_outline
                            : Icons.play_arrow_rounded)
                      : Icons.hourglass_top,
                  isLoading:
                      isAdmin &&
                      !hasLockedOrder &&
                      startRoundState.isSubmitting,
                  onPressed: isAdmin
                      ? (hasLockedOrder
                            ? () => context.push(
                                AppRoutePaths.groupCyclesGenerate(group.id),
                              )
                            : (startRoundState.isSubmitting
                                  ? null
                                  : () => startFairDrawFlow(
                                      context: context,
                                      ref: ref,
                                      groupId: group.id,
                                      navigateToOverview: true,
                                    )))
                      : null,
                ),
              ],
            );
          }

          return _CurrentRoundLoaded(
            group: group,
            cycle: cycle,
            isAdmin: isAdmin,
          );
        },
      ),
    );
  }
}

class _CurrentRoundLoaded extends ConsumerWidget {
  const _CurrentRoundLoaded({
    required this.group,
    required this.cycle,
    required this.isAdmin,
  });

  final GroupModel group;
  final CycleModel cycle;
  final bool isAdmin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final contributionsAsync = ref.watch(
      cycleContributionsProvider((groupId: group.id, cycleId: cycle.id)),
    );
    final payoutAsync = ref.watch(cyclePayoutProvider(cycle.id));
    final summary = contributionsAsync.valueOrNull?.summary;
    final payout = payoutAsync.valueOrNull;
    final status = mapRoundStatus(
      cycle: cycle,
      contributionSummary: summary,
      payout: payout,
    );
    final primaryAction = _resolvePrimaryAction(
      context: context,
      groupId: group.id,
      cycle: cycle,
      isAdmin: isAdmin,
      currentUserId: currentUser?.id,
      payout: payout,
      contributions: contributionsAsync.valueOrNull,
    );
    final scheduledRecipient = _cycleUserLabel(
      cycle.scheduledPayoutUser,
      cycle.scheduledPayoutUserId ?? cycle.payoutUserId,
    );
    final finalRecipient = _cycleUserLabel(
      cycle.finalPayoutUser,
      cycle.finalPayoutUserId ?? cycle.payoutUserId,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Current round',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            StatusPill.fromLabel(status.label),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Cycle #${cycle.cycleNo}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Due ${formatDate(cycle.dueDate)}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Scheduled recipient: $scheduledRecipient',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (finalRecipient != scheduledRecipient) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Final recipient: $finalRecipient',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        KitPrimaryButton(
          label: primaryAction.label,
          icon: primaryAction.icon,
          onPressed: primaryAction.onPressed,
        ),
      ],
    );
  }
}

class _ContributionsSummaryCard extends ConsumerWidget {
  const _ContributionsSummaryCard({
    required this.groupId,
    required this.currentCycleAsync,
  });

  final String groupId;
  final AsyncValue<CycleModel?> currentCycleAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return KitCard(
      child: currentCycleAsync.when(
        loading: () => const _SummarySkeleton(title: 'Contributions'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(currentCycleProvider(groupId)),
        ),
        data: (cycle) {
          if (cycle == null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contributions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'No active round yet.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            );
          }

          final contributionsAsync = ref.watch(
            cycleContributionsProvider((groupId: groupId, cycleId: cycle.id)),
          );

          return contributionsAsync.when(
            loading: () => const _SummarySkeleton(title: 'Contributions'),
            error: (error, _) => ErrorView(
              message: error.toString(),
              onRetry: () => ref.invalidate(
                cycleContributionsProvider((
                  groupId: groupId,
                  cycleId: cycle.id,
                )),
              ),
            ),
            data: (list) {
              final paid = list.summary.submitted + list.summary.confirmed;
              final total = list.summary.total;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contributions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Paid: $paid / $total',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${list.summary.confirmed} confirmed, ${list.summary.rejected} rejected',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  KitSecondaryButton(
                    label: 'View contributions',
                    icon: Icons.receipt_long_outlined,
                    onPressed: () => context.push(
                      AppRoutePaths.groupCycleContributions(groupId, cycle.id),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _RoundTimelineCard extends ConsumerWidget {
  const _RoundTimelineCard({
    required this.groupId,
    required this.currentCycleAsync,
  });

  final String groupId;
  final AsyncValue<CycleModel?> currentCycleAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cycle = currentCycleAsync.valueOrNull;
    final contributionSummary = cycle == null
        ? null
        : ref
              .watch(
                cycleContributionsProvider((
                  groupId: groupId,
                  cycleId: cycle.id,
                )),
              )
              .valueOrNull
              ?.summary;
    final payout = cycle == null
        ? null
        : ref.watch(cyclePayoutProvider(cycle.id)).valueOrNull;
    final status = mapRoundStatus(
      cycle: cycle,
      contributionSummary: contributionSummary,
      payout: payout,
    );
    final currentIndex = switch (status.stage) {
      RoundStage.contributions => 0,
      RoundStage.auction => 1,
      RoundStage.payout => 2,
      RoundStage.closed => 3,
    };
    const labels = ['Contributions', 'Auction', 'Payout', 'Closed'];

    return KitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Round timeline',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < labels.length; i++) ...[
                  _TimelineNode(
                    label: labels[i],
                    isActive: i == currentIndex,
                    isComplete: i < currentIndex,
                  ),
                  if (i != labels.length - 1)
                    Container(
                      width: AppSpacing.lg,
                      height: 1,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminActionsCard extends ConsumerWidget {
  const _AdminActionsCard({
    required this.groupId,
    required this.currentCycleAsync,
  });

  final String groupId;
  final AsyncValue<CycleModel?> currentCycleAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cycle = currentCycleAsync.valueOrNull;
    final payout = cycle == null
        ? null
        : ref.watch(cyclePayoutProvider(cycle.id)).valueOrNull;

    return KitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admin actions',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Actions are grouped to keep this screen focused for members.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          KitSecondaryButton(
            label: 'Open admin actions',
            icon: Icons.admin_panel_settings_outlined,
            onPressed: () => _showAdminActions(
              context: context,
              groupId: groupId,
              cycle: cycle,
              payout: payout,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineNode extends StatelessWidget {
  const _TimelineNode({
    required this.label,
    required this.isActive,
    required this.isComplete,
  });

  final String label;
  final bool isActive;
  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = isComplete || isActive
        ? colorScheme.primary
        : colorScheme.surfaceContainerLow;
    final foregroundColor = isComplete || isActive
        ? colorScheme.onPrimary
        : colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.pillRounded,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CurrentRoundSkeleton extends StatelessWidget {
  const _CurrentRoundSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KitSkeletonBox(height: AppSpacing.lg, width: 170),
        SizedBox(height: AppSpacing.sm),
        KitSkeletonBox(height: AppSpacing.xl, width: 140),
        SizedBox(height: AppSpacing.xs),
        KitSkeletonBox(height: AppSpacing.md, width: 220),
        SizedBox(height: AppSpacing.xs),
        KitSkeletonBox(height: AppSpacing.md, width: 260),
        SizedBox(height: AppSpacing.md),
        KitSkeletonBox(height: 46, width: 240),
      ],
    );
  }
}

class _SummarySkeleton extends StatelessWidget {
  const _SummarySkeleton({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.sm),
        const KitSkeletonBox(height: AppSpacing.xl, width: 120),
        const SizedBox(height: AppSpacing.xs),
        const KitSkeletonBox(height: AppSpacing.md, width: 220),
      ],
    );
  }
}

class _PrimaryAction {
  const _PrimaryAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
}

_PrimaryAction _resolvePrimaryAction({
  required BuildContext context,
  required String groupId,
  required CycleModel cycle,
  required bool isAdmin,
  required String? currentUserId,
  required PayoutModel? payout,
  required ContributionListModel? contributions,
}) {
  final cycleDetailRoute = AppRoutePaths.groupCycleDetail(groupId, cycle.id);
  final submitRoute = AppRoutePaths.groupCycleContributionsSubmit(
    groupId,
    cycle.id,
  );
  final payoutRoute = AppRoutePaths.groupCyclePayout(groupId, cycle.id);
  final auctionStatus = cycle.auctionStatus ?? AuctionStatusModel.none;
  final scheduledUserId = cycle.scheduledPayoutUserId ?? cycle.payoutUserId;
  final isScheduledRecipient =
      currentUserId != null && currentUserId == scheduledUserId;
  final canManageAuction = isAdmin || isScheduledRecipient;

  if (isAdmin && payout?.status == PayoutStatusModel.pending) {
    return _PrimaryAction(
      label: 'Manage payout',
      icon: Icons.account_balance_wallet_outlined,
      onPressed: () => context.push(payoutRoute),
    );
  }

  if (auctionStatus == AuctionStatusModel.open) {
    if (canManageAuction) {
      return _PrimaryAction(
        label: 'Close auction',
        icon: Icons.gavel_rounded,
        onPressed: () => context.push(cycleDetailRoute),
      );
    }
    return _PrimaryAction(
      label: 'Place bid',
      icon: Icons.local_offer_outlined,
      onPressed: () => context.push(cycleDetailRoute),
    );
  }

  if (isScheduledRecipient && auctionStatus != AuctionStatusModel.open) {
    return _PrimaryAction(
      label: 'Auction my turn',
      icon: Icons.gavel_rounded,
      onPressed: () => context.push(cycleDetailRoute),
    );
  }

  ContributionStatusModel? myStatus;
  if (currentUserId != null && contributions != null) {
    for (final item in contributions.items) {
      if (item.userId == currentUserId) {
        myStatus = item.status;
        break;
      }
    }
  }

  if (myStatus == ContributionStatusModel.rejected) {
    return _PrimaryAction(
      label: 'Fix & resubmit',
      icon: Icons.refresh_rounded,
      onPressed: () => context.push(submitRoute),
    );
  }
  if (myStatus == ContributionStatusModel.submitted ||
      myStatus == ContributionStatusModel.pending) {
    return const _PrimaryAction(
      label: 'Waiting confirmation',
      icon: Icons.hourglass_bottom_rounded,
      onPressed: null,
    );
  }
  if (myStatus == null || myStatus == ContributionStatusModel.unknown) {
    return _PrimaryAction(
      label: 'Submit contribution',
      icon: Icons.upload_file_outlined,
      onPressed: () => context.push(submitRoute),
    );
  }

  return _PrimaryAction(
    label: 'View current round',
    icon: Icons.visibility_outlined,
    onPressed: () => context.push(cycleDetailRoute),
  );
}

Future<void> _showAdminActions({
  required BuildContext context,
  required String groupId,
  required CycleModel? cycle,
  required PayoutModel? payout,
}) {
  final actions = <KitActionSheetItem>[
    KitActionSheetItem(
      label: 'Invite members',
      icon: Icons.person_add_alt_1_rounded,
      onPressed: () => context.push(AppRoutePaths.groupInvite(groupId)),
    ),
    if (cycle == null)
      KitActionSheetItem(
        label: 'Generate next cycle',
        icon: Icons.add_circle_outline,
        onPressed: () =>
            context.push(AppRoutePaths.groupCyclesGenerate(groupId)),
      ),
    if (cycle != null &&
        (cycle.auctionStatus ?? AuctionStatusModel.none) ==
            AuctionStatusModel.open)
      KitActionSheetItem(
        label: 'View bids / Close auction',
        icon: Icons.gavel_rounded,
        onPressed: () =>
            context.push(AppRoutePaths.groupCycleDetail(groupId, cycle.id)),
      ),
    if (cycle != null)
      KitActionSheetItem(
        label: 'Create / Confirm payout',
        icon: Icons.account_balance_wallet_outlined,
        onPressed: () =>
            context.push(AppRoutePaths.groupCyclePayout(groupId, cycle.id)),
      ),
    if (cycle != null && payout?.status == PayoutStatusModel.confirmed)
      KitActionSheetItem(
        label: 'Close cycle',
        icon: Icons.task_alt_rounded,
        onPressed: () =>
            context.push(AppRoutePaths.groupCyclePayout(groupId, cycle.id)),
      ),
  ];

  return KitActionSheet.show(
    context: context,
    title: 'Admin actions',
    actions: actions,
  );
}

String _cycleUserLabel(CyclePayoutUserModel? user, String fallbackUserId) {
  final fullName = user?.fullName?.trim();
  if (fullName != null && fullName.isNotEmpty) {
    return fullName;
  }
  final phone = user?.phone?.trim();
  if (phone != null && phone.isNotEmpty) {
    return phone;
  }
  return fallbackUserId;
}
