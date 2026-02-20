import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/bootstrap.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/cycle_model.dart';
import '../../../data/models/group_model.dart';
import '../../../data/models/payout_model.dart';
import '../../../features/auth/auth_controller.dart';
import '../../../shared/utils/api_error_mapper.dart';
import '../../../shared/utils/date_formatter.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../cycles/cycle_detail_provider.dart';
import '../../groups/group_detail_controller.dart';
import '../cycle_payout_provider.dart';
import '../payout_action_controller.dart';

class PayoutScreen extends ConsumerStatefulWidget {
  const PayoutScreen({super.key, required this.groupId, required this.cycleId});

  final String groupId;
  final String cycleId;

  @override
  ConsumerState<PayoutScreen> createState() => _PayoutScreenState();
}

class _PayoutScreenState extends ConsumerState<PayoutScreen> {
  late final TextEditingController _confirmPaymentRefController;
  late final TextEditingController _confirmNoteController;

  @override
  void initState() {
    super.initState();
    _confirmPaymentRefController = TextEditingController();
    _confirmNoteController = TextEditingController();
  }

  @override
  void dispose() {
    _confirmPaymentRefController.dispose();
    _confirmNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = (groupId: widget.groupId, cycleId: widget.cycleId);
    final groupAsync = ref.watch(groupDetailProvider(widget.groupId));
    final cycleAsync = ref.watch(
      cycleDetailProvider((groupId: widget.groupId, cycleId: widget.cycleId)),
    );
    final payoutAsync = ref.watch(cyclePayoutProvider(widget.cycleId));
    final membersAsync = ref.watch(groupMembersProvider(widget.groupId));
    final currentUser = ref.watch(currentUserProvider);
    final actionState = ref.watch(payoutActionControllerProvider(args));

    ref.listen(payoutActionControllerProvider(args), (previous, next) {
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

    Future<void> onRefresh() async {
      ref.read(payoutsRepositoryProvider).invalidatePayout(widget.cycleId);
      ref
          .read(cyclesRepositoryProvider)
          .invalidateCycleDetail(widget.groupId, widget.cycleId);
      ref.read(cyclesRepositoryProvider).invalidateGroupCache(widget.groupId);
      ref.read(groupsRepositoryProvider).invalidateGroup(widget.groupId);
      ref.read(groupsRepositoryProvider).invalidateMembers(widget.groupId);

      ref.invalidate(cyclePayoutProvider(widget.cycleId));
      ref.invalidate(
        cycleDetailProvider((groupId: widget.groupId, cycleId: widget.cycleId)),
      );
      ref.invalidate(groupDetailProvider(widget.groupId));
      ref.invalidate(groupMembersProvider(widget.groupId));

      await Future.wait([
        ref.read(cyclePayoutProvider(widget.cycleId).future),
        ref.read(
          cycleDetailProvider((
            groupId: widget.groupId,
            cycleId: widget.cycleId,
          )).future,
        ),
      ]);
    }

    final group = groupAsync.valueOrNull;
    final members = membersAsync.valueOrNull;

    var isAdmin = false;
    if (group?.membership?.role == MemberRoleModel.admin) {
      isAdmin = true;
    } else if (currentUser != null && members != null) {
      for (final member in members) {
        if (member.userId == currentUser.id &&
            member.status == MemberStatusModel.active &&
            member.role == MemberRoleModel.admin) {
          isAdmin = true;
          break;
        }
      }
    }

    final activeMembersCount =
        members
            ?.where((member) => member.status == MemberStatusModel.active)
            .length ??
        0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payout'),
        automaticallyImplyLeading: false,
        leading: context.canPop() ? const BackButton() : null,
      ),
      body: SafeArea(
        child: groupAsync.when(
          loading: () => const LoadingView(message: 'Loading payout...'),
          error: (error, _) => ErrorView(
            message: error.toString(),
            onRetry: () => ref
                .read(groupDetailControllerProvider)
                .refreshAll(widget.groupId),
          ),
          data: (_) {
            return cycleAsync.when(
              loading: () => const LoadingView(message: 'Loading cycle...'),
              error: (error, _) => ErrorView(
                message: error.toString(),
                onRetry: () => ref.invalidate(
                  cycleDetailProvider((
                    groupId: widget.groupId,
                    cycleId: widget.cycleId,
                  )),
                ),
              ),
              data: (cycleData) {
                return payoutAsync.when(
                  loading: () =>
                      const LoadingView(message: 'Loading payout...'),
                  error: (error, _) => ErrorView(
                    message: error.toString(),
                    onRetry: () =>
                        ref.invalidate(cyclePayoutProvider(widget.cycleId)),
                  ),
                  data: (payout) => RefreshIndicator(
                    onRefresh: onRefresh,
                    child: ListView(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      children: [
                        _CycleHeaderCard(cycle: cycleData),
                        const SizedBox(height: AppSpacing.md),
                        _PayoutStatusCard(
                          payout: payout,
                          onViewProof: (proofFileKey) =>
                              _viewProof(context, ref, proofFileKey),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _PayoutTimelineCard(cycle: cycleData, payout: payout),
                        const SizedBox(height: AppSpacing.md),
                        if (payout == null)
                          _CreatePayoutSection(
                            isAdmin: isAdmin,
                            defaultAmount:
                                (group?.contributionAmount ?? 0) *
                                (activeMembersCount > 0
                                    ? activeMembersCount
                                    : 1),
                            isLoading: actionState.isLoading,
                            onCreatePressed: isAdmin
                                ? () => _showCreatePayoutDialog(
                                    context: context,
                                    defaultAmount:
                                        (group?.contributionAmount ?? 0) *
                                        (activeMembersCount > 0
                                            ? activeMembersCount
                                            : 1),
                                    onSubmit:
                                        ({
                                          required amount,
                                          paymentRef,
                                          note,
                                        }) async {
                                          final success = await ref
                                              .read(
                                                payoutActionControllerProvider(
                                                  args,
                                                ).notifier,
                                              )
                                              .createPayout(
                                                amount: amount,
                                                paymentRef: paymentRef,
                                                note: note,
                                              );

                                          if (!context.mounted) {
                                            return;
                                          }

                                          if (success) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Payout created.',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                  )
                                : null,
                          ),
                        if (payout != null)
                          _PayoutActionsSection(
                            args: args,
                            cycle: cycleData,
                            payout: payout,
                            isAdmin: isAdmin,
                            actionState: actionState,
                            confirmPaymentRefController:
                                _confirmPaymentRefController,
                            confirmNoteController: _confirmNoteController,
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _CycleHeaderCard extends StatelessWidget {
  const _CycleHeaderCard({required this.cycle});

  final CycleModel cycle;

  @override
  Widget build(BuildContext context) {
    final statusLabel = switch (cycle.status) {
      CycleStatusModel.open => 'OPEN',
      CycleStatusModel.closed => 'CLOSED',
      CycleStatusModel.unknown => 'UNKNOWN',
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cycle #${cycle.cycleNo}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('Due date: ${formatFriendlyDate(cycle.dueDate)}'),
            const SizedBox(height: AppSpacing.xs),
            Text('Recipient: ${_cycleRecipientLabel(cycle)}'),
            const SizedBox(height: AppSpacing.xs),
            Chip(label: Text(statusLabel)),
          ],
        ),
      ),
    );
  }
}

class _PayoutStatusCard extends StatelessWidget {
  const _PayoutStatusCard({required this.payout, required this.onViewProof});

  final PayoutModel? payout;
  final Future<void> Function(String proofFileKey) onViewProof;

  @override
  Widget build(BuildContext context) {
    if (payout == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            'Payout not recorded yet.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    final statusLabel = switch (payout!.status) {
      PayoutStatusModel.pending => 'PENDING',
      PayoutStatusModel.confirmed => 'CONFIRMED',
      PayoutStatusModel.unknown => 'UNKNOWN',
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Payout status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Chip(label: Text(statusLabel)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('Amount: ${payout!.amount}'),
            const SizedBox(height: AppSpacing.xs),
            Text('Recipient: ${payout!.recipientLabel}'),
            if (payout!.paymentRef != null &&
                payout!.paymentRef!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text('Payment ref: ${payout!.paymentRef}'),
              ),
            if (payout!.note != null && payout!.note!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text('Note: ${payout!.note}'),
              ),
            if (payout!.confirmedAt != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  'Confirmed: ${formatFriendlyDate(payout!.confirmedAt!)}',
                ),
              ),
            if (payout!.proofFileKey != null &&
                payout!.proofFileKey!.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () => onViewProof(payout!.proofFileKey!),
                icon: const Icon(Icons.receipt_long),
                label: const Text('View proof'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PayoutTimelineCard extends StatelessWidget {
  const _PayoutTimelineCard({required this.cycle, required this.payout});

  final CycleModel cycle;
  final PayoutModel? payout;

  @override
  Widget build(BuildContext context) {
    final isCreated = payout != null;
    final isConfirmed = payout?.status == PayoutStatusModel.confirmed;
    final isClosed = cycle.status == CycleStatusModel.closed;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payout timeline',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            _TimelineRow(
              label: 'Payout created',
              done: isCreated,
              detail: isCreated ? 'Recorded by admin' : 'Pending',
            ),
            _TimelineRow(
              label: 'Payout confirmed',
              done: isConfirmed,
              detail: isConfirmed ? 'Confirmed and locked' : 'Pending',
            ),
            _TimelineRow(
              label: 'Cycle closed',
              done: isClosed,
              detail: isClosed ? 'Cycle completed' : 'Pending',
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.label,
    required this.done,
    required this.detail,
  });

  final String label;
  final bool done;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: done ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  detail,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
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

class _CreatePayoutSection extends StatelessWidget {
  const _CreatePayoutSection({
    required this.isAdmin,
    required this.defaultAmount,
    required this.isLoading,
    required this.onCreatePressed,
  });

  final bool isAdmin;
  final int defaultAmount;
  final bool isLoading;
  final Future<void> Function()? onCreatePressed;

  @override
  Widget build(BuildContext context) {
    if (!isAdmin) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            'Waiting for admin to record payout.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No payout exists yet.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('Suggested amount: $defaultAmount'),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: 'Create payout',
              isLoading: isLoading,
              onPressed: isLoading || onCreatePressed == null
                  ? null
                  : () => onCreatePressed!(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayoutActionsSection extends ConsumerWidget {
  const _PayoutActionsSection({
    required this.args,
    required this.cycle,
    required this.payout,
    required this.isAdmin,
    required this.actionState,
    required this.confirmPaymentRefController,
    required this.confirmNoteController,
  });

  final PayoutActionArgs args;
  final CycleModel cycle;
  final PayoutModel payout;
  final bool isAdmin;
  final PayoutActionState actionState;
  final TextEditingController confirmPaymentRefController;
  final TextEditingController confirmNoteController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isAdmin) {
      if (payout.status == PayoutStatusModel.confirmed) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'Payout is confirmed.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        );
      }

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            'Waiting for admin confirmation.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    final canConfirm = payout.status == PayoutStatusModel.pending;
    final canClose =
        payout.status == PayoutStatusModel.confirmed &&
        cycle.status == CycleStatusModel.open;

    return Column(
      children: [
        if (canConfirm)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confirm payout',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: confirmPaymentRefController,
                    decoration: const InputDecoration(
                      labelText: 'Payment ref (optional)',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: confirmNoteController,
                    decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      OutlinedButton.icon(
                        onPressed: actionState.isLoading
                            ? null
                            : () {
                                ref
                                    .read(
                                      payoutActionControllerProvider(
                                        args,
                                      ).notifier,
                                    )
                                    .pickProofFromCamera();
                              },
                        icon: const Icon(Icons.photo_camera),
                        label: const Text('Camera proof'),
                      ),
                      OutlinedButton.icon(
                        onPressed: actionState.isLoading
                            ? null
                            : () {
                                ref
                                    .read(
                                      payoutActionControllerProvider(
                                        args,
                                      ).notifier,
                                    )
                                    .pickProofFromGallery();
                              },
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery proof'),
                      ),
                      if (actionState.hasProof)
                        TextButton(
                          onPressed: actionState.isLoading
                              ? null
                              : () {
                                  ref
                                      .read(
                                        payoutActionControllerProvider(
                                          args,
                                        ).notifier,
                                      )
                                      .clearProof();
                                },
                          child: const Text('Remove proof'),
                        ),
                    ],
                  ),
                  if (actionState.proofImage != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: AppRadius.mdRounded,
                      child: Image.memory(
                        actionState.proofImage!.bytes,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                  if (actionState.actionType ==
                          PayoutActionType.uploadingProof ||
                      actionState.actionType ==
                          PayoutActionType.confirming) ...[
                    const SizedBox(height: AppSpacing.md),
                    LinearProgressIndicator(value: actionState.uploadProgress),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      actionState.actionType == PayoutActionType.uploadingProof
                          ? 'Uploading payout proof...'
                          : 'Confirming payout...',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (actionState.errorMessage != null &&
                      actionState.errorMessage!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      actionState.errorMessage!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    if (actionState.errorMessage!.toLowerCase().contains(
                      'review contributions',
                    ))
                      TextButton(
                        onPressed: () => context.push(
                          AppRoutePaths.groupCycleContributions(
                            args.groupId,
                            args.cycleId,
                          ),
                        ),
                        child: const Text('View contributions'),
                      ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: 'Confirm payout',
                    isLoading: actionState.isLoading,
                    onPressed: actionState.isLoading
                        ? null
                        : () async {
                            final success = await ref
                                .read(
                                  payoutActionControllerProvider(args).notifier,
                                )
                                .confirmPayout(
                                  payoutId: payout.id,
                                  paymentRef: confirmPaymentRefController.text,
                                  note: confirmNoteController.text,
                                );

                            if (!context.mounted) {
                              return;
                            }

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Payout confirmed.'),
                                ),
                              );
                            }
                          },
                  ),
                ],
              ),
            ),
          ),
        if (canClose)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Close cycle',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Payout is confirmed. You can close this cycle now.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: 'Close cycle',
                    isLoading:
                        actionState.isLoading &&
                        actionState.actionType == PayoutActionType.closing,
                    onPressed: actionState.isLoading
                        ? null
                        : () async {
                            final shouldClose = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) {
                                return AlertDialog(
                                  title: const Text('Close this cycle?'),
                                  content: const Text(
                                    'This will mark the cycle as CLOSED. This action cannot be undone.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(
                                        dialogContext,
                                      ).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.of(dialogContext).pop(true),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (shouldClose != true) {
                              return;
                            }

                            final success = await ref
                                .read(
                                  payoutActionControllerProvider(args).notifier,
                                )
                                .closeCycle();

                            if (!context.mounted) {
                              return;
                            }

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Cycle closed.')),
                              );
                              if (context.canPop()) {
                                context.pop();
                              }
                              if (context.canPop()) {
                                context.pop();
                              }
                            }
                          },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

Future<void> _showCreatePayoutDialog({
  required BuildContext context,
  required int defaultAmount,
  required Future<void> Function({
    required int amount,
    String? paymentRef,
    String? note,
  })
  onSubmit,
}) async {
  final amountController = TextEditingController(
    text: defaultAmount > 0 ? defaultAmount.toString() : '',
  );
  final paymentRefController = TextEditingController();
  final noteController = TextEditingController();
  String? validationError;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: const Text('Create payout'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Amount'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: paymentRefController,
                    decoration: const InputDecoration(
                      labelText: 'Payment ref (optional)',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                    ),
                  ),
                  if (validationError != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      validationError!,
                      style: Theme.of(dialogContext).textTheme.bodySmall
                          ?.copyWith(
                            color: Theme.of(dialogContext).colorScheme.error,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final amount = int.tryParse(amountController.text.trim());
                  if (amount == null || amount <= 0) {
                    setDialogState(() {
                      validationError = 'Amount must be greater than 0.';
                    });
                    return;
                  }

                  await onSubmit(
                    amount: amount,
                    paymentRef: paymentRefController.text,
                    note: noteController.text,
                  );

                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: const Text('Create'),
              ),
            ],
          );
        },
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
                      'Payout proof',
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

String _cycleRecipientLabel(CycleModel cycle) {
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
