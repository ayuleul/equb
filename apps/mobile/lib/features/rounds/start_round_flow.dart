import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../shared/copy/fair_draw_copy.dart';
import '../../shared/kit/kit.dart';
import '../../shared/ui/ui.dart';
import 'start_round_controller.dart';

Future<void> startFairDrawFlow({
  required BuildContext context,
  required WidgetRef ref,
  required String groupId,
  required bool navigateToOverview,
}) async {
  final state = ref.read(startRoundControllerProvider(groupId));
  if (state.isSubmitting) {
    return;
  }

  final confirmed = await KitDialog.confirm(
    context: context,
    title: FairDrawCopy.startDialogTitle,
    message: FairDrawCopy.startDialogBullets
        .map((line) => '• $line')
        .join('\n'),
    cancelLabel: FairDrawCopy.startDialogCancel,
    confirmLabel: FairDrawCopy.startDialogConfirm,
  );

  if (confirmed != true) {
    return;
  }

  final started = await ref
      .read(startRoundControllerProvider(groupId).notifier)
      .startRound();

  if (!context.mounted || !started) {
    return;
  }

  AppSnackbars.success(context, '${FairDrawCopy.label} started.');

  if (navigateToOverview) {
    context.push(AppRoutePaths.groupOverview(groupId));
  }
}
