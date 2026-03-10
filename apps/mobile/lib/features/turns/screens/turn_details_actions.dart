part of 'turn_details_screen.dart';

class _TurnAction {
  const _TurnAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.scope,
    required this.kind,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final _TurnActionScope scope;
  final _TurnActionKind kind;
}

class _TurnFooter {
  const _TurnFooter.action(this.action)
    : message = null,
      detail = null,
      icon = null;

  const _TurnFooter.status({
    required this.message,
    required this.detail,
    required this.icon,
  }) : action = null;

  final _TurnAction? action;
  final String? message;
  final String? detail;
  final IconData? icon;

  bool get isAction => action != null;
}

enum _TurnActionScope { turn, contribution }

enum _TurnActionKind {
  drawWinner,
  markPayoutSent,
  confirmReceipt,
  payNow,
  fixResubmit,
  waitingForVerification,
  uploadReceipt,
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
  final receiptConfirmerUserId = _receiptConfirmerUserId(
    cycle: cycle,
    payout: payout,
  );
  if (isAdmin && cycle.state == CycleStateModel.readyForWinnerSelection) {
    return const _TurnAction(
      label: 'Draw winner',
      icon: Icons.emoji_events_outlined,
      onPressed: null,
      scope: _TurnActionScope.turn,
      kind: _TurnActionKind.drawWinner,
    );
  }

  if (isAdmin && cycle.state == CycleStateModel.readyForPayout) {
    return const _TurnAction(
      label: 'Mark payout sent',
      icon: Icons.account_balance_wallet_outlined,
      onPressed: null,
      scope: _TurnActionScope.turn,
      kind: _TurnActionKind.markPayoutSent,
    );
  }

  if (cycle.state == CycleStateModel.payoutSent &&
      receiptConfirmerUserId == currentUserId) {
    return const _TurnAction(
      label: 'Confirm receipt',
      icon: Icons.task_alt_rounded,
      onPressed: null,
      scope: _TurnActionScope.turn,
      kind: _TurnActionKind.confirmReceipt,
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
      scope: _TurnActionScope.contribution,
      kind: _TurnActionKind.payNow,
    );
  }

