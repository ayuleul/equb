part of 'turn_details_screen.dart';

class _TurnSummaryCard extends StatelessWidget {
  const _TurnSummaryCard({
    required this.group,
    required this.cycle,
    required this.payout,
    required this.status,
    required this.contributionsAsync,
    required this.currentUserId,
  });

  final GroupModel group;
  final CycleModel cycle;
  final PayoutModel? payout;
  final TurnStatusPresentation status;
  final AsyncValue<ContributionListModel> contributionsAsync;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    final contributionList = contributionsAsync.valueOrNull;
    final myContribution = _findContribution(contributionList, currentUserId);
    final potSize = _turnPotSize(
      contributionList,
      fallbackAmount: group.contributionAmount,
      totalMembers: contributionList?.summary.total ?? 0,
    );

    return KitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TurnStatusLine(status: status),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your contribution',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    formatCurrency(
                      myContribution?.amount ?? group.contributionAmount,
                      group.currency,
                    ),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text('Pot size: ${formatCurrency(potSize, group.currency)}'),
                ],
              ),
              const SizedBox(width: AppSpacing.xxs),
              DueCountdown(dueDate: cycle.dueDate),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _WinnerHighlight(cycle: cycle, payout: payout),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _winnerSelectionStateCopy(cycle),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _WinnerHighlight extends StatelessWidget {
  const _WinnerHighlight({required this.cycle, required this.payout});

  final CycleModel cycle;
  final PayoutModel? payout;

  @override
  Widget build(BuildContext context) {
    final winner = _winnerLabel(cycle, payout);
    final hasWinner = winner != null;
    final colorScheme = Theme.of(context).colorScheme;
    final brand = context.brand;
    final background = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: hasWinner
            ? [
                colorScheme.primary.withValues(alpha: 0.16),
                colorScheme.tertiary.withValues(alpha: 0.12),
              ]
            : [
                brand.cardAccentStart.withValues(alpha: 0.12),
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
              ],
      ),
      borderRadius: AppRadius.cardRounded,
      border: Border.all(
        color: hasWinner
            ? colorScheme.primary.withValues(alpha: 0.26)
            : colorScheme.outlineVariant,
      ),
    );

    return Container(
      width: double.infinity,
      decoration: background,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: hasWinner
          ? _WinnerSelectedContent(cycle: cycle, winner: winner)
          : _WinnerPendingContent(cycle: cycle),
    );
  }
}

class _WinnerSelectedContent extends StatelessWidget {
  const _WinnerSelectedContent({required this.cycle, required this.winner});

  final CycleModel cycle;
  final String winner;

  @override
  Widget build(BuildContext context) {
    final selectedAt = cycle.winnerSelectedAt;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KitAvatar(name: winner, size: KitAvatarSize.lg),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                winner,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                selectedAt == null
                    ? 'This member is the selected winner for this turn.'
                    : 'Selected ${formatDate(selectedAt, includeTime: true)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Icon(
          Icons.emoji_events_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }
}

class _WinnerPendingContent extends StatelessWidget {
  const _WinnerPendingContent({required this.cycle});

  final CycleModel cycle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.hourglass_top_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Winner not selected yet',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                _winnerPendingCopy(cycle),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CollectionSection extends ConsumerWidget {
  const _CollectionSection({
    required this.group,
    required this.cycle,
    required this.contributionsAsync,
    required this.currentUserId,
    required this.isAdmin,
    required this.adminState,
    required this.action,
  });

  final GroupModel group;
  final CycleModel cycle;
  final AsyncValue<ContributionListModel> contributionsAsync;
  final String? currentUserId;
  final bool isAdmin;
  final AdminContributionActionsState adminState;
  final _TurnAction? action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return contributionsAsync.when(
      loading: () => const KitCard(child: KitSkeletonBox(height: 360)),
      error: (error, _) => KitCard(
        child: Text(
          mapFriendlyError(error),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      data: (list) {
        final stats = _buildCollectionStats(list);
        final inlineAction = _showsInFooterTray(action) ? null : action;
        final sortedItems = _sortContributionsForDisplay(
          list.items,
          currentUserId: currentUserId,
        );

        if (list.items.isEmpty) {
          return KitCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MemberPaymentProgressSummary(stats: stats),
                const SizedBox(height: AppSpacing.sm),
                _ProgressBar(paid: stats.paid, total: stats.total),
                if (_buildCollectionSecondarySummary(stats)
                    case final summary?) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    summary,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (_collectionStatusHintText(
                      stats: stats,
                      action: inlineAction,
                      isAdmin: isAdmin,
                    )
                    case final hint?) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    hint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                if (inlineAction != null && inlineAction.onPressed == null)
                  _CollectionActionNote(action: inlineAction),
                if (inlineAction != null && inlineAction.onPressed == null)
                  const SizedBox(height: AppSpacing.md),
                const KitEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No contributions yet',
                  message:
                      'Contribution rows will appear here as members start paying.',
                ),
              ],
            ),
          );
        }

