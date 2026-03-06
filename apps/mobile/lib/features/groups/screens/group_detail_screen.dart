import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/bootstrap.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme_extensions.dart';
import '../../../data/models/contribution_model.dart';
import '../../../data/models/cycle_model.dart';
import '../../../data/models/group_model.dart';
import '../../../data/models/payout_model.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/utils/turn_status_mapper.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../auth/auth_controller.dart';
import '../../contributions/cycle_contributions_provider.dart';
import '../../cycles/current_cycle_provider.dart';
import '../../cycles/cycles_list_provider.dart';
import '../../cycles/start_cycle_controller.dart';
import '../../payouts/cycle_payout_provider.dart';
import '../group_detail_controller.dart';
import '../widgets/group_more_actions_button.dart';

class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupDetailProvider(groupId));
    final group = groupAsync.valueOrNull;
    final isAdmin = group?.membership?.role == MemberRoleModel.admin;

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
          message: mapFriendlyError(error),
          onRetry: () =>
              ref.read(groupDetailControllerProvider).refreshAll(groupId),
        ),
        data: (group) => _GroupTurnOverview(group: group),
      ),
    );
  }
}

class _GroupTurnOverview extends ConsumerWidget {
  const _GroupTurnOverview({required this.group});

  final GroupModel group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCycleAsync = ref.watch(currentCycleProvider(group.id));
    final cyclesAsync = ref.watch(cyclesListProvider(group.id));