  return switch (contribution.status) {
    ContributionStatusModel.rejected => _TurnAction(
      label: 'Fix & resubmit',
      icon: Icons.refresh_rounded,
      onPressed: () => context.push(
        AppRoutePaths.groupCycleContributionsSubmit(group.id, cycle.id),
      ),
      scope: _TurnActionScope.contribution,
      kind: _TurnActionKind.fixResubmit,
    ),
    ContributionStatusModel.late => _TurnAction(
      label: 'Pay now',
      icon: Icons.warning_amber_rounded,
      onPressed: () => context.push(
        AppRoutePaths.groupCycleContributionsSubmit(group.id, cycle.id),
      ),
      scope: _TurnActionScope.contribution,
      kind: _TurnActionKind.payNow,
    ),
    ContributionStatusModel.paidSubmitted ||
    ContributionStatusModel.submitted => const _TurnAction(
      label: 'Waiting for verification',
      icon: Icons.hourglass_bottom_rounded,
      onPressed: null,
      scope: _TurnActionScope.contribution,
      kind: _TurnActionKind.waitingForVerification,
    ),
    ContributionStatusModel.pending => _TurnAction(
      label: 'Pay now',
      icon: Icons.upload_file_outlined,
      onPressed: () => context.push(
        AppRoutePaths.groupCycleContributionsSubmit(group.id, cycle.id),
      ),
      scope: _TurnActionScope.contribution,
      kind: _TurnActionKind.uploadReceipt,
    ),
    _ => null,
  };
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

bool _isTurnLevelAction(_TurnAction? action) {
  return action?.scope == _TurnActionScope.turn;
}

bool _showsInFooterTray(_TurnAction? action) {
  return switch (action?.kind) {
    _TurnActionKind.drawWinner ||
    _TurnActionKind.markPayoutSent ||
    _TurnActionKind.confirmReceipt ||
    _TurnActionKind.payNow ||
    _TurnActionKind.uploadReceipt => true,
    _ => false,
  };
}

_TurnFooter? _resolveTurnFooter({
  required _TurnAction? action,
  required CycleModel cycle,
  required PayoutModel? payout,
  required bool isAdmin,
  required ContributionModel? contribution,
  required String? currentUserId,
}) {
  final receiptConfirmerUserId = _receiptConfirmerUserId(
    cycle: cycle,
    payout: payout,
  );
  if (_showsInFooterTray(action)) {
    return _TurnFooter.action(action!);
  }

  if (!isAdmin &&
      cycle.state == CycleStateModel.payoutSent &&
      receiptConfirmerUserId != currentUserId) {
    return const _TurnFooter.status(
      message: 'Waiting for payout receipt confirmation',
      detail: 'The selected winner must confirm receipt to complete this turn.',
      icon: Icons.hourglass_bottom_rounded,
    );
  }

  if (cycle.state == CycleStateModel.completed ||
      cycle.status == CycleStatusModel.closed) {
    return const _TurnFooter.status(
      message: 'Turn completed',
      detail: 'This turn is finished and recorded in history.',
      icon: Icons.task_alt_rounded,
    );
  }

  if (action?.kind == _TurnActionKind.waitingForVerification) {
    return const _TurnFooter.status(
      message: 'Waiting for contribution verification',
      detail: 'Your submitted payment is waiting for admin review.',
      icon: Icons.hourglass_bottom_rounded,
    );
  }

  if (cycle.state == CycleStateModel.collecting && contribution == null) {
    return const _TurnFooter.status(
      message: 'Waiting for contribution',
      detail: 'Submit your contribution to keep this turn moving.',
      icon: Icons.receipt_long_outlined,
    );
  }

  if (cycle.state == CycleStateModel.collecting) {
    return const _TurnFooter.status(
      message: 'Collection is in progress',
      detail: 'This turn will unlock the next step when collection requirements are met.',
      icon: Icons.sync_alt_rounded,
    );
  }

  if (cycle.state == CycleStateModel.readyForWinnerSelection) {
    return const _TurnFooter.status(
      message: 'Waiting for winner selection',
      detail: 'An admin needs to select the winner for this turn.',
      icon: Icons.emoji_events_outlined,
    );
  }

  if (cycle.state == CycleStateModel.readyForPayout) {
    return const _TurnFooter.status(
      message: 'Waiting for payout to be sent',
      detail: 'The selected winner is set. The next step is payout disbursement.',
      icon: Icons.account_balance_wallet_outlined,
    );
  }

  if (cycle.state == CycleStateModel.payoutSent) {
    return const _TurnFooter.status(
      message: 'Payout has been sent',
      detail: 'The turn will complete after the recipient confirms receipt.',
      icon: Icons.payments_outlined,
    );
  }

  return null;
}

String? _receiptConfirmerUserId({
  required CycleModel cycle,
  required PayoutModel? payout,
}) {
  return cycle.selectedWinnerUserId ??
      payout?.toUserId ??
      cycle.finalPayoutUserId ??
      cycle.payoutUserId;
}

Widget _buildTurnActionTray({
  required BuildContext context,
  required _TurnFooter footer,
  required VoidCallback? onPressed,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  return SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colorScheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: footer.isAction
                      ? SizedBox(
                          width: double.infinity,
                          child: KitPrimaryButton(
                            onPressed: onPressed,
                            label: footer.action!.label,
                            icon: footer.action!.icon,
                          ),
                        )
                      : Row(
                          children: [
                            Icon(
                              footer.icon,
                              size: 20,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    footer.message!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: AppSpacing.xxs),
                                  Text(
                                    footer.detail!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            ),
          ),
        ),
      ),
  );
}

