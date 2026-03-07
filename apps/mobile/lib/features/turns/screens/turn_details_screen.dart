import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/bootstrap.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/contribution_dispute_model.dart';
import '../../../data/models/contribution_model.dart';
import '../../../data/models/cycle_bid_model.dart';
import '../../../data/models/cycle_model.dart';
import '../../../data/models/group_model.dart';
import '../../../data/models/payout_model.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/utils/turn_status_mapper.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../auth/auth_controller.dart';
import '../../contributions/admin_contribution_actions_controller.dart';
import '../../contributions/cycle_contributions_provider.dart';
import '../../cycles/cycle_auction_controller.dart';
import '../../cycles/cycle_bids_provider.dart';
import '../../cycles/cycle_detail_provider.dart';
import '../../groups/group_detail_controller.dart';
import '../../payouts/cycle_payout_provider.dart';
import '../turn_disputes_provider.dart';

class TurnDetailsScreen extends ConsumerStatefulWidget {
  const TurnDetailsScreen({
    super.key,
    required this.groupId,
    required this.turnId,
  });

  final String groupId;
  final String turnId;

  @override
  ConsumerState<TurnDetailsScreen> createState() => _TurnDetailsScreenState();
}

class _TurnDetailsScreenState extends ConsumerState<TurnDetailsScreen> {
  late final TextEditingController _bidAmountController;

  @override
  void initState() {
    super.initState();
    _bidAmountController = TextEditingController();
  }