    Future<void> onRefresh() async {
      await ref.read(groupDetailControllerProvider).refreshAll(group.id);
      ref.read(cyclesRepositoryProvider).invalidateGroupCache(group.id);
      ref.invalidate(currentCycleProvider(group.id));
      ref.invalidate(cyclesListProvider(group.id));

      final current = await ref.read(currentCycleProvider(group.id).future);
      await ref.read(cyclesListProvider(group.id).future);
      if (current != null) {
        ref.invalidate(
          cycleContributionsProvider((groupId: group.id, cycleId: current.id)),
        );
        ref.invalidate(cyclePayoutProvider(current.id));
      }
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        children: [
          _CurrentTurnHeroCard(group: group, currentCycleAsync: currentCycleAsync),
          const SizedBox(height: AppSpacing.lg),
          _PastTurnsSection(
            groupId: group.id,
            currentCycleAsync: currentCycleAsync,
            cyclesAsync: cyclesAsync,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _CurrentTurnHeroCard extends ConsumerWidget {
  const _CurrentTurnHeroCard({
    required this.group,
    required this.currentCycleAsync,
  });

  final GroupModel group;
  final AsyncValue<CycleModel?> currentCycleAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(currentUserProvider)?.id;

    return currentCycleAsync.when(
      loading: () => const KitCard(child: _HeroSkeleton()),
      error: (error, _) => KitCard(
        child: ErrorView(
          message: mapFriendlyError(error),
          onRetry: () => ref.invalidate(currentCycleProvider(group.id)),
        ),
      ),
      data: (cycle) {
        if (cycle == null) {
          return _NoCurrentTurnHeroCard(group: group);
        }

        final contributionsAsync = ref.watch(
          cycleContributionsProvider((groupId: group.id, cycleId: cycle.id)),
        );
        final payoutAsync = ref.watch(cyclePayoutProvider(cycle.id));
        final contributionList = contributionsAsync.valueOrNull;
        final summary = contributionList?.summary;
        final payout = payoutAsync.valueOrNull;
        final myContribution = _findContribution(contributionList, currentUserId);
        final status = mapTurnStatus(
          cycle: cycle,
          contributionSummary: summary,
          payout: payout,
        );
        final actions = _resolveVisibleActions(
          context: context,
          group: group,
          cycle: cycle,
          contribution: myContribution,
          payout: payout,
          summary: summary,
        );
        final paid = _paidCount(summary);
        final total = summary?.total ?? 0;
        final potSize = _turnPotSize(
          contributions: contributionList,
          fallbackAmount: group.contributionAmount,
          totalMembers: total,
        );
        final hasAuction =
            (cycle.auctionStatus ?? AuctionStatusModel.none) !=
            AuctionStatusModel.none;
        final hasLate = (summary?.late ?? 0) > 0;

        return KitCard(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [context.brand.heroTop, context.brand.heroBottom],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.cardRounded,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Turn ${cycle.cycleNo}',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      _buildStagePill(status),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Due ${formatDate(cycle.dueDate)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _winnerCopy(cycle, payout),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Pot size: ${formatCurrency(potSize, group.currency)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (hasAuction || hasLate) ...[
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        if (hasAuction)
                          const StatusPill(
                            label: 'Auction',
                            tone: KitBadgeTone.info,
                          ),
                        if (hasLate)
                          const StatusPill(
                            label: 'Late',
                            tone: KitBadgeTone.warning,
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  Divider(color: Theme.of(context).colorScheme.outlineVariant),
                  const SizedBox(height: AppSpacing.md),
                  KitPrimaryButton(
                    onPressed: actions.primary.onPressed,
                    label: actions.primary.label,
                    icon: actions.primary.icon,
                  ),
                  if (actions.secondary.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final action in actions.secondary)
                          KitSecondaryButton(
                            onPressed: action.onPressed,
                            label: action.label,
                            icon: action.icon,
                            expand: false,
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  Divider(color: Theme.of(context).colorScheme.outlineVariant),
                  const SizedBox(height: AppSpacing.md),
                  _ProgressSummaryBar(paid: paid, total: total),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.xs,
                    children: [
                      _InlineMetric(label: 'Paid', value: '$paid / $total'),
                      _InlineMetric(
                        label: 'Verified',
                        value: '${(summary?.verified ?? 0) + (summary?.confirmed ?? 0)}',
                      ),
                      _InlineMetric(
                        label: 'Pending',
                        value:
                            '${(summary?.pending ?? 0) + (summary?.submitted ?? 0) + (summary?.paidSubmitted ?? 0)}',
                      ),
                      _InlineMetric(
                        label: 'Late',
                        value: '${summary?.late ?? 0}',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  KitTertiaryButton(
                    onPressed: () => context.push(
                      AppRoutePaths.groupTurnDetail(group.id, cycle.id),
                    ),
                    label: 'See turn details',
                    icon: Icons.chevron_right_rounded,
                    expand: false,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PastTurnsSection extends StatelessWidget {
  const _PastTurnsSection({
    required this.groupId,
    required this.currentCycleAsync,
    required this.cyclesAsync,
  });

  final String groupId;
  final AsyncValue<CycleModel?> currentCycleAsync;
  final AsyncValue<List<CycleModel>> cyclesAsync;

  @override
  Widget build(BuildContext context) {
    final currentCycleId = currentCycleAsync.valueOrNull?.id;

    return cyclesAsync.when(
      loading: () => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KitSectionHeader(title: 'Past Turns'),
          KitCard(
            child: SizedBox(height: 220, child: KitSkeletonList(itemCount: 3)),
          ),
        ],
      ),
      error: (error, _) => KitCard(
        child: Text(
          mapFriendlyError(error),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      data: (cycles) {
        final pastTurns = cycles
            .where((cycle) => cycle.id != currentCycleId)
            .toList(growable: false)
          ..sort((a, b) => b.cycleNo.compareTo(a.cycleNo));

        if (pastTurns.isEmpty) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KitSectionHeader(title: 'Past Turns'),
              Padding(
                padding: EdgeInsets.only(top: AppSpacing.xs),
                child: Text('No past turns yet'),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const KitSectionHeader(
              title: 'Past Turns',
              subtitle: 'Recent history for this group',
            ),
            KitCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var index = 0; index < pastTurns.length; index++) ...[
                    _PastTurnRow(groupId: groupId, cycle: pastTurns[index]),
                    if (index != pastTurns.length - 1)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PastTurnRow extends ConsumerWidget {
  const _PastTurnRow({required this.groupId, required this.cycle});

  final String groupId;
  final CycleModel cycle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contributionsAsync = ref.watch(
      cycleContributionsProvider((groupId: groupId, cycleId: cycle.id)),
    );
    final payoutAsync = ref.watch(cyclePayoutProvider(cycle.id));
    final status = mapTurnStatus(
      cycle: cycle,
      contributionSummary: contributionsAsync.valueOrNull?.summary,
      payout: payoutAsync.valueOrNull,
    );
    final winnerLabel = _turnWinnerLabel(cycle, payoutAsync.valueOrNull);
    final hasLate = (contributionsAsync.valueOrNull?.summary.late ?? 0) > 0;
    final hasAuction =
        (cycle.auctionStatus ?? AuctionStatusModel.none) !=
        AuctionStatusModel.none;

    return InkWell(
      onTap: () => context.push(AppRoutePaths.groupTurnDetail(groupId, cycle.id)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Turn ${cycle.cycleNo}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _buildStagePill(status),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    winnerLabel == null ? 'Winner pending' : 'Winner: $winnerLabel',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (hasAuction || hasLate) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        if (hasAuction) const _MiniIndicator(label: 'Auction'),
                        if (hasLate) const _MiniIndicator(label: 'Late'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _NoCurrentTurnHeroCard extends ConsumerStatefulWidget {
  const _NoCurrentTurnHeroCard({required this.group});

  final GroupModel group;

  @override
  ConsumerState<_NoCurrentTurnHeroCard> createState() =>
      _NoCurrentTurnHeroCardState();
}

class _NoCurrentTurnHeroCardState extends ConsumerState<_NoCurrentTurnHeroCard> {
  bool _isStarting = false;

  Future<void> _startTurn() async {
    if (_isStarting) {
      return;
    }

    setState(() => _isStarting = true);
    final created = await ref
        .read(startCycleControllerProvider(widget.group.id).notifier)
        .startCycle();
    if (!mounted) {
      return;
    }

    setState(() => _isStarting = false);
    if (created == null) {
      final message =
          ref.read(startCycleControllerProvider(widget.group.id)).errorMessage ??
          'Could not start a turn right now.';
      KitToast.error(context, message);
      return;
    }

    ref.read(cyclesRepositoryProvider).invalidateGroupCache(widget.group.id);
    ref.invalidate(currentCycleProvider(widget.group.id));
    ref.invalidate(cyclesListProvider(widget.group.id));
    KitToast.success(context, 'Turn started. Contributions are now due.');
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.group.membership?.role == MemberRoleModel.admin;

    return KitCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAdmin ? 'No active turn yet' : 'No active turn right now',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isAdmin
                  ? 'Start the next turn when the group is ready.'
                  : 'Check back after an admin starts the next turn.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            KitPrimaryButton(
              onPressed: !isAdmin
                  ? null
                  : widget.group.canStartCycle
                  ? _startTurn
                  : () => context.push(AppRoutePaths.groupSetup(widget.group.id)),
              label: !isAdmin
                  ? 'Waiting for admin start'
                  : widget.group.canStartCycle
                  ? (_isStarting ? 'Starting turn...' : 'Start turn')
                  : 'Complete setup to start',
              icon: !isAdmin
                  ? Icons.hourglass_top_rounded
                  : widget.group.canStartCycle
                  ? Icons.play_arrow_rounded
                  : Icons.rule_folder_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KitSkeletonBox(height: 28, width: 150),
          SizedBox(height: AppSpacing.sm),
          KitSkeletonBox(height: 20, width: 120),
          SizedBox(height: AppSpacing.sm),
          KitSkeletonBox(height: 22, width: 240),
          SizedBox(height: AppSpacing.md),
          KitSkeletonBox(height: 46, width: 220),
          SizedBox(height: AppSpacing.md),
          KitSkeletonBox(height: 8, width: double.infinity),
          SizedBox(height: AppSpacing.md),
          KitSkeletonBox(height: 18, width: 260),
        ],
      ),
    );
  }
}

class _InlineMetric extends StatelessWidget {
  const _InlineMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label: $value',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _MiniIndicator extends StatelessWidget {
  const _MiniIndicator({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return StatusPill(label: label, tone: KitBadgeTone.info);
  }
}

class _ProgressSummaryBar extends StatelessWidget {
  const _ProgressSummaryBar({required this.paid, required this.total});

  final int paid;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : (paid / total).clamp(0, 1).toDouble();
    return ClipRRect(
      borderRadius: AppRadius.pillRounded,
      child: LinearProgressIndicator(value: progress, minHeight: 10),
    );
  }
}

class _VisibleActions {
  const _VisibleActions({required this.primary, required this.secondary});

  final _TurnAction primary;
  final List<_TurnAction> secondary;
}

class _TurnAction {
  const _TurnAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
}

_VisibleActions _resolveVisibleActions({
  required BuildContext context,
  required GroupModel group,
  required CycleModel cycle,
  required ContributionModel? contribution,
  required PayoutModel? payout,
  required ContributionSummaryModel? summary,
}) {
  final turnRoute = AppRoutePaths.groupTurnDetail(group.id, cycle.id);
  final submitRoute =
      AppRoutePaths.groupCycleContributionsSubmit(group.id, cycle.id);
  final payoutRoute = AppRoutePaths.groupCyclePayout(group.id, cycle.id);
  final contributionsRoute =
      AppRoutePaths.groupCycleContributions(group.id, cycle.id);
  final isAdmin = group.membership?.role == MemberRoleModel.admin;
  final secondary = <_TurnAction>[];

  if ((cycle.auctionStatus ?? AuctionStatusModel.none) == AuctionStatusModel.open) {
    final primary = _TurnAction(
      label: isAdmin ? 'Close auction' : 'Place bid',
      icon: Icons.gavel_rounded,
      onPressed: () => context.push(turnRoute),
    );
    if (isAdmin && (summary?.late ?? 0) > 0) {
      secondary.add(
        _TurnAction(
          label: 'Verify payments',
          icon: Icons.fact_check_outlined,
          onPressed: () => context.push(contributionsRoute),
        ),
      );
    }
    return _VisibleActions(primary: primary, secondary: secondary);
  }

  if (isAdmin && cycle.state == CycleStateModel.readyForPayout) {
    final primary = _TurnAction(
      label: 'Draw winner',
      icon: Icons.emoji_events_outlined,
      onPressed: () => context.push(turnRoute),
    );
    secondary.add(
      _TurnAction(
        label: 'Verify payments',
        icon: Icons.fact_check_outlined,
        onPressed: () => context.push(contributionsRoute),
      ),
    );
    return _VisibleActions(primary: primary, secondary: secondary);
  }

  if (isAdmin && payout?.status == PayoutStatusModel.pending) {
    final primary = _TurnAction(
      label: 'Disburse payout',
      icon: Icons.account_balance_wallet_outlined,
      onPressed: () => context.push(payoutRoute),
    );
    secondary.add(
      _TurnAction(
        label: 'Close turn',
        icon: Icons.task_alt_rounded,
        onPressed: () => context.push(payoutRoute),
      ),
    );
    return _VisibleActions(primary: primary, secondary: secondary);
  }

  if (contribution == null) {
    return _VisibleActions(
      primary: _TurnAction(
        label: 'Pay now',
        icon: Icons.upload_file_outlined,
        onPressed: () => context.push(submitRoute),
      ),
      secondary: secondary,
    );
  }

  switch (contribution.status) {
    case ContributionStatusModel.rejected:
      return _VisibleActions(
        primary: _TurnAction(
          label: 'Fix & resubmit',
          icon: Icons.refresh_rounded,
          onPressed: () => context.push(submitRoute),
        ),
        secondary: secondary,
      );
    case ContributionStatusModel.late:
      return _VisibleActions(
        primary: _TurnAction(
          label: 'Pay now',
          icon: Icons.warning_amber_rounded,
          onPressed: () => context.push(submitRoute),
        ),
        secondary: secondary,
      );
    case ContributionStatusModel.pending:
      return _VisibleActions(
        primary: _TurnAction(
          label: 'Upload receipt',
          icon: Icons.upload_file_outlined,
          onPressed: () => context.push(submitRoute),
        ),
        secondary: secondary,
      );
    case ContributionStatusModel.paidSubmitted:
    case ContributionStatusModel.submitted:
      if (isAdmin) {
        secondary.add(
          _TurnAction(
            label: 'See turn details',
            icon: Icons.visibility_outlined,
            onPressed: () => context.push(turnRoute),
          ),
        );
        return _VisibleActions(
          primary: _TurnAction(
            label: 'Verify payments',
            icon: Icons.fact_check_outlined,
            onPressed: () => context.push(contributionsRoute),
          ),
          secondary: secondary,
        );
      }
      return const _VisibleActions(
        primary: _TurnAction(
          label: 'Waiting for verification',
          icon: Icons.hourglass_bottom_rounded,
          onPressed: null,
        ),
        secondary: <_TurnAction>[],
      );
    case ContributionStatusModel.verified:
    case ContributionStatusModel.confirmed:
      if (isAdmin) {
        return _VisibleActions(
          primary: _TurnAction(
            label: 'Verify payments',
            icon: Icons.fact_check_outlined,
            onPressed: () => context.push(contributionsRoute),
          ),
          secondary: secondary,
        );
      }
      return _VisibleActions(
        primary: _TurnAction(
          label: 'See turn details',
          icon: Icons.visibility_outlined,
          onPressed: () => context.push(turnRoute),
        ),
        secondary: secondary,
      );
    case ContributionStatusModel.unknown:
      return _VisibleActions(
        primary: _TurnAction(
          label: 'See turn details',
          icon: Icons.visibility_outlined,
          onPressed: () => context.push(turnRoute),
        ),
        secondary: secondary,
      );
  }
}

ContributionModel? _findContribution(
  ContributionListModel? list,
  String? currentUserId,
) {
  if (list == null || currentUserId == null) {
    return null;
  }

  for (final item in list.items) {
    if (item.userId == currentUserId) {
      return item;
    }
  }

  return null;
}

StatusPill _buildStagePill(TurnStatusPresentation status) {
  final tone = switch (status.stage) {
    TurnStage.waiting => KitBadgeTone.warning,
    TurnStage.collecting => KitBadgeTone.info,
    TurnStage.auction => KitBadgeTone.info,
    TurnStage.readyForPayout => KitBadgeTone.warning,
    TurnStage.disbursed => KitBadgeTone.success,
    TurnStage.completed => KitBadgeTone.success,
  };
  return StatusPill(label: status.label, tone: tone);
}

String? _turnWinnerLabel(CycleModel cycle, PayoutModel? payout) {
  final payoutLabel = payout?.recipientLabel.trim();
  if (payoutLabel != null && payoutLabel.isNotEmpty) {
    return payoutLabel;
  }

  final user =
      cycle.finalPayoutUser ?? cycle.payoutUser ?? cycle.scheduledPayoutUser;
  final fullName = user?.fullName?.trim();
  if (fullName != null && fullName.isNotEmpty) {
    return fullName;
  }

  final phone = user?.phone?.trim();
  if (phone != null && phone.isNotEmpty) {
    return phone;
  }

  final fallbackId = cycle.finalPayoutUserId ?? cycle.payoutUserId;
  return fallbackId.trim().isEmpty ? null : fallbackId;
}

String _winnerCopy(CycleModel cycle, PayoutModel? payout) {
  final winnerLabel = _turnWinnerLabel(cycle, payout);
  if (winnerLabel != null) {
    return 'This turn\'s winner: $winnerLabel';
  }
  return _winnerPendingCopy(cycle);
}

String _winnerPendingCopy(CycleModel cycle) {
  final auctionStatus = cycle.auctionStatus ?? AuctionStatusModel.none;
  if (auctionStatus == AuctionStatusModel.open) {
    return 'Winner is pending while the auction is still open.';
  }
  if (cycle.state == CycleStateModel.readyForPayout) {
    return 'Winner is ready to be confirmed for payout.';
  }
  return 'Winner selection will appear here once this turn progresses.';
}

int _paidCount(ContributionSummaryModel? summary) {
  if (summary == null) {
    return 0;
  }
  return summary.submitted +
      summary.paidSubmitted +
      summary.verified +
      summary.confirmed;
}

int _turnPotSize({
  required ContributionListModel? contributions,
  required int fallbackAmount,
  required int totalMembers,
}) {
  final items = contributions?.items ?? const <ContributionModel>[];
  if (items.isNotEmpty) {
    return items.fold<int>(0, (sum, item) => sum + item.amount);
  }
  return fallbackAmount * totalMembers;
}
