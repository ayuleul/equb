import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/bootstrap.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/cycle_model.dart';
import '../../../data/models/group_model.dart';
import '../../../data/models/group_rules_model.dart';
import '../../../data/models/member_model.dart';
import '../../../data/models/member_status_utils.dart';
import '../../../data/models/payout_model.dart';
import '../../../features/auth/auth_controller.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/utils/api_error_mapper.dart';
import '../../../shared/utils/date_formatter.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../cycles/cycle_detail_provider.dart';
import '../../groups/group_detail_controller.dart';
import '../../groups/group_rules_provider.dart';
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
  late final TextEditingController _disbursePaymentRefController;
  late final TextEditingController _disburseNoteController;
  String? _decisionWinnerUserId;

  @override
  void initState() {
    super.initState();
    _disbursePaymentRefController = TextEditingController();
    _disburseNoteController = TextEditingController();
  }

  @override
  void dispose() {
    _disbursePaymentRefController.dispose();
    _disburseNoteController.dispose();
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
    final rulesAsync = ref.watch(groupRulesProvider(widget.groupId));
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
            isParticipatingMemberStatus(member.status) &&
            member.role == MemberRoleModel.admin) {
          isAdmin = true;
          break;
        }
      }
    }

    return KitScaffold(
      appBar: const KitAppBar(title: 'Payout details'),
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
                      _PhaseFiveActionsSection(
                        args: args,
                        cycle: cycleData,
                        payout: payout,
                        isAdmin: isAdmin,
                        currentUserId: currentUser?.id,
                        actionState: actionState,
                        rules: rulesAsync.valueOrNull,
                        members: members ?? const [],
                        decisionWinnerUserId: _decisionWinnerUserId,
                        onDecisionWinnerChanged: (userId) {
                          setState(() {
                            _decisionWinnerUserId = userId;
                          });
                        },
                        disbursePaymentRefController:
                            _disbursePaymentRefController,
                        disburseNoteController: _disburseNoteController,
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
            'Turn ${cycle.cycleNo}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Due date: ${formatFriendlyDate(cycle.dueDate)}'),
          const SizedBox(height: AppSpacing.xs),
          Text('Selected winner: ${_selectedWinnerLabel(cycle)}'),
          if (_selectedWinnerLabel(cycle) != _cycleRecipientLabel(cycle))
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
      PayoutStatusModel.pending => 'SENT',
      PayoutStatusModel.confirmed => 'RECEIVED',
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
                'Receipt confirmed: ${formatFriendlyDate(payout!.confirmedAt!)}',
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
    final collectionComplete =
        cycle.state == CycleStateModel.readyForWinnerSelection ||
        cycle.state == CycleStateModel.readyForPayout ||
        cycle.state == CycleStateModel.payoutSent ||
        cycle.state == CycleStateModel.completed;
    final winnerSelected = cycle.selectedWinnerUserId != null || payout != null;
    final payoutSent =
        cycle.state == CycleStateModel.payoutSent ||
        payout?.status == PayoutStatusModel.pending;
    final receiptConfirmed =
        payout?.status == PayoutStatusModel.confirmed ||
        cycle.state == CycleStateModel.completed;

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
            label: 'Collection complete',
            done: collectionComplete,
            detail: collectionComplete ? 'Winner step unlocked' : 'Pending',
          ),
          _TimelineRow(
            label: 'Winner selected',
            done: winnerSelected,
            detail: winnerSelected ? 'Winner set for cycle' : 'Pending',
          ),
          _TimelineRow(
            label: 'Payout sent',
            done: payoutSent,
            detail: payoutSent ? 'Admin marked payout as sent' : 'Pending',
          ),
          _TimelineRow(
            label: 'Recipient confirmed receipt',
            done: receiptConfirmed,
            detail: receiptConfirmed ? 'Turn completed' : 'Pending',
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

class _PhaseFiveActionsSection extends ConsumerWidget {
  const _PhaseFiveActionsSection({
    required this.args,
    required this.cycle,
    required this.isAdmin,
    required this.currentUserId,
    required this.payout,
    required this.actionState,
    required this.rules,
    required this.members,
    required this.decisionWinnerUserId,
    required this.onDecisionWinnerChanged,
    required this.disbursePaymentRefController,
    required this.disburseNoteController,
  });

  final PayoutActionArgs args;
  final CycleModel cycle;
  final bool isAdmin;
  final String? currentUserId;
  final PayoutModel? payout;
  final PayoutActionState actionState;
  final GroupRulesModel? rules;
  final List<MemberModel> members;
  final String? decisionWinnerUserId;
  final ValueChanged<String?> onDecisionWinnerChanged;
  final TextEditingController disbursePaymentRefController;
  final TextEditingController disburseNoteController;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receiptConfirmerUserId =
        cycle.selectedWinnerUserId ??
        payout?.toUserId ??
        cycle.finalPayoutUserId ??
        cycle.payoutUserId;
    final isWinner = receiptConfirmerUserId == currentUserId;

    if (!isAdmin && !isWinner) {
      return KitCard(
        child: Text(
          payout?.status == PayoutStatusModel.confirmed
              ? 'Turn completed.'
              : 'Waiting for the next payout action.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final canSelectWinner =
        isAdmin &&
        cycle.state == CycleStateModel.readyForWinnerSelection &&
        cycle.status == CycleStatusModel.open;
    final canSendPayout =
        isAdmin &&
        cycle.state == CycleStateModel.readyForPayout &&
        cycle.status == CycleStatusModel.open;
    final canConfirmReceipt =
        isWinner &&
        cycle.state == CycleStateModel.payoutSent &&
        payout?.status != PayoutStatusModel.confirmed;

    if (!canSelectWinner && !canSendPayout && !canConfirmReceipt) {
      return KitCard(
        child: Text(
          cycle.state == CycleStateModel.completed ||
                  payout?.status == PayoutStatusModel.confirmed
              ? 'Turn completed.'
              : 'This turn will unlock the next payout action automatically as it progresses.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return Column(
      children: [
        if (canSelectWinner)
          KitCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select winner',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                _WinnerSelectionContent(
                  args: args,
                  cycle: cycle,
                  rules: rules,
                  members: members,
                  decisionWinnerUserId: decisionWinnerUserId,
                  onDecisionWinnerChanged: onDecisionWinnerChanged,
                  actionState: actionState,
                ),
              ],
            ),
          ),
        if (canSendPayout)
          KitCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mark payout sent',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                KitTextField(
                  controller: disbursePaymentRefController,
                  label: 'Payment ref (optional)',
                ),
                const SizedBox(height: AppSpacing.md),
                KitTextArea(
                  controller: disburseNoteController,
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
                    actionState.actionType == PayoutActionType.disbursing) ...[
                  const SizedBox(height: AppSpacing.md),
                  LinearProgressIndicator(value: actionState.uploadProgress),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    actionState.actionType == PayoutActionType.uploadingProof
                        ? 'Uploading payout proof...'
                        : 'Saving payout send...',
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
                ],
                const SizedBox(height: AppSpacing.md),
                KitPrimaryButton(
                  label: 'Mark payout sent',
                  isLoading:
                      actionState.isLoading &&
                      actionState.actionType == PayoutActionType.disbursing,
                  onPressed: actionState.isLoading
                      ? null
                      : () async {
                          final success = await ref
                              .read(
                                payoutActionControllerProvider(args).notifier,
                              )
                              .disbursePayout(
                                paymentRef: disbursePaymentRefController.text,
                                note: disburseNoteController.text,
                                preferSocketSync: true,
                              );

                          if (!context.mounted) {
                            return;
                          }

                          if (success) {
                            KitToast.success(context, 'Payout marked as sent.');
                          }
                        },
                ),
              ],
            ),
          ),
        if (canConfirmReceipt)
          KitCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Confirm receipt',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Confirm that you received the payout. This completes the turn.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                KitPrimaryButton(
                  label: 'Confirm receipt',
                  isLoading:
                      actionState.isLoading &&
                      actionState.actionType == PayoutActionType.confirming,
                  onPressed: actionState.isLoading
                      ? null
                      : () async {
                          final shouldConfirm = await KitDialog.confirm(
                            context: context,
                            title: 'Confirm payout receipt?',
                            message: 'This will mark the turn as completed.',
                            confirmLabel: 'Confirm receipt',
                          );

                          if (shouldConfirm != true) {
                            return;
                          }

                          final success = await ref
                              .read(
                                payoutActionControllerProvider(args).notifier,
                              )
                              .confirmPayoutReceived(preferSocketSync: true);

                          if (!context.mounted) {
                            return;
                          }

                          if (success) {
                            KitToast.success(context, 'Turn completed.');
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

class _WinnerSelectionContent extends ConsumerWidget {
  const _WinnerSelectionContent({
    required this.args,
    required this.cycle,
    required this.rules,
    required this.members,
    required this.decisionWinnerUserId,
    required this.onDecisionWinnerChanged,
    required this.actionState,
  });

  final PayoutActionArgs args;
  final CycleModel cycle;
  final GroupRulesModel? rules;
  final List<MemberModel> members;
  final String? decisionWinnerUserId;
  final ValueChanged<String?> onDecisionWinnerChanged;
  final PayoutActionState actionState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = rules?.payoutMode ?? GroupRulePayoutModeModel.unknown;
    final requiresVerification = rules?.requiresMemberVerification ?? false;
    final eligibleMembers = members
        .where(
          (member) => requiresVerification
              ? isVerifiedMemberStatus(member.status)
              : isParticipatingMemberStatus(member.status),
        )
        .toList(growable: false);

    final isSelecting =
        actionState.isLoading &&
        actionState.actionType == PayoutActionType.selectingWinner;

    Future<void> runSelection({String? userId}) async {
      final success = await ref
          .read(payoutActionControllerProvider(args).notifier)
          .selectWinner(userId: userId, preferSocketSync: true);

      if (!context.mounted) {
        return;
      }
      if (success) {
        KitToast.success(context, 'Winner selected.');
      }
    }

    final helperText = switch (mode) {
      GroupRulePayoutModeModel.lottery =>
        'Run a turn draw among eligible members.',
      GroupRulePayoutModeModel.auction =>
        'Close bids and select highest bid winner (tie: earliest bid).',
      GroupRulePayoutModeModel.rotation =>
        'System picks the next eligible member in rotation.',
      GroupRulePayoutModeModel.decision =>
        'Admin selects one eligible member manually.',
      GroupRulePayoutModeModel.unknown => 'Ruleset payout mode is unavailable.',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(helperText, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.sm),
        if (mode == GroupRulePayoutModeModel.decision) ...[
          KitDropdownField<String>(
            value: decisionWinnerUserId,
            label: 'Choose winner',
            items: eligibleMembers
                .map(
                  (member) => DropdownMenuItem<String>(
                    value: member.userId,
                    child: Text(member.displayName),
                  ),
                )
                .toList(growable: false),
            onChanged: isSelecting ? null : onDecisionWinnerChanged,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (mode == GroupRulePayoutModeModel.auction)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: KitSecondaryButton(
              onPressed: () => context.push(
                AppRoutePaths.groupCycleDetail(args.groupId, cycle.id),
              ),
              icon: Icons.gavel_rounded,
              label: 'Open bids',
              expand: false,
            ),
          ),
        KitPrimaryButton(
          label: switch (mode) {
            GroupRulePayoutModeModel.lottery => 'Draw winner',
            GroupRulePayoutModeModel.auction => 'Close bids & select winner',
            GroupRulePayoutModeModel.rotation => 'Select next in rotation',
            GroupRulePayoutModeModel.decision => 'Select chosen member',
            GroupRulePayoutModeModel.unknown => 'Winner selection unavailable',
          },
          icon: switch (mode) {
            GroupRulePayoutModeModel.lottery => Icons.casino_outlined,
            GroupRulePayoutModeModel.auction => Icons.gavel_rounded,
            GroupRulePayoutModeModel.rotation => Icons.swap_horiz_rounded,
            GroupRulePayoutModeModel.decision => Icons.how_to_vote_outlined,
            GroupRulePayoutModeModel.unknown => Icons.error_outline,
          },
          isLoading: isSelecting,
          onPressed:
              isSelecting ||
                  mode == GroupRulePayoutModeModel.unknown ||
                  (mode == GroupRulePayoutModeModel.decision &&
                      (decisionWinnerUserId == null ||
                          decisionWinnerUserId!.trim().isEmpty))
              ? null
              : () => runSelection(
                  userId: mode == GroupRulePayoutModeModel.decision
                      ? decisionWinnerUserId
                      : null,
                ),
        ),
      ],
    );
  }
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

String _selectedWinnerLabel(CycleModel cycle) {
  if (cycle.selectedWinnerUserId == null) {
    return 'Pending';
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

  return cycle.selectedWinnerUserId ??
      cycle.finalPayoutUserId ??
      cycle.payoutUserId;
}
