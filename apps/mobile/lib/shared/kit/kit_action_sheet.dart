import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

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
      builder: (sheetContext) {
        final colorScheme = Theme.of(sheetContext).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                ...actions.map((action) {
                  final color = action.isDestructive
                      ? colorScheme.error
                      : colorScheme.onSurface;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: action.icon == null
                        ? null
                        : Icon(action.icon, color: color),
                    title: Text(
                      action.label,
                      style: Theme.of(
                        sheetContext,
                      ).textTheme.bodyLarge?.copyWith(color: color),
                    ),
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      await action.onPressed();
                    },
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
