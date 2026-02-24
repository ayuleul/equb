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
  bool _autoNext = true;

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
                      _PhaseFiveActionsSection(
                        args: args,
                        cycle: cycleData,
                        payout: payout,
                        isAdmin: isAdmin,
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
                        autoNext: _autoNext,
                        onAutoNextChanged: (value) {
                          setState(() {
                            _autoNext = value;
                          });
                        },
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
    final collectionComplete =
        cycle.state == CycleStateModel.readyForPayout ||
        cycle.state == CycleStateModel.disbursed ||
        cycle.state == CycleStateModel.closed;
    final winnerSelected =
        payout != null ||
        cycle.state == CycleStateModel.disbursed ||
        cycle.state == CycleStateModel.closed;
    final isDisbursed = payout?.status == PayoutStatusModel.confirmed;
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
            label: 'Collection complete',
            done: collectionComplete,
            detail: collectionComplete ? 'Ready for payout stage' : 'Pending',
          ),
          _TimelineRow(
            label: 'Winner selected',
            done: winnerSelected,
            detail: winnerSelected ? 'Winner set for cycle' : 'Pending',
          ),
          _TimelineRow(
            label: 'Payout disbursed',
            done: isDisbursed,
            detail: isDisbursed ? 'Disbursement recorded' : 'Pending',
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

class _PhaseFiveActionsSection extends ConsumerWidget {
  const _PhaseFiveActionsSection({
    required this.args,
    required this.cycle,
    required this.isAdmin,
    required this.payout,
    required this.actionState,
    required this.rules,
    required this.members,
    required this.decisionWinnerUserId,
    required this.onDecisionWinnerChanged,
    required this.disbursePaymentRefController,
    required this.disburseNoteController,
    required this.autoNext,
    required this.onAutoNextChanged,
  });

  final PayoutActionArgs args;
  final CycleModel cycle;
  final bool isAdmin;
  final PayoutModel? payout;
  final PayoutActionState actionState;
  final GroupRulesModel? rules;
  final List<MemberModel> members;
  final String? decisionWinnerUserId;
  final ValueChanged<String?> onDecisionWinnerChanged;
  final TextEditingController disbursePaymentRefController;
  final TextEditingController disburseNoteController;
  final bool autoNext;
  final ValueChanged<bool> onAutoNextChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isAdmin) {
      return KitCard(
        child: Text(
          payout?.status == PayoutStatusModel.confirmed
              ? 'Payout is disbursed.'
              : 'Waiting for admin payout actions.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final isReadyForPayout = cycle.state == CycleStateModel.readyForPayout;
    final isPayoutDisbursed = payout?.status == PayoutStatusModel.confirmed;
    final canSelectAndDisburse =
        isReadyForPayout &&
        cycle.status == CycleStatusModel.open &&
        !isPayoutDisbursed;
    final canClose = isPayoutDisbursed && cycle.status == CycleStatusModel.open;

    if (!canSelectAndDisburse && !canClose) {
      return KitCard(
        child: Text(
          isPayoutDisbursed
              ? 'Payout is disbursed. Close cycle to continue.'
              : 'Winner selection becomes available when cycle is READY_FOR_PAYOUT.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return Column(
      children: [
        if (canSelectAndDisburse)
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
        if (canSelectAndDisburse)
          KitCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Disburse payout',
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
                        : 'Disbursing payout...',
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
                  label: 'Disburse payout',
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
                              );

                          if (!context.mounted) {
                            return;
                          }

                          if (success) {
                            KitToast.success(context, 'Payout disbursed.');
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
                const SizedBox(height: AppSpacing.sm),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Auto-start next cycle'),
                  value: autoNext,
                  onChanged: actionState.isLoading ? null : onAutoNextChanged,
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
                              .closeCycle(autoNext: autoNext);

                          if (!context.mounted) {
                            return;
                          }

                          if (success) {
                            KitToast.success(context, 'Cycle closed.');
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
          .selectWinner(userId: userId);

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
          DropdownButtonFormField<String>(
            initialValue: decisionWinnerUserId,
            decoration: const InputDecoration(
              labelText: 'Choose winner',
              border: OutlineInputBorder(),
            ),
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
