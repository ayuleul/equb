import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bootstrap.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/invite_model.dart';
import '../../../shared/kit/kit.dart';

Future<InviteModel?> showGroupInviteSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String groupId,
  InviteModel? initialInvite,
}) async {
  final repository = ref.read(groupsRepositoryProvider);
  var invite = initialInvite;

  Future<InviteModel?> createInvite({bool showToast = true}) async {
    try {
      final nextInvite = await repository.createInvite(groupId);
      if (showToast && context.mounted) {
        KitToast.success(context, 'Invite code ready.');
      }
      return nextInvite;
    } catch (error) {
      if (context.mounted) {
        KitToast.error(context, mapFriendlyError(error));
      }
      return null;
    }
  }

  Future<void> copyValue(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) {
      return;
    }
    KitToast.success(context, 'Copied.');
  }

  invite ??= await createInvite(showToast: false);
  if (!context.mounted || invite == null) {
    return null;
  }

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      final colorScheme = Theme.of(sheetContext).colorScheme;
      final textTheme = Theme.of(sheetContext).textTheme;
      var currentInvite = invite!;
      var isRefreshing = false;

      return StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invite members',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Share this code with members.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: SelectableText(
                      currentInvite.code,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      KitPrimaryButton(
                        onPressed: () => copyValue(currentInvite.code),
                        label: 'Copy code',
                        icon: Icons.copy_rounded,
                        expand: false,
                      ),
                      if ((currentInvite.joinUrl ?? '').trim().isNotEmpty)
                        KitSecondaryButton(
                          onPressed: () => copyValue(currentInvite.joinUrl!),
                          label: 'Copy join link',
                          icon: Icons.link_rounded,
                          expand: false,
                        ),
                      KitTertiaryButton(
                        onPressed: isRefreshing
                            ? null
                            : () async {
                                setSheetState(() => isRefreshing = true);
                                final nextInvite = await createInvite();
                                if (nextInvite != null) {
                                  setSheetState(() => currentInvite = nextInvite);
                                  invite = nextInvite;
                                }
                                if (sheetContext.mounted) {
                                  setSheetState(() => isRefreshing = false);
                                }
                              },
                        label: isRefreshing
                            ? 'Generating...'
                            : 'Generate new code',
                        icon: Icons.refresh_rounded,
                        expand: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  return invite;
}
