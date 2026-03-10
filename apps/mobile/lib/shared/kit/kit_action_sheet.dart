import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_theme_extensions.dart';

class KitActionSheetItem {
  const KitActionSheetItem({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isDestructive = false,
  });

  final String label;
  final FutureOr<void> Function() onPressed;
  final IconData? icon;
  final bool isDestructive;
}

class KitActionSheet {
  const KitActionSheet._();

  static Future<void> show({
    required BuildContext context,
    required String title,
    required List<KitActionSheetItem> actions,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        final colorScheme = Theme.of(sheetContext).colorScheme;
        final textTheme = Theme.of(sheetContext).textTheme;
        final brand = sheetContext.brand;
        final semantic = Theme.of(sheetContext).semanticColors;
        final viewInsets = MediaQuery.viewInsetsOf(sheetContext);
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.md + viewInsets.bottom,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ...actions.map((action) {
                  final foregroundColor = action.isDestructive
                      ? semantic.danger
                      : colorScheme.onSurface;
                  final borderColor = action.isDestructive
                      ? semantic.danger.withValues(alpha: 0.24)
                      : colorScheme.outlineVariant;
                  final backgroundColor = action.isDestructive
                      ? semantic.dangerContainer.withValues(alpha: 0.28)
                      : colorScheme.surfaceContainerLow;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: AppRadius.inputRounded,
                      child: InkWell(
                        borderRadius: AppRadius.inputRounded,
                        onTap: () async {
                          Navigator.of(sheetContext).pop();
                          await action.onPressed();
                        },
                        child: Ink(
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                brand.cardAccentStart.withValues(alpha: 0.04),
                                brand.cardAccentEnd.withValues(alpha: 0.02),
                              ],
                            ),
                            borderRadius: AppRadius.inputRounded,
                            border: Border.all(
                              color: borderColor,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.md,
                            ),
                            child: Row(
                              children: [
                                if (action.icon != null) ...[
                                  Icon(
                                    action.icon,
                                    color: foregroundColor,
                                    size: 26,
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                ],
                                Expanded(
                                  child: Text(
                                    action.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.titleMedium?.copyWith(
                                      color: foregroundColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