  @override
  void dispose() {
    _bidAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = (groupId: widget.groupId, cycleId: widget.turnId);
    final groupAsync = ref.watch(groupDetailProvider(widget.groupId));
    final cycleAsync = ref.watch(cycleDetailProvider(args));
    final contributionsAsync = ref.watch(cycleContributionsProvider(args));
    final payoutAsync = ref.watch(cyclePayoutProvider(widget.turnId));
    final disputesAsync = ref.watch(
      turnDisputesProvider((groupId: widget.groupId, cycleId: widget.turnId)),
    );
    final auctionState = ref.watch(cycleAuctionActionControllerProvider(args));
    final adminState = ref.watch(
      adminContributionActionsControllerProvider(args),
    );

    ref.listen(cycleAuctionActionControllerProvider(args), (previous, next) {
      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;
      if (nextError != null &&
          nextError.isNotEmpty &&
          previousError != nextError) {
        KitToast.error(context, nextError);
      }
    });
    ref.listen(adminContributionActionsControllerProvider(args), (
      previous,
      next,
    ) {
      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;
      if (nextError != null &&
          nextError.isNotEmpty &&
          previousError != nextError) {
        KitToast.error(context, nextError);
      }
    });

    Future<void> onRefresh() async {
      ref
          .read(cyclesRepositoryProvider)
          .invalidateCycleDetail(widget.groupId, widget.turnId);
      ref.read(cyclesRepositoryProvider).invalidateGroupCache(widget.groupId);
      ref.read(payoutsRepositoryProvider).invalidatePayout(widget.turnId);
      ref.read(groupsRepositoryProvider).invalidateGroup(widget.groupId);
      ref.invalidate(cycleDetailProvider(args));
      ref.invalidate(cycleContributionsProvider(args));
      ref.invalidate(cyclePayoutProvider(widget.turnId));
      ref.invalidate(
        turnDisputesProvider((groupId: widget.groupId, cycleId: widget.turnId)),
      );
      ref.invalidate(cycleBidsProvider(widget.turnId));
      ref.invalidate(groupDetailProvider(widget.groupId));

      await Future.wait([
        ref.read(cycleDetailProvider(args).future),
        ref.read(cycleContributionsProvider(args).future),
      ]);
    }

    return KitScaffold(
      appBar: const KitAppBar(title: 'Turn details'),
      child: groupAsync.when(
        loading: () => const LoadingView(message: 'Loading turn...'),
        error: (error, _) => ErrorView(
          message: mapFriendlyError(error),
          onRetry: () => ref
              .read(groupDetailControllerProvider)
              .refreshAll(widget.groupId),
        ),
        data: (group) => cycleAsync.when(
          loading: () => const LoadingView(message: 'Loading turn...'),
          error: (error, _) => ErrorView(
            message: mapFriendlyError(error),
            onRetry: () => ref.invalidate(cycleDetailProvider(args)),
          ),
          data: (cycle) {
            final isAdmin = group.membership?.role == MemberRoleModel.admin;
            final currentUserId = ref.watch(currentUserProvider)?.id;
            final contributionList = contributionsAsync.valueOrNull;
            final payout = payoutAsync.valueOrNull;
            final status = mapTurnStatus(
              cycle: cycle,
              contributionSummary: contributionList?.summary,
              payout: payout,
            );

            return RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView(
                children: [
                  const SizedBox(height: AppSpacing.xs),
                  const KitSectionHeader(
                    title: 'Turn Summary',
                    subtitle: 'Winner, due date, status, and turn signals',
                  ),
                  _TurnSummaryCard(
                    group: group,
                    cycle: cycle,
                    payout: payout,
                    status: status,
                    disputesAsync: disputesAsync,
                    contributionsAsync: contributionsAsync,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const KitSectionHeader(
                    title: 'Contribution Progress',
                    subtitle: 'Current payment state and the next best action',
                  ),
                  _ContributionProgressCard(
                    group: group,
                    cycle: cycle,
                    payout: payout,
                    contributionsAsync: contributionsAsync,
                    currentUserId: currentUserId,
                    isAdmin: isAdmin,
                    adminState: adminState,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const KitSectionHeader(
                    title: 'Contributions',
                    subtitle:
                        'Member-by-member contribution tracking for this turn',
                  ),
                  _ContributionsSection(
                    group: group,
                    cycle: cycle,
                    contributionsAsync: contributionsAsync,
                    currentUserId: currentUserId,
                    isAdmin: isAdmin,
                    adminState: adminState,
                  ),
                  if (_shouldShowPayoutSection(cycle, payout)) ...[
                    const SizedBox(height: AppSpacing.md),
                    const KitSectionHeader(
                      title: 'Payout',
                      subtitle: 'Recipient, payout state, and payout actions',
                    ),
                    _PayoutSection(
                      group: group,
                      cycle: cycle,
                      payoutAsync: payoutAsync,
                      isAdmin: isAdmin,
                    ),
                  ],
                  if ((cycle.auctionStatus ?? AuctionStatusModel.none) !=
                      AuctionStatusModel.none) ...[
                    const SizedBox(height: AppSpacing.md),
                    const KitSectionHeader(
                      title: 'Auction',
                      subtitle: 'Bidding status and next auction action',
                    ),
                    _AuctionSection(
                      groupId: widget.groupId,
                      cycle: cycle,
                      isAdmin: isAdmin,
                      actionState: auctionState,
                      bidAmountController: _bidAmountController,
                    ),
                  ],
                  if ((disputesAsync.valueOrNull ?? const []).isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    const KitSectionHeader(
                      title: 'Disputes',
                      subtitle: 'Open and resolved issues tied to this turn',
                    ),
                    _DisputesSection(
                      groupId: widget.groupId,
                      cycleId: widget.turnId,
                      disputesAsync: disputesAsync,
                    ),
                  ],
                  if (_shouldShowLedgerSummary(contributionList, payout)) ...[
                    const SizedBox(height: AppSpacing.md),
                    const KitSectionHeader(
                      title: 'Ledger Summary',
                      subtitle:
                          'A concise view of collected and disbursed amounts',
                    ),
                    _LedgerSummarySection(
                      contributionList: contributionList,
                      payout: payout,
                      currency: group.currency,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TurnSummaryCard extends StatelessWidget {
  const _TurnSummaryCard({
    required this.group,
    required this.cycle,
    required this.payout,
    required this.status,
    required this.disputesAsync,
    required this.contributionsAsync,
  });

  final GroupModel group;
  final CycleModel cycle;
  final PayoutModel? payout;
  final TurnStatusPresentation status;
  final AsyncValue<List<TurnContributionDisputeGroup>> disputesAsync;
  final AsyncValue<ContributionListModel> contributionsAsync;

  @override
  Widget build(BuildContext context) {
    final contributionList = contributionsAsync.valueOrNull;
    final potSize = _turnPotSize(
      contributionList,
      fallbackAmount: group.contributionAmount,
      totalMembers: contributionList?.summary.total ?? 0,
    );
    final hasLate = (contributionList?.summary.late ?? 0) > 0;
    final hasDispute = (disputesAsync.valueOrNull ?? const []).isNotEmpty;

    return KitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Turn ${cycle.cycleNo}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _buildTurnStatusPill(status),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Due date: ${formatDate(cycle.dueDate)}'),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Winner: ${_winnerLabel(cycle, payout) ?? (cycle.state == CycleStateModel.collecting ? 'Will be drawn after collection' : 'Pending')}',
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Pot size: ${formatCurrency(potSize, group.currency)}'),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              if ((cycle.auctionStatus ?? AuctionStatusModel.none) !=
                  AuctionStatusModel.none)
                const StatusPill(label: 'Auction', tone: KitBadgeTone.info),
              if (hasLate)
                const StatusPill(label: 'Late', tone: KitBadgeTone.warning),
              if (hasDispute)
                const StatusPill(label: 'Dispute', tone: KitBadgeTone.danger),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContributionProgressCard extends ConsumerWidget {
  const _ContributionProgressCard({
    required this.group,
    required this.cycle,
    required this.payout,
    required this.contributionsAsync,
    required this.currentUserId,
    required this.isAdmin,
    required this.adminState,
  });

  final GroupModel group;
  final CycleModel cycle;
  final PayoutModel? payout;
  final AsyncValue<ContributionListModel> contributionsAsync;
  final String? currentUserId;
  final bool isAdmin;
  final AdminContributionActionsState adminState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return contributionsAsync.when(
      loading: () => const KitCard(child: KitSkeletonBox(height: 140)),
      error: (error, _) => KitCard(
        child: Text(
          mapFriendlyError(error),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      data: (list) {
        final summary = list.summary;
        final myContribution = _findContribution(list, currentUserId);
        final paid = _paidCount(summary);
        final total = summary.total;
        final action = _resolveTurnAction(
          context: context,
          group: group,
          cycle: cycle,
          payout: payout,
          contribution: myContribution,
          isAdmin: isAdmin,
          currentUserId: currentUserId,
        );

        return KitCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProgressBar(paid: paid, total: total),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.xs,
                children: [
                  _CountChip(label: 'Paid', value: '$paid/$total'),
                  _CountChip(
                    label: 'Verified',
                    value: '${summary.verified + summary.confirmed}',
                  ),
                  _CountChip(
                    label: 'Pending',
                    value:
                        '${summary.pending + summary.submitted + summary.paidSubmitted}',
                  ),
                  _CountChip(label: 'Late', value: '${summary.late}'),
                ],
              ),
              if (action != null) ...[
                const SizedBox(height: AppSpacing.md),
                KitPrimaryButton(
                  onPressed: action.onPressed,
                  label: action.label,
                  icon: action.icon,
                ),
              ],
              if (isAdmin) ...[
                const SizedBox(height: AppSpacing.sm),
                KitSecondaryButton(
                  onPressed: adminState.isEvaluating
                      ? null
                      : () async {
                          final evaluation = await ref
                              .read(
                                adminContributionActionsControllerProvider((
                                  groupId: group.id,
                                  cycleId: cycle.id,
                                )).notifier,
                              )
                              .evaluateCycleCollection();
                          if (!context.mounted || evaluation == null) {
                            return;
                          }
                          KitToast.success(
                            context,
                            'Overdue ${evaluation.overdueCount}, newly late ${evaluation.lateMarkedCount}',
                          );
                        },
                  label: adminState.isEvaluating
                      ? 'Evaluating...'
                      : 'Admin shortcut: evaluate turn',
                  icon: Icons.rule_outlined,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ContributionsSection extends StatelessWidget {
  const _ContributionsSection({
    required this.group,
    required this.cycle,
    required this.contributionsAsync,
    required this.currentUserId,
    required this.isAdmin,
    required this.adminState,
  });

  final GroupModel group;
  final CycleModel cycle;
  final AsyncValue<ContributionListModel> contributionsAsync;
  final String? currentUserId;
  final bool isAdmin;
  final AdminContributionActionsState adminState;

  @override
  Widget build(BuildContext context) {
    return contributionsAsync.when(
      loading: () => const KitCard(
        child: SizedBox(height: 320, child: KitSkeletonList(itemCount: 5)),
      ),
      error: (error, _) => KitCard(
        child: Text(
          mapFriendlyError(error),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      data: (list) {
        if (list.items.isEmpty) {
          return const KitCard(
            child: KitEmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No contributions yet',
              message:
                  'Contribution rows will appear here as members start paying.',
            ),
          );
        }

        return KitCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var index = 0; index < list.items.length; index++) ...[
                _ContributionRow(
                  group: group,
                  cycle: cycle,
                  contribution: list.items[index],
                  currentUserId: currentUserId,
                  isAdmin: isAdmin,
                  adminState: adminState,
                ),
                if (index != list.items.length - 1)
                  const Divider(height: 1, indent: 16, endIndent: 16),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ContributionRow extends ConsumerWidget {
  const _ContributionRow({
    required this.group,
    required this.cycle,
    required this.contribution,
    required this.currentUserId,
    required this.isAdmin,
    required this.adminState,
  });

  final GroupModel group;
  final CycleModel cycle;
  final ContributionModel contribution;
  final String? currentUserId;
  final bool isAdmin;
  final AdminContributionActionsState adminState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMe = currentUserId != null && contribution.userId == currentUserId;
    final hasProof = contribution.proofFileKey?.trim().isNotEmpty == true;
    final timestamp = _contributionTimestamp(contribution);
    final args = (groupId: group.id, cycleId: cycle.id);

    Future<void> openActions() async {
      final actions = <KitActionSheetItem>[
        if (isAdmin && _canVerify(contribution.status))
          KitActionSheetItem(
            label: 'Verify',
            icon: Icons.fact_check_outlined,
            onPressed: () async {
              final success = await ref
                  .read(
                    adminContributionActionsControllerProvider(args).notifier,
                  )
                  .confirm(contribution.id);
              if (!context.mounted || !success) {
                return;
              }
              KitToast.success(context, 'Contribution verified');
            },
          ),
        if (isAdmin && _canReject(contribution.status))
          KitActionSheetItem(
            label: 'Reject',
            icon: Icons.close_rounded,
            isDestructive: true,
            onPressed: () async {
              final reason = await promptText(
                context: context,
                title: 'Reject contribution',
                label: 'Reason',
                hint: 'Explain what should be corrected',
                submitLabel: 'Reject',
              );
              if (!context.mounted || reason == null || reason.trim().isEmpty) {
                return;
              }
              final success = await ref
                  .read(
                    adminContributionActionsControllerProvider(args).notifier,
                  )
                  .reject(contribution.id, reason);
              if (!context.mounted || !success) {
                return;
              }
              KitToast.success(context, 'Contribution rejected');
            },
          ),
        if (isAdmin)
          KitActionSheetItem(
            label: 'Open dispute',
            icon: Icons.report_problem_outlined,
            onPressed: () => context.push(
              AppRoutePaths.groupCycleContributionDisputes(
                group.id,
                cycle.id,
                contribution.id,
              ),
            ),
          ),
        if (isMe && _canResubmit(contribution.status))
          KitActionSheetItem(
            label: contribution.proofFileKey == null
                ? 'Upload receipt'
                : 'Update receipt',
            icon: Icons.upload_file_outlined,
            onPressed: () => context.push(
              AppRoutePaths.groupCycleContributionsSubmit(group.id, cycle.id),
            ),
          ),
        if (isMe && hasProof)
          KitActionSheetItem(
            label: 'View receipt',
            icon: Icons.receipt_long_outlined,
            onPressed: () =>
                _viewProof(context, ref, contribution.proofFileKey!),
          ),
      ];

      if (actions.isEmpty) {
        if (hasProof) {
          await _viewProof(context, ref, contribution.proofFileKey!);
        }
        return;
      }

      await KitActionSheet.show(
        context: context,
        title: contribution.displayName,
        actions: actions,
      );
    }

    return InkWell(
      onTap: openActions,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KitAvatar(name: contribution.displayName),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          contribution.displayName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      StatusPill(
                        label: _contributionStatusLabel(contribution.status),
                        tone: _contributionTone(contribution.status),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    timestamp,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      if (hasProof)
                        const StatusPill(
                          label: 'Receipt',
                          tone: KitBadgeTone.info,
                        ),
                      if (adminState.activeContributionId == contribution.id &&
                          adminState.isLoading)
                        const StatusPill(
                          label: 'Updating',
                          tone: KitBadgeTone.warning,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Icon(Icons.more_horiz_rounded),
          ],
        ),
      ),
    );
  }
}

class _PayoutSection extends StatelessWidget {
  const _PayoutSection({
    required this.group,
    required this.cycle,
    required this.payoutAsync,
    required this.isAdmin,
  });

  final GroupModel group;
  final CycleModel cycle;
  final AsyncValue<PayoutModel?> payoutAsync;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return payoutAsync.when(
      loading: () => const KitCard(child: KitSkeletonBox(height: 120)),
      error: (error, _) => KitCard(
        child: Text(
          mapFriendlyError(error),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      data: (payout) {
        final statusText = payout == null
            ? cycle.state == CycleStateModel.readyForWinnerSelection
                  ? 'Ready to draw winner'
                  : 'Awaiting payout step'
            : payout.status == PayoutStatusModel.confirmed
            ? 'Receipt confirmed'
            : 'Sent';

        return KitCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryLine(
                label: 'Winner',
                value: _winnerLabel(cycle, payout) ?? 'Pending',
              ),
              const SizedBox(height: AppSpacing.xs),
              _SummaryLine(
                label: 'Payout amount',
                value: formatCurrency(payout?.amount ?? 0, group.currency),
              ),
              const SizedBox(height: AppSpacing.xs),
              _SummaryLine(label: 'Disbursement status', value: statusText),
              if (payout?.paymentRef != null &&
                  payout!.paymentRef!.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                _SummaryLine(label: 'Proof / ref', value: payout.paymentRef!),
              ],
              const SizedBox(height: AppSpacing.md),
              KitSecondaryButton(
                onPressed: () => context.push(
                  AppRoutePaths.groupCyclePayout(group.id, cycle.id),
                ),
                label: isAdmin ? 'Manage payout' : 'View payout details',
                icon: isAdmin
                    ? Icons.account_balance_wallet_outlined
                    : Icons.visibility_outlined,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AuctionSection extends ConsumerWidget {
  const _AuctionSection({
    required this.groupId,
    required this.cycle,
    required this.isAdmin,
    required this.actionState,
    required this.bidAmountController,
  });

  final String groupId;
  final CycleModel cycle;
  final bool isAdmin;
  final CycleAuctionActionState actionState;
  final TextEditingController bidAmountController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bidsAsync = ref.watch(cycleBidsProvider(cycle.id));
    final args = (groupId: groupId, cycleId: cycle.id);
    final isLoading = actionState.isLoading;
    final highestBid = bidsAsync.valueOrNull?.fold<CycleBidModel?>(null, (
      current,
      bid,
    ) {
      if (current == null) {
        return bid;
      }
      return bid.amount > current.amount ? bid : current;
    });

    return KitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryLine(
            label: 'Auction status',
            value: _auctionStatusLabel(
              cycle.auctionStatus ?? AuctionStatusModel.none,
            ),
          ),
          if (highestBid != null) ...[
            const SizedBox(height: AppSpacing.xs),
            _SummaryLine(
              label: 'Current highest bid',
              value: '${highestBid.amount} by ${_bidderLabel(highestBid)}',
            ),
          ],
          if ((cycle.auctionStatus ?? AuctionStatusModel.none) ==
              AuctionStatusModel.open) ...[
            const SizedBox(height: AppSpacing.md),
            if (!isAdmin) ...[
              KitNumberField(
                controller: bidAmountController,
                label: 'Bid amount',
              ),
              const SizedBox(height: AppSpacing.sm),
              KitPrimaryButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        final amount = int.tryParse(
                          bidAmountController.text.trim(),
                        );
                        if (amount == null || amount <= 0) {
                          KitToast.error(
                            context,
                            'Enter a bid amount greater than 0.',
                          );
                          return;
                        }
                        final success = await ref
                            .read(
                              cycleAuctionActionControllerProvider(
                                args,
                              ).notifier,
                            )
                            .submitBid(amount);
                        if (!context.mounted || !success) {
                          return;
                        }
                        bidAmountController.clear();
                        KitToast.success(context, 'Bid submitted.');
                      },
                label: 'Place bid',
                icon: Icons.local_offer_outlined,
              ),
            ] else
              KitPrimaryButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        final success = await ref
                            .read(
                              cycleAuctionActionControllerProvider(
                                args,
                              ).notifier,
                            )
                            .closeAuction();
                        if (!context.mounted || !success) {
                          return;
                        }
                        KitToast.success(context, 'Auction closed.');
                      },
                label: 'Close auction',
                icon: Icons.gavel_rounded,
              ),
          ],
        ],
      ),
    );
  }
}

class _DisputesSection extends StatelessWidget {
  const _DisputesSection({
    required this.groupId,
    required this.cycleId,
    required this.disputesAsync,
  });

  final String groupId;
  final String cycleId;
  final AsyncValue<List<TurnContributionDisputeGroup>> disputesAsync;

  @override
  Widget build(BuildContext context) {
    return disputesAsync.when(
      loading: () => const KitCard(
        child: SizedBox(height: 220, child: KitSkeletonList(itemCount: 3)),
      ),
      error: (error, _) => KitCard(
        child: Text(
          mapFriendlyError(error),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      data: (groups) {
        return KitCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var index = 0; index < groups.length; index++) ...[
                _DisputeRow(
                  groupId: groupId,
                  cycleId: cycleId,
                  item: groups[index],
                ),
                if (index != groups.length - 1)
                  const Divider(height: 1, indent: 16, endIndent: 16),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DisputeRow extends StatelessWidget {
  const _DisputeRow({
    required this.groupId,
    required this.cycleId,
    required this.item,
  });

  final String groupId;
  final String cycleId;
  final TurnContributionDisputeGroup item;

  @override
  Widget build(BuildContext context) {
    final latest = item.disputes.last;

    return ListTile(
      title: Text(item.contribution.displayName),
      subtitle: Text(
        '${_disputeStatusLabel(latest.status)} • ${formatDate(latest.updatedAt, includeTime: true)}',
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => context.push(
        AppRoutePaths.groupCycleContributionDisputes(
          groupId,
          cycleId,
          item.contribution.id,
        ),
      ),
    );
  }
}

class _LedgerSummarySection extends StatelessWidget {
  const _LedgerSummarySection({
    required this.contributionList,
    required this.payout,
    required this.currency,
  });

  final ContributionListModel? contributionList;
  final PayoutModel? payout;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final collected =
        contributionList?.items
            .where(
              (item) =>
                  item.status == ContributionStatusModel.verified ||
                  item.status == ContributionStatusModel.confirmed,
            )
            .fold<int>(0, (sum, item) => sum + item.amount) ??
        0;
    final disbursed = payout?.amount ?? 0;

    return KitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryLine(
            label: 'Collected amount',
            value: formatCurrency(collected, currency),
          ),
          if (disbursed > 0) ...[
            const SizedBox(height: AppSpacing.xs),
            _SummaryLine(
              label: 'Disbursed amount',
              value: formatCurrency(disbursed, currency),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.pillRounded,
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.paid, required this.total});

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

_TurnAction? _resolveTurnAction({
  required BuildContext context,
  required GroupModel group,
  required CycleModel cycle,
  required PayoutModel? payout,
  required ContributionModel? contribution,
  required bool isAdmin,
  required String? currentUserId,
}) {
  if (isAdmin && cycle.state == CycleStateModel.readyForWinnerSelection) {
    return _TurnAction(
      label: 'Draw winner',
      icon: Icons.emoji_events_outlined,
      onPressed: () =>
          context.push(AppRoutePaths.groupCyclePayout(group.id, cycle.id)),
    );
  }

  if (isAdmin && cycle.state == CycleStateModel.readyForPayout) {
    return _TurnAction(
      label: 'Mark payout sent',
      icon: Icons.account_balance_wallet_outlined,
      onPressed: () =>
          context.push(AppRoutePaths.groupCyclePayout(group.id, cycle.id)),
    );
  }

  if (!isAdmin &&
      cycle.state == CycleStateModel.payoutSent &&
      cycle.selectedWinnerUserId == currentUserId) {
    return _TurnAction(
      label: 'Confirm receipt',
      icon: Icons.task_alt_rounded,
      onPressed: () =>
          context.push(AppRoutePaths.groupCyclePayout(group.id, cycle.id)),
    );
  }

  if ((cycle.auctionStatus ?? AuctionStatusModel.none) ==
      AuctionStatusModel.open) {
    return null;
  }

  if (contribution == null) {
    return _TurnAction(
      label: 'Pay now',
      icon: Icons.upload_file_outlined,
      onPressed: () => context.push(
        AppRoutePaths.groupCycleContributionsSubmit(group.id, cycle.id),
      ),
    );
  }

  return switch (contribution.status) {
    ContributionStatusModel.rejected => _TurnAction(
      label: 'Fix & resubmit',
      icon: Icons.refresh_rounded,
      onPressed: () => context.push(
        AppRoutePaths.groupCycleContributionsSubmit(group.id, cycle.id),
      ),
    ),
    ContributionStatusModel.late => _TurnAction(
      label: 'Pay now',
      icon: Icons.warning_amber_rounded,
      onPressed: () => context.push(
        AppRoutePaths.groupCycleContributionsSubmit(group.id, cycle.id),
      ),
    ),
    ContributionStatusModel.paidSubmitted ||
    ContributionStatusModel.submitted => const _TurnAction(
      label: 'Waiting for verification',
      icon: Icons.hourglass_bottom_rounded,
      onPressed: null,
    ),
    ContributionStatusModel.pending => _TurnAction(
      label: 'Upload receipt',
      icon: Icons.upload_file_outlined,
      onPressed: () => context.push(
        AppRoutePaths.groupCycleContributionsSubmit(group.id, cycle.id),
      ),
    ),
    _ => null,
  };
}

StatusPill _buildTurnStatusPill(TurnStatusPresentation status) {
  final tone = switch (status.stage) {
    TurnStage.waiting => KitBadgeTone.warning,
    TurnStage.collecting => KitBadgeTone.info,
    TurnStage.readyForWinnerSelection => KitBadgeTone.warning,
    TurnStage.auction => KitBadgeTone.info,
    TurnStage.readyForPayout => KitBadgeTone.warning,
    TurnStage.payoutSent => KitBadgeTone.info,
    TurnStage.completed => KitBadgeTone.success,
  };
  return StatusPill(label: status.label, tone: tone);
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

String? _winnerLabel(CycleModel cycle, PayoutModel? payout) {
  final payoutLabel = payout?.recipientLabel.trim();
  if (payoutLabel != null && payoutLabel.isNotEmpty) {
    return payoutLabel;
  }
  if (cycle.selectedWinnerUserId == null) {
    return null;
  }
  final user =
      cycle.selectedWinnerUser ?? cycle.finalPayoutUser ?? cycle.payoutUser;
  final fullName = user?.fullName?.trim();
  if (fullName != null && fullName.isNotEmpty) {
    return fullName;
  }
  final phone = user?.phone?.trim();
  if (phone != null && phone.isNotEmpty) {
    return phone;
  }
  final fallback = cycle.selectedWinnerUserId;
  if (fallback == null || fallback.isEmpty) {
    return null;
  }
  return fallback;
}

String _contributionStatusLabel(ContributionStatusModel status) {
  return switch (status) {
    ContributionStatusModel.pending => 'Pending',
    ContributionStatusModel.late => 'Late',
    ContributionStatusModel.paidSubmitted => 'Submitted',
    ContributionStatusModel.submitted => 'Submitted',
    ContributionStatusModel.verified => 'Verified',
    ContributionStatusModel.confirmed => 'Verified',
    ContributionStatusModel.rejected => 'Rejected',
    _ => 'Unknown',
  };
}

KitBadgeTone _contributionTone(ContributionStatusModel status) {
  return switch (status) {
    ContributionStatusModel.verified ||
    ContributionStatusModel.confirmed => KitBadgeTone.success,
    ContributionStatusModel.rejected => KitBadgeTone.danger,
    ContributionStatusModel.late => KitBadgeTone.warning,
    ContributionStatusModel.pending ||
    ContributionStatusModel.submitted ||
    ContributionStatusModel.paidSubmitted => KitBadgeTone.info,
    _ => KitBadgeTone.info,
  };
}

String _contributionTimestamp(ContributionModel contribution) {
  if (contribution.confirmedAt != null) {
    return 'Verified ${formatDate(contribution.confirmedAt!, includeTime: true)}';
  }
  if (contribution.submittedAt != null) {
    return 'Submitted ${formatDate(contribution.submittedAt!, includeTime: true)}';
  }
  if (contribution.lateMarkedAt != null) {
    return 'Late ${formatDate(contribution.lateMarkedAt!, includeTime: true)}';
  }
  if (contribution.rejectedAt != null) {
    return 'Rejected ${formatDate(contribution.rejectedAt!, includeTime: true)}';
  }
  return 'No timestamp yet';
}

bool _canVerify(ContributionStatusModel status) {
  return status == ContributionStatusModel.paidSubmitted ||
      status == ContributionStatusModel.submitted ||
      status == ContributionStatusModel.late;
}

bool _canReject(ContributionStatusModel status) {
  return status == ContributionStatusModel.paidSubmitted ||
      status == ContributionStatusModel.submitted ||
      status == ContributionStatusModel.late;
}

bool _canResubmit(ContributionStatusModel status) {
  return status != ContributionStatusModel.verified &&
      status != ContributionStatusModel.confirmed;
}

String _auctionStatusLabel(AuctionStatusModel status) {
  return switch (status) {
    AuctionStatusModel.none => 'Not started',
    AuctionStatusModel.open => 'Open',
    AuctionStatusModel.closed => 'Closed',
    _ => 'Unknown',
  };
}

String _bidderLabel(CycleBidModel bid) {
  final name = bid.user.fullName?.trim();
  if (name != null && name.isNotEmpty) {
    return name;
  }
  final phone = bid.user.phone?.trim();
  if (phone != null && phone.isNotEmpty) {
    return phone;
  }
  return bid.userId;
}

String _disputeStatusLabel(ContributionDisputeStatusModel status) {
  return switch (status) {
    ContributionDisputeStatusModel.open => 'Open',
    ContributionDisputeStatusModel.mediating => 'Mediating',
    ContributionDisputeStatusModel.resolved => 'Resolved',
    _ => 'Unknown',
  };
}

int _paidCount(ContributionSummaryModel summary) {
  return summary.submitted +
      summary.paidSubmitted +
      summary.verified +
      summary.confirmed;
}

int _turnPotSize(
  ContributionListModel? list, {
  required int fallbackAmount,
  required int totalMembers,
}) {
  final items = list?.items ?? const <ContributionModel>[];
  if (items.isNotEmpty) {
    return items.fold<int>(0, (sum, item) => sum + item.amount);
  }
  return fallbackAmount * totalMembers;
}

bool _shouldShowPayoutSection(CycleModel cycle, PayoutModel? payout) {
  return payout != null ||
      cycle.state == CycleStateModel.readyForWinnerSelection ||
      cycle.state == CycleStateModel.readyForPayout ||
      cycle.state == CycleStateModel.payoutSent ||
      cycle.status == CycleStatusModel.closed;
}

bool _shouldShowLedgerSummary(
  ContributionListModel? contributionList,
  PayoutModel? payout,
) {
  final hasCollected = (contributionList?.items.isNotEmpty ?? false);
  return hasCollected || payout != null;
}

Future<void> _viewProof(BuildContext context, WidgetRef ref, String key) async {
  try {
    final repository = ref.read(filesRepositoryProvider);
    final url = await repository.getSignedDownloadUrl(key);

    if (!context.mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Receipt',
                      style: Theme.of(dialogContext).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 420,
                  width: double.infinity,
                  child: InteractiveViewer(
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Text('Could not load receipt image.'),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  } catch (error) {
    if (!context.mounted) {
      return;
    }
    KitToast.error(context, mapFriendlyError(error));
  }
}
