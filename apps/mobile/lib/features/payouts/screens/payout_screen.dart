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
import '../../../shared/kit/kit.dart';
import '../../../shared/utils/api_error_mapper.dart';
import '../../../shared/utils/date_formatter.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
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
        KitToast.error(context, nextError);
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

    return KitScaffold(
      appBar: const KitAppBar(title: 'Payout'),
      child: groupAsync.when(
        loading: () => const LoadingView(message: 'Loading payout...'),
        error: (error, _) => ErrorView(
          message: mapFriendlyError(error),
          onRetry: () => ref
              .read(groupDetailControllerProvider)
              .refreshAll(widget.groupId),
        ),
        data: (_) {
          return cycleAsync.when(
            loading: () => const LoadingView(message: 'Loading cycle...'),
            error: (error, _) => ErrorView(
              message: mapFriendlyError(error),
              onRetry: () => ref.invalidate(
                cycleDetailProvider((
                  groupId: widget.groupId,
                  cycleId: widget.cycleId,
                )),
              ),
            ),
            data: (cycleData) {
              return payoutAsync.when(
                loading: () => const LoadingView(message: 'Loading payout...'),
                error: (error, _) => ErrorView(
                  message: mapFriendlyError(error),
                  onRetry: () =>
                      ref.invalidate(cyclePayoutProvider(widget.cycleId)),
                ),
                data: (payout) => RefreshIndicator(
                  onRefresh: onRefresh,
                  child: ListView(
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
                              (activeMembersCount > 0 ? activeMembersCount : 1),
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
                                          KitToast.success(
                                            context,
                                            'Payout created.',
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

    return KitCard(
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
          Text('Drawn winner: ${_drawnWinnerLabel(cycle)}'),
          if (_drawnWinnerLabel(cycle) != _cycleRecipientLabel(cycle))
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                'Final recipient after auction: ${_cycleRecipientLabel(cycle)}',
              ),
            ),
          const SizedBox(height: AppSpacing.xs),
          StatusPill.fromLabel(statusLabel),
        ],
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
      return KitCard(
        child: Text(
          'Payout not recorded yet.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final statusLabel = switch (payout!.status) {
      PayoutStatusModel.pending => 'PENDING',
      PayoutStatusModel.confirmed => 'CONFIRMED',
      PayoutStatusModel.unknown => 'UNKNOWN',
    };

    return KitCard(
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
              StatusPill.fromLabel(statusLabel),
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
            KitSecondaryButton(
              onPressed: () => onViewProof(payout!.proofFileKey!),
              icon: Icons.receipt_long,
              label: 'View proof',
              expand: false,
            ),
          ],
        ],
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

    return KitCard(
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
      return KitCard(
        child: Text(
          'Waiting for admin to record payout.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return KitCard(
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
          KitPrimaryButton(
            label: 'Create payout',
            isLoading: isLoading,
            onPressed: isLoading || onCreatePressed == null
                ? null
                : () => onCreatePressed!(),
          ),
        ],
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
        return KitCard(
          child: Text(
            'Payout is confirmed.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        );
      }

      return KitCard(
        child: Text(
          'Waiting for admin confirmation.',
          style: Theme.of(context).textTheme.bodyMedium,
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
          KitCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin actions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                KitTextField(
                  controller: confirmPaymentRefController,
                  label: 'Payment ref (optional)',
                ),
                const SizedBox(height: AppSpacing.md),
                KitTextArea(
                  controller: confirmNoteController,
                  label: 'Note (optional)',
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    KitSecondaryButton(
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
                      icon: Icons.photo_camera,
                      label: 'Camera proof',
                      expand: false,
                    ),
                    KitSecondaryButton(
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
                      icon: Icons.photo_library,
                      label: 'Gallery proof',
                      expand: false,
                    ),
                    if (actionState.hasProof)
                      KitTertiaryButton(
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
                        label: 'Remove proof',
                      ),
                  ],
                ),
                if (actionState.proofImage != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: AppRadius.inputRounded,
                    child: Image.memory(
                      actionState.proofImage!.bytes,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                if (actionState.actionType == PayoutActionType.uploadingProof ||
                    actionState.actionType == PayoutActionType.confirming) ...[
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
                    KitTertiaryButton(
                      onPressed: () => context.push(
                        AppRoutePaths.groupCycleContributions(
                          args.groupId,
                          args.cycleId,
                        ),
                      ),
                      label: 'View contributions',
                    ),
                ],
                const SizedBox(height: AppSpacing.md),
                KitPrimaryButton(
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
                            KitToast.success(context, 'Payout confirmed.');
                          }
                        },
                ),
              ],
            ),
          ),
        if (canClose)
          KitCard(
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
                KitPrimaryButton(
                  label: 'Close cycle',
                  isLoading:
                      actionState.isLoading &&
                      actionState.actionType == PayoutActionType.closing,
                  onPressed: actionState.isLoading
                      ? null
                      : () async {
                          final shouldClose = await KitDialog.confirm(
                            context: context,
                            title: 'Close this cycle?',
                            message:
                                'This will mark the cycle as CLOSED. This action cannot be undone.',
                            confirmLabel: 'Close',
                            isDestructive: true,
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
                            KitToast.success(context, 'Cycle closed.');
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
                  KitNumberField(controller: amountController, label: 'Amount'),
                  const SizedBox(height: AppSpacing.md),
                  KitTextField(
                    controller: paymentRefController,
                    label: 'Payment ref (optional)',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  KitTextArea(
                    controller: noteController,
                    label: 'Note (optional)',
                    maxLines: 2,
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

    KitToast.error(context, mapApiErrorToMessage(error));
  }
}

String _cycleRecipientLabel(CycleModel cycle) {
  final user = cycle.finalPayoutUser ?? cycle.payoutUser;
  final fullName = user?.fullName?.trim();
  if (fullName != null && fullName.isNotEmpty) {
    return fullName;
  }

  final phone = user?.phone?.trim();
  if (phone != null && phone.isNotEmpty) {
    return phone;
  }

  return cycle.finalPayoutUserId ?? cycle.payoutUserId;
}

String _drawnWinnerLabel(CycleModel cycle) {
  final user = cycle.scheduledPayoutUser ?? cycle.payoutUser;
  final fullName = user?.fullName?.trim();
  if (fullName != null && fullName.isNotEmpty) {
    return fullName;
  }

  final phone = user?.phone?.trim();
  if (phone != null && phone.isNotEmpty) {
    return phone;
  }

  return cycle.scheduledPayoutUserId ?? cycle.payoutUserId;
}
