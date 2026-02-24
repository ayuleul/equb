import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/bootstrap.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/contribution_model.dart';
import '../../../data/models/cycle_model.dart';
import '../../../data/models/group_model.dart';
import '../../../data/models/group_rules_model.dart';
import '../../../data/models/payout_model.dart';
import '../../../shared/copy/lottery_copy.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/ui/ui.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/utils/round_status_mapper.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../auth/auth_controller.dart';
import '../../contributions/cycle_contributions_provider.dart';
import '../../cycles/current_cycle_provider.dart';
import '../../cycles/cycles_list_provider.dart';
import '../../cycles/generate_cycle_controller.dart';
import '../../payouts/cycle_payout_provider.dart';
import '../../rounds/widgets/lottery_reveal_animation.dart';
import '../group_detail_controller.dart';
import '../group_rules_provider.dart';
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
          message: mapFriendlyError(error),
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
        ref.invalidate(cyclesListProvider(group.id));
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
          if (isAdmin && !group.rulesetConfigured) ...[
            KitBanner(
              title: 'Complete group setup',
              message:
                  'Rules must be saved before you can invite members or draw the first cycle.',
              tone: KitBadgeTone.warning,
              icon: Icons.rule_folder_outlined,
              ctaLabel: 'Open setup',
              onCtaPressed: () =>
                  context.push(AppRoutePaths.groupSetup(group.id)),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          _CurrentTurnCard(
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
              group: group,
              currentCycleAsync: currentCycleAsync,
            ),
          ],
        ],
      ),
    );
  }
}

class _CurrentTurnCard extends ConsumerStatefulWidget {
  const _CurrentTurnCard({
    required this.group,
    required this.currentCycleAsync,
    required this.isAdmin,
  });

  final GroupModel group;
  final AsyncValue<CycleModel?> currentCycleAsync;
  final bool isAdmin;

  @override
  ConsumerState<_CurrentTurnCard> createState() => _CurrentTurnCardState();
}

class _CurrentTurnCardState extends ConsumerState<_CurrentTurnCard> {
  bool _isDrawing = false;
  String? _highlightCycleId;

  Future<void> _drawWinner() async {
    if (_isDrawing) {
      return;
    }
    if (!widget.group.canStartCycle) {
      AppSnackbars.error(
        context,
        'Complete setup and ensure at least 2 eligible members before drawing the first winner.',
      );
      return;
    }

    setState(() => _isDrawing = true);

    final startedAt = DateTime.now();
    final drawController = ref.read(
      generateCycleControllerProvider(widget.group.id).notifier,
    );

    final created = await drawController.generateNextCycle();

    final elapsed = DateTime.now().difference(startedAt);
    const minimumAnimation = Duration(milliseconds: 1200);
    if (elapsed < minimumAnimation) {
      await Future<void>.delayed(minimumAnimation - elapsed);
    }

    if (!mounted) {
      return;
    }

    setState(() => _isDrawing = false);

    if (created == null) {
      final errorMessage =
          ref
              .read(generateCycleControllerProvider(widget.group.id))
              .errorMessage ??
          'Could not start a cycle right now.';
      AppSnackbars.error(context, errorMessage);
      return;
    }
    final createdCycle = created;

    final winnerName = _cycleUserLabel(
      createdCycle.finalPayoutUser,
      createdCycle.finalPayoutUserId ?? createdCycle.payoutUserId,
    );

    setState(() => _highlightCycleId = createdCycle.id);
    Timer(const Duration(milliseconds: 1200), () {
      if (!mounted || _highlightCycleId != createdCycle.id) {
        return;
      }
      setState(() => _highlightCycleId = null);
    });

    AppSnackbars.success(
      context,
      '${LotteryCopy.drawSuccessPrefix} $winnerName won this turn!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return KitCard(
      child: widget.currentCycleAsync.when(
        loading: () => const _CurrentTurnSkeleton(),
        error: (error, _) => ErrorView(
          message: mapFriendlyError(error),
          onRetry: () => ref.invalidate(currentCycleProvider(widget.group.id)),
        ),
        data: (cycle) {
          if (cycle == null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LotteryCopy.noTurnYetTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  LotteryCopy.noTurnYetMessage,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                if (_isDrawing)
                  Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        LotteryCopy.drawingWinnerLabel,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  )
                else
                  KitPrimaryButton(
                    label: !widget.isAdmin
                        ? 'Waiting for admin draw'
                        : widget.group.canStartCycle
                        ? LotteryCopy.drawWinnerButton
                        : 'Complete setup to draw',
                    icon: !widget.isAdmin
                        ? Icons.hourglass_top
                        : widget.group.canStartCycle
                        ? Icons.casino_outlined
                        : Icons.rule_folder_outlined,
                    onPressed: !widget.isAdmin
                        ? null
                        : widget.group.canStartCycle
                        ? _drawWinner
                        : () => context.push(
                            AppRoutePaths.groupSetup(widget.group.id),
                          ),
                  ),
              ],
            );
          }

          return _CurrentTurnLoaded(
            group: widget.group,
            cycle: cycle,
            isAdmin: widget.isAdmin,
            highlightWinner: _highlightCycleId == cycle.id,
          );
        },
      ),
    );
  }
}

class _CurrentTurnLoaded extends ConsumerWidget {
  const _CurrentTurnLoaded({
    required this.group,
    required this.cycle,
    required this.isAdmin,
    required this.highlightWinner,
  });

