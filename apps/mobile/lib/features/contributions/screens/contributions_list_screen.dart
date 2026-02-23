import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/bootstrap.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/contribution_model.dart';
import '../../../data/models/cycle_model.dart';
import '../../../data/models/group_model.dart';
import '../../../features/auth/auth_controller.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/error_view.dart';
import '../../cycles/cycle_detail_provider.dart';
import '../../groups/group_detail_controller.dart';
import '../admin_contribution_actions_controller.dart';
import '../cycle_contributions_provider.dart';

enum _ContributionFilter { all, pending, late, submitted, confirmed, rejected }

class ContributionsListScreen extends ConsumerStatefulWidget {
  const ContributionsListScreen({
    super.key,
    required this.groupId,
    required this.cycleId,
  });

  final String groupId;
  final String cycleId;

  @override
  ConsumerState<ContributionsListScreen> createState() =>
      _ContributionsListScreenState();
}

class _ContributionsListScreenState
    extends ConsumerState<ContributionsListScreen> {
  _ContributionFilter _filter = _ContributionFilter.all;

  @override
  Widget build(BuildContext context) {
    final groupId = widget.groupId;
    final cycleId = widget.cycleId;
    final args = (groupId: groupId, cycleId: cycleId);

    final contributionsAsync = ref.watch(cycleContributionsProvider(args));
    final cycleAsync = ref.watch(
      cycleDetailProvider((groupId: groupId, cycleId: cycleId)),
    );
    final groupAsync = ref.watch(groupDetailProvider(groupId));
    final currentUser = ref.watch(currentUserProvider);
    final adminState = ref.watch(
      adminContributionActionsControllerProvider(args),
    );

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

    final group = groupAsync.valueOrNull;
    final isAdmin = group?.membership?.role == MemberRoleModel.admin;

    Future<void> onRefresh() async {
      ref.invalidate(cycleContributionsProvider(args));
      ref.invalidate(cycleDetailProvider((groupId: groupId, cycleId: cycleId)));
      ref.invalidate(groupDetailProvider(groupId));
      await Future.wait([
        ref.read(cycleContributionsProvider(args).future),
        ref.read(
          cycleDetailProvider((groupId: groupId, cycleId: cycleId)).future,
        ),
      ]);
    }

    return KitScaffold(
      appBar: KitAppBar(
        title: 'Contributions',
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => onRefresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      child: contributionsAsync.when(
        loading: () =>
            const SizedBox(height: 360, child: KitSkeletonList(itemCount: 4)),
        error: (error, _) => ErrorView(
          message: mapFriendlyError(error),
          onRetry: () => ref.invalidate(cycleContributionsProvider(args)),
        ),
        data: (contributionList) {
          ContributionModel? myContribution;
          final userId = currentUser?.id;
          if (userId != null) {
            for (final item in contributionList.items) {
              if (item.userId == userId) {
                myContribution = item;
                break;
              }
            }
          }

          final filteredItems = contributionList.items
              .where((item) => _matchesFilter(_filter, item.status))
              .toList(growable: false);

          final cycle = cycleAsync.valueOrNull;
          final canSubmit =
              currentUser != null &&
              (myContribution == null ||
                  (myContribution.status != ContributionStatusModel.verified &&
                      myContribution.status !=
                          ContributionStatusModel.confirmed)) &&
              cycle?.status == CycleStatusModel.open;

          return RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView(
              children: [
                _CycleHeaderCard(cycleAsync: cycleAsync),
                const SizedBox(height: AppSpacing.md),
                if (isAdmin)
                  KitSecondaryButton(
                    onPressed: adminState.isEvaluating
                        ? null
                        : () async {
                            final evaluation = await ref
                                .read(
                                  adminContributionActionsControllerProvider(
                                    args,
                                  ).notifier,
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
                    icon: Icons.rule_outlined,
                    label: adminState.isEvaluating
                        ? 'Evaluating...'
                        : 'Run overdue check',
                  ),
                if (isAdmin) const SizedBox(height: AppSpacing.md),
                _SummarySegmentedHeader(
                  summary: contributionList.summary,
                  selected: _filter,
                  onSelected: (value) => setState(() => _filter = value),
                ),
                const SizedBox(height: AppSpacing.md),
                if (isAdmin && contributionList.summary.late > 0) ...[
                  KitBanner(
                    title: 'Overdue ${contributionList.summary.late}',
                    message:
                        'Late contributions were detected after grace period. Open the Late filter for details.',
                    tone: KitBadgeTone.warning,
                    icon: Icons.warning_amber_rounded,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (canSubmit)
                  KitPrimaryButton(
                    onPressed: () {
                      context.push(
                        AppRoutePaths.groupCycleContributionsSubmit(
                          groupId,
                          cycleId,
                        ),
                      );
                    },
                    icon: Icons.upload_file,
                    label: myContribution == null
                        ? 'Pay now'
                        : 'Update payment',
                  ),
                if (canSubmit) const SizedBox(height: AppSpacing.md),
                if (filteredItems.isEmpty)
                  const KitEmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No contributions',
                    message:
                        'No contribution items match this filter for the selected cycle.',
                  )
                else
                  ...filteredItems.map(
                    (contribution) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _ContributionCard(
                        args: args,
                        contribution: contribution,
                        isAdmin: isAdmin,
                        adminState: adminState,
                        onViewProof: (proofFileKey) async {
                          await _viewProof(context, ref, proofFileKey);
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummarySegmentedHeader extends StatelessWidget {
  const _SummarySegmentedHeader({
    required this.summary,
    required this.selected,
    required this.onSelected,
  });

  final ContributionSummaryModel summary;
  final _ContributionFilter selected;
  final ValueChanged<_ContributionFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return KitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: AppSpacing.xs,
              children: [
                _FilterChip(
                  label: 'All (${summary.total})',
                  selected: selected == _ContributionFilter.all,
                  onTap: () => onSelected(_ContributionFilter.all),
                ),
                _FilterChip(
                  label: 'Pending (${summary.pending})',
                  selected: selected == _ContributionFilter.pending,
                  onTap: () => onSelected(_ContributionFilter.pending),
                ),
                _FilterChip(
                  label: 'Late (${summary.late})',
                  selected: selected == _ContributionFilter.late,
                  onTap: () => onSelected(_ContributionFilter.late),
                ),
                _FilterChip(
                  label: 'Submitted (${summary.submitted})',
                  selected: selected == _ContributionFilter.submitted,
                  onTap: () => onSelected(_ContributionFilter.submitted),
                ),
                _FilterChip(
                  label: 'Confirmed (${summary.confirmed})',
                  selected: selected == _ContributionFilter.confirmed,
                  onTap: () => onSelected(_ContributionFilter.confirmed),
                ),
                _FilterChip(
                  label: 'Rejected (${summary.rejected})',
                  selected: selected == _ContributionFilter.rejected,
                  onTap: () => onSelected(_ContributionFilter.rejected),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _CycleHeaderCard extends StatelessWidget {
  const _CycleHeaderCard({required this.cycleAsync});

  final AsyncValue<CycleModel> cycleAsync;

  @override
  Widget build(BuildContext context) {
    return KitCard(
      child: cycleAsync.when(
        loading: () => const KitSkeletonBox(height: 72),
        error: (error, _) => Text(error.toString()),
        data: (cycle) {
          final statusLabel = switch (cycle.status) {
            CycleStatusModel.open => 'OPEN',
            CycleStatusModel.closed => 'CLOSED',
            CycleStatusModel.unknown => 'UNKNOWN',
          };

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cycle #${cycle.cycleNo}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text('Due date: ${formatDate(cycle.dueDate)}'),
              const SizedBox(height: AppSpacing.xs),
              Text('Recipient: ${_recipientLabel(cycle)}'),
              const SizedBox(height: AppSpacing.xs),
              StatusPill.fromLabel(statusLabel),
            ],
          );
        },
      ),
    );
  }
}

class _ContributionCard extends ConsumerWidget {
  const _ContributionCard({
    required this.args,
    required this.contribution,
    required this.isAdmin,
    required this.adminState,
    required this.onViewProof,
  });

  final CycleContributionsArgs args;
  final ContributionModel contribution;
  final bool isAdmin;
  final AdminContributionActionsState adminState;
  final Future<void> Function(String proofFileKey) onViewProof;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusLabel = switch (contribution.status) {
      ContributionStatusModel.pending => 'PENDING',
      ContributionStatusModel.late => 'LATE',
      ContributionStatusModel.paidSubmitted => 'PAID_SUBMITTED',
      ContributionStatusModel.verified => 'VERIFIED',
      ContributionStatusModel.submitted => 'SUBMITTED',
      ContributionStatusModel.confirmed => 'CONFIRMED',
      ContributionStatusModel.rejected => 'REJECTED',
      ContributionStatusModel.unknown => 'UNKNOWN',
    };

    final isActionLoading =
        adminState.isLoading &&
        adminState.activeContributionId == contribution.id;
    final hasProof = contribution.proofFileKey?.trim().isNotEmpty == true;

    return KitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              KitAvatar(name: contribution.displayName),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  contribution.displayName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              StatusPill.fromLabel(statusLabel),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Amount: ${contribution.amount}'),
          if (contribution.submittedAt != null)
            Text(
              'Submitted: ${formatDate(contribution.submittedAt!, includeTime: true)}',
            ),
          if (contribution.confirmedAt != null)
            Text(
              'Confirmed: ${formatDate(contribution.confirmedAt!, includeTime: true)}',
            ),
          if (contribution.rejectedAt != null)
            Text(
              'Rejected: ${formatDate(contribution.rejectedAt!, includeTime: true)}',
            ),
          if (contribution.rejectReason != null &&
              contribution.rejectReason!.trim().isNotEmpty)
            Text('Reason: ${contribution.rejectReason}'),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if (hasProof)
                KitSecondaryButton(
                  onPressed: () => onViewProof(contribution.proofFileKey!),
                  icon: Icons.receipt_long,
                  label: 'View proof',
                  expand: false,
                ),
              if (isAdmin &&
                  (contribution.status ==
                          ContributionStatusModel.paidSubmitted ||
                      contribution.status == ContributionStatusModel.submitted))
                KitTertiaryButton(
                  onPressed: isActionLoading
                      ? null
                      : () => _showAdminActionsSheet(
                          context,
                          ref,
                          args,
                          contribution,
                        ),
                  icon: Icons.more_horiz,
                  label: 'Admin actions',
                ),
              KitTertiaryButton(
                onPressed: () => context.push(
                  AppRoutePaths.groupCycleContributionDisputes(
                    args.groupId,
                    args.cycleId,
                    contribution.id,
                  ),
                ),
                icon: Icons.report_gmailerrorred_outlined,
                label: 'Report mismatch',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _showAdminActionsSheet(
  BuildContext context,
  WidgetRef ref,
  CycleContributionsArgs args,
  ContributionModel contribution,
) async {
  await KitActionSheet.show(
    context: context,
    title: 'Admin actions',
    actions: [
      KitActionSheetItem(
        label: 'Verify contribution',
        icon: Icons.check_circle_outline,
        onPressed: () async {
          final success = await ref
              .read(adminContributionActionsControllerProvider(args).notifier)
              .confirm(contribution.id);
          if (!context.mounted) {
            return;
          }
          if (success) {
            KitToast.success(context, 'Contribution verified');
          }
        },
      ),
      KitActionSheetItem(
        label: 'Reject contribution',
        icon: Icons.cancel_outlined,
        isDestructive: true,
        onPressed: () async {
          final reason = await _promptRejectReason(context);
          if (!context.mounted || reason == null) {
            return;
          }
          final success = await ref
              .read(adminContributionActionsControllerProvider(args).notifier)
              .reject(contribution.id, reason);
          if (!context.mounted) {
            return;
          }
          if (success) {
            KitToast.success(context, 'Contribution rejected');
          }
        },
      ),
    ],
  );
}

bool _matchesFilter(
  _ContributionFilter filter,
  ContributionStatusModel status,
) {
  return switch (filter) {
    _ContributionFilter.all => true,
    _ContributionFilter.pending => status == ContributionStatusModel.pending,
    _ContributionFilter.late => status == ContributionStatusModel.late,
    _ContributionFilter.submitted =>
      status == ContributionStatusModel.paidSubmitted ||
          status == ContributionStatusModel.submitted,
    _ContributionFilter.confirmed =>
      status == ContributionStatusModel.verified ||
          status == ContributionStatusModel.confirmed,
    _ContributionFilter.rejected => status == ContributionStatusModel.rejected,
  };
}

String _recipientLabel(CycleModel cycle) {
  final fullName = cycle.payoutUser?.fullName?.trim();
  if (fullName != null && fullName.isNotEmpty) {
    return fullName;
  }

  final phone = cycle.payoutUser?.phone?.trim();
  if (phone != null && phone.isNotEmpty) {
    return phone;
  }

  return cycle.payoutUserId;
}

Future<String?> _promptRejectReason(BuildContext context) async {
  return promptText(
    context: context,
    title: 'Reject contribution',
    label: 'Reason',
    hint: 'Explain what should be corrected',
    submitLabel: 'Reject',
  );
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
                      'Proof',
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
                          child: Text('Could not load proof image.'),
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
