import 'package:flutter/material.dart';

import '../../app/theme/app_theme_extensions.dart';
import '../../app/theme/app_spacing.dart';
import 'kit_badge.dart';

class KitToast {
  const KitToast._();

  static void success(BuildContext context, String message) {
    _show(context, message, tone: KitBadgeTone.success, icon: Icons.check);
  }

  static void info(BuildContext context, String message) {
    _show(context, message, tone: KitBadgeTone.info, icon: Icons.info_outline);
  }

  static void warning(BuildContext context, String message) {
    _show(
      context,
      message,
      tone: KitBadgeTone.warning,
      icon: Icons.warning_amber_outlined,
    );
  }

  static void error(BuildContext context, String message) {
    _show(
      context,
      message,
      tone: KitBadgeTone.danger,
      icon: Icons.error_outline,
    );
  }

  static void _show(
    BuildContext context,
    String message, {
    required KitBadgeTone tone,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = context.colors;
    final palette = switch (tone) {
      KitBadgeTone.info => (bg: colors.infoTint, fg: colors.onInfoTint),
      KitBadgeTone.success => (
        bg: colors.successTint,
        fg: colors.onSuccessTint,
      ),
      KitBadgeTone.warning => (
        bg: colors.warningTint,
        fg: colors.onWarningTint,
      ),
      KitBadgeTone.danger => (bg: colors.dangerTint, fg: colors.onDangerTint),
      KitBadgeTone.neutral => (
        bg: colorScheme.surfaceContainerHigh,
        fg: colorScheme.onSurfaceVariant,
      ),
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: palette.bg,
        content: Row(
          children: [
            Icon(icon, size: 18, color: palette.fg),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: palette.fg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