  final GroupModel group;
  final CycleModel cycle;
  final bool isAdmin;
  final bool highlightWinner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final contributionsAsync = ref.watch(
      cycleContributionsProvider((groupId: group.id, cycleId: cycle.id)),
    );
    final rules = ref.watch(groupRulesProvider(group.id)).valueOrNull;
    final payoutAsync = ref.watch(cyclePayoutProvider(cycle.id));
    final summary = contributionsAsync.valueOrNull?.summary;
    final payout = payoutAsync.valueOrNull;
    final currentUserId = currentUser?.id;
    ContributionModel? myContribution;
    if (currentUserId != null) {
      final items = contributionsAsync.valueOrNull?.items ?? const [];
      for (final item in items) {
        if (item.userId == currentUserId) {
          myContribution = item;
          break;
        }
      }
    }
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
      currentUserId: currentUserId,
      payout: payout,
      contributions: contributionsAsync.valueOrNull,
    );
    final winnerName = _cycleUserLabel(
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
                'Current turn',
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
          'Turn ${cycle.cycleNo}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Due ${formatDate(cycle.dueDate)}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (myContribution?.status == ContributionStatusModel.late) ...[
          const SizedBox(height: AppSpacing.sm),
          KitBanner(
            title: 'Your contribution is late',
            message: _lateMessage(
              contribution: myContribution,
              rules: rules,
              currency: group.currency,
            ),
            tone: KitBadgeTone.warning,
            icon: Icons.warning_amber_rounded,
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        LotteryRevealAnimation(
          play: highlightWinner,
          child: Row(
            children: [
              const Icon(Icons.emoji_events_outlined),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '${LotteryCopy.winnerHeadline}: $winnerName',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
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
          message: mapFriendlyError(error),
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
                  'No open turn yet.',
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
              message: mapFriendlyError(error),
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
              final group = ref.watch(groupDetailProvider(groupId)).valueOrNull;
              final isAdmin = group?.membership?.role == MemberRoleModel.admin;

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
                  if (isAdmin && list.summary.late > 0) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Overdue ${list.summary.late}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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

String _lateMessage({
  required ContributionModel? contribution,
  required GroupRulesModel? rules,
  required String currency,
}) {
  if (contribution?.lateMarkedAt == null) {
    return 'Your payment has passed due + grace period.';
  }

  if (rules == null) {
    return 'Your payment is late. Please submit and ask admin verification.';
  }

  if (rules.fineType == GroupRuleFineTypeModel.fixedAmount &&
      rules.fineAmount > 0) {
    return 'Late since ${formatDate(contribution!.lateMarkedAt!)}. Fine: $currency ${rules.fineAmount}.';
  }

  return 'Late since ${formatDate(contribution!.lateMarkedAt!)}. No fixed fine configured.';
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
            'Turn progress',
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
    required this.group,
    required this.currentCycleAsync,
  });

  final GroupModel group;
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
              groupId: group.id,
              cycle: cycle,
              payout: payout,
              canInviteMembers: group.canInviteMembers,
              canStartCycle: group.canStartCycle,
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

class _CurrentTurnSkeleton extends StatelessWidget {
  const _CurrentTurnSkeleton();

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
  final drawnWinnerUserId = cycle.scheduledPayoutUserId ?? cycle.payoutUserId;
  final isDrawnWinner =
      currentUserId != null && currentUserId == drawnWinnerUserId;
  final canManageAuction = isAdmin || isDrawnWinner;

  if (isAdmin && cycle.state == CycleStateModel.readyForPayout) {
    return _PrimaryAction(
      label: 'Select winner',
      icon: Icons.how_to_vote_outlined,
      onPressed: () => context.push(payoutRoute),
    );
  }

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

  if (isDrawnWinner && auctionStatus != AuctionStatusModel.open) {
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
  if (myStatus == ContributionStatusModel.late) {
    return _PrimaryAction(
      label: 'Pay now',
      icon: Icons.warning_amber_rounded,
      onPressed: () => context.push(submitRoute),
    );
  }
  if (myStatus == ContributionStatusModel.paidSubmitted ||
      myStatus == ContributionStatusModel.submitted ||
      myStatus == ContributionStatusModel.pending) {
    return const _PrimaryAction(
      label: 'Waiting confirmation',
      icon: Icons.hourglass_bottom_rounded,
      onPressed: null,
    );
  }
  if (myStatus == ContributionStatusModel.verified ||
      myStatus == ContributionStatusModel.confirmed) {
    return _PrimaryAction(
      label: 'View contributions',
      icon: Icons.receipt_long_outlined,
      onPressed: () => context.push(cycleDetailRoute),
    );
  }
  if (myStatus == null || myStatus == ContributionStatusModel.unknown) {
    return _PrimaryAction(
      label: 'Pay now',
      icon: Icons.upload_file_outlined,
      onPressed: () => context.push(submitRoute),
    );
  }

  return _PrimaryAction(
    label: 'View current turn',
    icon: Icons.visibility_outlined,
    onPressed: () => context.push(cycleDetailRoute),
  );
}

Future<void> _showAdminActions({
  required BuildContext context,
  required String groupId,
  required CycleModel? cycle,
  required PayoutModel? payout,
  required bool canInviteMembers,
  required bool canStartCycle,
}) {
  final actions = <KitActionSheetItem>[
    if (!canInviteMembers || !canStartCycle)
      KitActionSheetItem(
        label: 'Open setup checklist',
        icon: Icons.rule_folder_outlined,
        onPressed: () => context.push(AppRoutePaths.groupSetup(groupId)),
      ),
    if (canInviteMembers)
      KitActionSheetItem(
        label: 'Invite members',
        icon: Icons.person_add_alt_1_rounded,
        onPressed: () => context.push(AppRoutePaths.groupInvite(groupId)),
      ),
    if (cycle == null && canStartCycle)
      KitActionSheetItem(
        label: LotteryCopy.drawWinnerButton,
        icon: Icons.casino_outlined,
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
        label: 'Select winner / Disburse payout',
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