Future<void> _handleTurnLevelAction({
  required BuildContext context,
  required WidgetRef ref,
  required _TurnAction action,
  required String groupId,
  required CycleModel cycle,
}) {
  return switch (action.kind) {
    _TurnActionKind.drawWinner => _handleDrawWinnerAction(
      context: context,
      ref: ref,
      groupId: groupId,
      cycle: cycle,
    ),
    _TurnActionKind.markPayoutSent => _openSendPayoutSheet(
      context: context,
      groupId: groupId,
      cycle: cycle,
    ),
    _TurnActionKind.confirmReceipt => _handleConfirmReceiptAction(
      context: context,
      ref: ref,
      groupId: groupId,
      cycle: cycle,
    ),
    _ => Future.value(),
  };
}

Future<void> _openSendPayoutSheet({
  required BuildContext context,
  required String groupId,
  required CycleModel cycle,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _SendPayoutSheet(
      groupId: groupId,
      cycle: cycle,
    ),
  );
}

Future<void> _handleDrawWinnerAction({
  required BuildContext context,
  required WidgetRef ref,
  required String groupId,
  required CycleModel cycle,
}) async {
  final args = (groupId: groupId, cycleId: cycle.id);
  final rules = await ref.read(groupRulesProvider(groupId).future);
  final mode = rules?.payoutMode ?? GroupRulePayoutModeModel.unknown;

  if (mode == GroupRulePayoutModeModel.unknown) {
    if (context.mounted) {
      KitToast.error(context, 'Winner selection is unavailable.');
    }
    return;
  }

  String? selectedUserId;
  if (mode == GroupRulePayoutModeModel.decision) {
    if (!context.mounted) {
      return;
    }
    selectedUserId = await _promptDecisionWinner(
      context: context,
      ref: ref,
      groupId: groupId,
      rules: rules,
    );
    if (selectedUserId == null || selectedUserId.trim().isEmpty) {
      return;
    }
  } else {
    if (!context.mounted) {
      return;
    }
    final shouldRun = await KitDialog.confirm(
      context: context,
      title: 'Draw winner?',
      message: _winnerSelectionHelperText(mode),
      confirmLabel: _winnerSelectionButtonLabel(mode),
    );
    if (shouldRun != true) {
      return;
    }
  }

  final success = await ref
      .read(payoutActionControllerProvider(args).notifier)
      .selectWinner(
        userId: mode == GroupRulePayoutModeModel.decision ? selectedUserId : null,
        preferSocketSync: true,
      );
  if (success && context.mounted) {
    KitToast.success(context, 'Winner selected.');
  }
}

Future<void> _handleConfirmReceiptAction({
  required BuildContext context,
  required WidgetRef ref,
  required String groupId,
  required CycleModel cycle,
}) async {
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
        payoutActionControllerProvider((groupId: groupId, cycleId: cycle.id))
            .notifier,
      )
      .confirmPayoutReceived(preferSocketSync: true);
  if (success && context.mounted) {
    KitToast.success(context, 'Turn completed.');
  }
}

Future<String?> _promptDecisionWinner({
  required BuildContext context,
  required WidgetRef ref,
  required String groupId,
  required GroupRulesModel? rules,
}) async {
  final members = await ref.read(groupMembersProvider(groupId).future);
  final requiresVerification = rules?.requiresMemberVerification ?? false;
  final eligibleMembers = members
      .where(
        (member) => requiresVerification
            ? isVerifiedMemberStatus(member.status)
            : isParticipatingMemberStatus(member.status),
      )
      .toList(growable: false);
  if (eligibleMembers.isEmpty) {
    if (context.mounted) {
      KitToast.error(context, 'No eligible members are available.');
    }
    return null;
  }

  var selectedUserId = eligibleMembers.first.userId;
  if (!context.mounted) {
    return null;
  }
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) => AlertDialog(
        title: const Text('Choose winner'),
        content: KitDropdownField<String>(
          value: selectedUserId,
          label: 'Eligible member',
          items: eligibleMembers
              .map(
                (member) => DropdownMenuItem<String>(
                  value: member.userId,
                  child: Text(member.displayName),
                ),
              )
              .toList(growable: false),
          onChanged: (value) {
            setState(() {
              selectedUserId = value ?? selectedUserId;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(selectedUserId),
            child: const Text('Select winner'),
          ),
        ],
      ),
    ),
  );
}