        return KitCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MemberPaymentProgressSummary(stats: stats),
                    const SizedBox(height: AppSpacing.md),
                    _ProgressBar(paid: stats.paid, total: stats.total),
                    if (_buildCollectionSecondarySummary(stats)
                        case final summary?) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        summary,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (_collectionStatusHintText(
                          stats: stats,
                          action: inlineAction,
                          isAdmin: isAdmin,
                        )
                        case final hint?) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        hint,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (inlineAction != null &&
                        inlineAction.onPressed != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      _CollectionPrimaryAction(action: inlineAction),
                    ],
                    if (inlineAction != null &&
                        inlineAction.onPressed == null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _CollectionActionNote(action: inlineAction),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1),
              for (var index = 0; index < sortedItems.length; index++) ...[
                _ContributionRow(
                  group: group,
                  cycle: cycle,
                  contribution: sortedItems[index],
                  currentUserId: currentUserId,
                  isAdmin: isAdmin,
                  adminState: adminState,
                ),
                if (index != sortedItems.length - 1)
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
                  .confirm(contribution.id, preferSocketSync: true);
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
                  .reject(contribution.id, reason, preferSocketSync: true);
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
                ? 'Pay ${formatCurrency(group.contributionAmount, group.currency)}'
                : 'Update payment',
            icon: Icons.upload_file_outlined,
            onPressed: () => context.push(
              AppRoutePaths.groupCycleContributionsSubmit(group.id, cycle.id),
            ),
          ),
        if (isMe && hasProof)
          KitActionSheetItem(
            label: 'View payment proof',
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
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: isMe
                ? Theme.of(context).colorScheme.surfaceContainerHigh
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isMe
                  ? Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.22)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KitAvatar(name: contribution.displayName),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          isMe
                              ? '${contribution.displayName} (You)'
                              : contribution.displayName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
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
                          KitTertiaryButton(
                            onPressed: () => _viewProof(
                              context,
                              ref,
                              contribution.proofFileKey!,
                            ),
                            label: 'View receipt',
                            icon: Icons.receipt_long_outlined,
                            expand: false,
                          ),
                        if (adminState.activeContributionId ==
                                contribution.id &&
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
      ),
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
                            .submitBid(amount, preferSocketSync: true);
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
                            .closeAuction(preferSocketSync: true);
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
      loading: () => const KitCard(child: KitSkeletonBox(height: 220)),
      error: (error, _) => KitCard(
        child: Text(
          mapFriendlyError(error),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      data: (groups) => KitCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            for (var index = 0; index < groups.length; index++) ...[
              _DisputeRow(
                groupId: groupId,
                cycleId: cycleId,
                disputeGroup: groups[index],
              ),
              if (index != groups.length - 1)
                const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _DisputeRow extends StatelessWidget {
  const _DisputeRow({
    required this.groupId,
    required this.cycleId,
    required this.disputeGroup,
  });

  final String groupId;
  final String cycleId;
  final TurnContributionDisputeGroup disputeGroup;

  @override
  Widget build(BuildContext context) {
    final latest = disputeGroup.disputes.isEmpty
        ? null
        : disputeGroup.disputes.reduce(
            (current, next) =>
                next.updatedAt.isAfter(current.updatedAt) ? next : current,
          );
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      title: Text(disputeGroup.contribution.displayName),
      subtitle: Text(
        latest == null
            ? 'No dispute details available.'
            : '${_disputeStatusLabel(latest.status)} • ${formatDate(latest.createdAt, includeTime: true)}',
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => context.push(
        AppRoutePaths.groupCycleContributionDisputes(
          groupId,
          cycleId,
          disputeGroup.contribution.id,
        ),
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
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _MemberPaymentProgressSummary extends StatelessWidget {
  const _MemberPaymentProgressSummary({required this.stats});

  final _CollectionStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Progress',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${stats.paid} / ${stats.total} ${stats.total == 1 ? 'member' : 'members'} paid',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

bool _isCurrentUser(ContributionModel contribution, String? currentUserId) {
  return currentUserId != null && contribution.userId == currentUserId;
}

List<ContributionModel> _sortContributionsForDisplay(
  List<ContributionModel> items, {
  required String? currentUserId,
}) {
  final sorted = [...items];
  sorted.sort((a, b) {
    final aIsMe = _isCurrentUser(a, currentUserId);
    final bIsMe = _isCurrentUser(b, currentUserId);
    if (aIsMe != bIsMe) {
      return aIsMe ? -1 : 1;
    }
    return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
  });
  return sorted;
}

class _CollectionActionNote extends StatelessWidget {
  const _CollectionActionNote({required this.action});

  final _TurnAction action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            action.icon,
            size: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              action.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionPrimaryAction extends StatelessWidget {
  const _CollectionPrimaryAction({required this.action});

  final _TurnAction action;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: KitPrimaryButton(
        onPressed: action.onPressed,
        label: action.label,
        icon: action.icon,
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

String? _collectionStatusHintText({
  required _CollectionStats stats,
  required _TurnAction? action,
  required bool isAdmin,
}) {
  if (stats.total == 0) {
    return 'No member payments have been submitted for this turn yet.';
  }

  if (stats.late > 0) {
    return '${stats.late} ${stats.late == 1 ? 'member is' : 'members are'} marked late.';
  }

  if (stats.verified == stats.total && stats.total > 0) {
    return isAdmin
        ? 'All member payments are verified for this turn.'
        : 'All member payments are verified for this turn.';
  }

  if (action != null && action.onPressed == null) {
    return action.label;
  }

  return null;
}

String? _buildCollectionSecondarySummary(_CollectionStats stats) {
  final parts = <String>[
    if (stats.pending > 0) '${stats.pending} pending',
    if (stats.verified > 0) '${stats.verified} verified',
    if (stats.late > 0) '${stats.late} late',
  ];
  if (parts.isEmpty) {
    return null;
  }
  return parts.join(' • ');
}

class _TurnStatusLine extends StatelessWidget {
  const _TurnStatusLine({required this.status});

  final TurnStatusPresentation status;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 10, color: _turnStatusColor(context, status)),
        const SizedBox(width: AppSpacing.xs),
        Text(
          status.label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

Color _turnStatusColor(BuildContext context, TurnStatusPresentation status) {
  return switch (status.stage) {
    TurnStage.waiting => context.colors.warning,
    TurnStage.collecting => context.colors.info,
    TurnStage.readyForWinnerSelection => context.colors.warning,
    TurnStage.auction => context.colors.info,
    TurnStage.readyForPayout => context.colors.warning,
    TurnStage.payoutSent => context.colors.info,
    TurnStage.completed => context.colors.success,
  };
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

String _winnerSelectionStateCopy(CycleModel cycle) {
  if (cycle.selectedWinnerUserId != null) {
    if (cycle.state == CycleStateModel.readyForPayout) {
      return 'Winner is set. The next step is payout disbursement.';
    }
    if (cycle.state == CycleStateModel.payoutSent) {
      return 'Payout was sent. Waiting for the winner to confirm receipt.';
    }
    return 'Winner has been selected for this turn.';
  }
  return _winnerPendingCopy(cycle);
}

String _winnerPendingCopy(CycleModel cycle) {
  if (cycle.state == CycleStateModel.collecting) {
    return 'Winner will be drawn after collection';
  }
  if (cycle.state == CycleStateModel.readyForWinnerSelection) {
    return 'Waiting for draw';
  }
  if (cycle.state == CycleStateModel.readyForPayout) {
    return 'Winner selected. Ready for payout';
  }
  if (cycle.state == CycleStateModel.payoutSent) {
    return 'Payout sent. Waiting for receipt confirmation';
  }
  return 'Winner will appear here once this turn progresses';
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
    ContributionStatusModel.late => KitBadgeTone.danger,
    ContributionStatusModel.pending => KitBadgeTone.neutral,
    ContributionStatusModel.submitted ||
    ContributionStatusModel.paidSubmitted => KitBadgeTone.info,
    _ => KitBadgeTone.info,
  };
}

String _contributionTimestamp(ContributionModel contribution) {
  if (contribution.confirmedAt != null) {
    return 'Approved ${formatShortDateTime(contribution.confirmedAt!)}';
  }
  if (contribution.submittedAt != null) {
    return 'Submitted ${formatShortDateTime(contribution.submittedAt!)}';
  }
  if (contribution.lateMarkedAt != null) {
    return 'Overdue since ${formatShortDateTime(contribution.lateMarkedAt!)}';
  }
  if (contribution.rejectedAt != null) {
    return 'Rejected ${formatShortDateTime(contribution.rejectedAt!)}';
  }
  return 'Payment not submitted';
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

typedef _CollectionStats = ({
  int total,
  int paid,
  int verified,
  int pending,
  int late,
});

_CollectionStats _buildCollectionStats(ContributionListModel list) {
  var paid = 0;
  var verified = 0;
  var pending = 0;
  var late = 0;

  for (final item in list.items) {
    switch (item.status) {
      case ContributionStatusModel.verified:
      case ContributionStatusModel.confirmed:
        paid += 1;
        verified += 1;
        break;
      case ContributionStatusModel.paidSubmitted:
      case ContributionStatusModel.submitted:
        paid += 1;
        break;
      case ContributionStatusModel.late:
        late += 1;
        break;
      case ContributionStatusModel.pending:
      case ContributionStatusModel.rejected:
      case ContributionStatusModel.unknown:
        pending += 1;
        break;
    }
  }

  return (
    total: list.items.length,
    paid: paid,
    verified: verified,
    pending: pending,
    late: late,
  );
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
