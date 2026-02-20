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
import '../../../shared/utils/api_error_mapper.dart';
import '../../../shared/utils/date_formatter.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../cycles/cycle_detail_provider.dart';
import '../../groups/group_detail_controller.dart';
import '../admin_contribution_actions_controller.dart';
import '../cycle_contributions_provider.dart';

class ContributionsListScreen extends ConsumerWidget {
  const ContributionsListScreen({
    super.key,
    required this.groupId,
    required this.cycleId,
  });

  final String groupId;
  final String cycleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(nextError)));
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contributions'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              ref.invalidate(cycleContributionsProvider(args));
              ref.invalidate(
                cycleDetailProvider((groupId: groupId, cycleId: cycleId)),
              );
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: contributionsAsync.when(
          loading: () => const LoadingView(message: 'Loading contributions...'),
          error: (error, _) => ErrorView(
            message: error.toString(),
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

            final cycle = cycleAsync.valueOrNull;
            final canSubmit =
                currentUser != null &&
                (myContribution == null ||
                    myContribution.status !=
                        ContributionStatusModel.confirmed) &&
                cycle?.status == CycleStatusModel.open;

            return RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  _CycleHeaderCard(cycleAsync: cycleAsync),
                  const SizedBox(height: AppSpacing.md),
                  _SummaryCard(summary: contributionList.summary),
                  const SizedBox(height: AppSpacing.md),
                  if (canSubmit)
                    FilledButton.icon(
                      onPressed: () {
                        context.go(
                          AppRoutePaths.groupCycleContributionsSubmit(
                            groupId,
                            cycleId,
                          ),
                        );
                      },
                      icon: const Icon(Icons.upload_file),
                      label: Text(
                        myContribution == null
                            ? 'Submit payment proof'
                            : 'Update payment proof',
                      ),
                    ),
                  if (canSubmit) const SizedBox(height: AppSpacing.md),
                  if (contributionList.items.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          'No contributions yet. Submit your payment proof to get started.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    )
                  else
                    ...contributionList.items.map(
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CycleHeaderCard extends StatelessWidget {
  const _CycleHeaderCard({required this.cycleAsync});

  final AsyncValue<CycleModel> cycleAsync;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: cycleAsync.when(
          loading: () => const Text('Loading cycle info...'),
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
                Text('Due date: ${formatFriendlyDate(cycle.dueDate)}'),
                const SizedBox(height: AppSpacing.xs),
                Text('Recipient: ${_recipientLabel(cycle)}'),
                const SizedBox(height: AppSpacing.xs),
                Chip(label: Text(statusLabel)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final ContributionSummaryModel summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            Chip(label: Text('Total: ${summary.total}')),
            Chip(label: Text('Pending: ${summary.pending}')),
            Chip(label: Text('Submitted: ${summary.submitted}')),
            Chip(label: Text('Confirmed: ${summary.confirmed}')),
            Chip(label: Text('Rejected: ${summary.rejected}')),
          ],
        ),
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
      ContributionStatusModel.submitted => 'SUBMITTED',
      ContributionStatusModel.confirmed => 'CONFIRMED',
      ContributionStatusModel.rejected => 'REJECTED',
      ContributionStatusModel.unknown => 'UNKNOWN',
    };

    final isActionLoading =
        adminState.isLoading &&
        adminState.activeContributionId == contribution.id;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(contribution.displayName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xs),
                  Text('Amount: ${contribution.amount}'),
                  if (contribution.submittedAt != null)
                    Text(
                      'Submitted: ${formatFriendlyDate(contribution.submittedAt!)}',
                    ),
                  if (contribution.confirmedAt != null)
                    Text(
                      'Confirmed: ${formatFriendlyDate(contribution.confirmedAt!)}',
                    ),
                  if (contribution.rejectedAt != null)
                    Text(
                      'Rejected: ${formatFriendlyDate(contribution.rejectedAt!)}',
                    ),
                  if (contribution.rejectReason != null &&
                      contribution.rejectReason!.trim().isNotEmpty)
                    Text('Reason: ${contribution.rejectReason}'),
                ],
              ),
              trailing: Chip(label: Text(statusLabel)),
            ),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                if (contribution.proofFileKey != null &&
                    contribution.proofFileKey!.trim().isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () => onViewProof(contribution.proofFileKey!),
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('View proof'),
                  ),
                if (isAdmin &&
                    contribution.status == ContributionStatusModel.submitted)
                  FilledButton(
                    onPressed: isActionLoading
                        ? null
                        : () async {
                            final success = await ref
                                .read(
                                  adminContributionActionsControllerProvider(
                                    args,
                                  ).notifier,
                                )
                                .confirm(contribution.id);

                            if (!context.mounted) {
                              return;
                            }

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Contribution confirmed.'),
                                ),
                              );
                            }
                          },
                    child: const Text('Confirm'),
                  ),
                if (isAdmin &&
                    contribution.status == ContributionStatusModel.submitted)
                  OutlinedButton(
                    onPressed: isActionLoading
                        ? null
                        : () async {
                            final reason = await _promptRejectReason(context);
                            if (!context.mounted || reason == null) {
                              return;
                            }

                            final success = await ref
                                .read(
                                  adminContributionActionsControllerProvider(
                                    args,
                                  ).notifier,
                                )
                                .reject(contribution.id, reason);

                            if (!context.mounted) {
                              return;
                            }

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Contribution rejected.'),
                                ),
                              );
                            }
                          },
                    child: const Text('Reject'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
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
  final controller = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Reject contribution'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Reason',
            hintText: 'Explain what should be corrected',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final reason = controller.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Reason is required.')),
                );
                return;
              }

              Navigator.of(dialogContext).pop(reason);
            },
            child: const Text('Reject'),
          ),
        ],
      );
    },
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

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mapApiErrorToMessage(error))));
  }
}