class _SendPayoutSheet extends ConsumerStatefulWidget {
  const _SendPayoutSheet({
    required this.groupId,
    required this.cycle,
  });

  final String groupId;
  final CycleModel cycle;

  @override
  ConsumerState<_SendPayoutSheet> createState() => _SendPayoutSheetState();
}

class _SendPayoutSheetState extends ConsumerState<_SendPayoutSheet> {
  late final TextEditingController _paymentRefController;
  late final TextEditingController _noteController;

  PayoutActionArgs get _args => (
    groupId: widget.groupId,
    cycleId: widget.cycle.id,
  );

  @override
  void initState() {
    super.initState();
    _paymentRefController = TextEditingController();
    _noteController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final controller = ref.read(
        payoutActionControllerProvider(_args).notifier,
      );
      controller.clearProof();
      controller.clearError();
    });
  }

  @override
  void dispose() {
    _paymentRefController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(payoutActionControllerProvider(_args));

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: SingleChildScrollView(
            child: KitCard(
              child: _SendPayoutSheetContent(
                args: _args,
                paymentRefController: _paymentRefController,
                noteController: _noteController,
                actionState: actionState,
                onCompleted: () {
                  if (!mounted) {
                    return;
                  }
                  Navigator.of(context).pop();
                  KitToast.success(context, 'Payout marked as sent.');
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SendPayoutSheetContent extends ConsumerWidget {
  const _SendPayoutSheetContent({
    required this.args,
    required this.paymentRefController,
    required this.noteController,
    required this.actionState,
    required this.onCompleted,
  });

  final PayoutActionArgs args;
  final TextEditingController paymentRefController;
  final TextEditingController noteController;
  final PayoutActionState actionState;
  final VoidCallback onCompleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(payoutActionControllerProvider(args).notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Mark payout sent',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Capture the payout reference and optional proof for this turn.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
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
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            KitSecondaryButton(
              onPressed: actionState.isLoading
                  ? null
                  : () => controller.pickProofFromCamera(),
              icon: Icons.photo_camera,
              label: 'Camera proof',
              expand: false,
            ),
            KitSecondaryButton(
              onPressed: actionState.isLoading
                  ? null
                  : () => controller.pickProofFromGallery(),
              icon: Icons.photo_library,
              label: 'Gallery proof',
              expand: false,
            ),
            if (actionState.hasProof)
              KitTertiaryButton(
                onPressed: actionState.isLoading ? null : controller.clearProof,
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
                : 'Saving payout...',
            style: Theme.of(context).textTheme.bodySmall,
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
                  final success = await controller.disbursePayout(
                    paymentRef: paymentRefController.text,
                    note: noteController.text,
                    preferSocketSync: true,
                  );
                  if (success) {
                    onCompleted();
                  }
                },
        ),
      ],
    );
  }
}

String _winnerSelectionHelperText(GroupRulePayoutModeModel mode) {
  return switch (mode) {
    GroupRulePayoutModeModel.lottery =>
      'Run a turn draw among eligible members.',
    GroupRulePayoutModeModel.auction =>
      'Close bids and select the highest eligible bid.',
    GroupRulePayoutModeModel.rotation =>
      'Select the next eligible member in rotation.',
    GroupRulePayoutModeModel.decision =>
      'Choose one eligible member for this turn.',
    GroupRulePayoutModeModel.unknown => 'Winner selection is unavailable.',
  };
}

String _winnerSelectionButtonLabel(GroupRulePayoutModeModel mode) {
  return switch (mode) {
    GroupRulePayoutModeModel.lottery => 'Draw winner',
    GroupRulePayoutModeModel.auction => 'Close bids & select winner',
    GroupRulePayoutModeModel.rotation => 'Select next in rotation',
    GroupRulePayoutModeModel.decision => 'Select chosen member',
    GroupRulePayoutModeModel.unknown => 'Winner selection unavailable',
  };
}
