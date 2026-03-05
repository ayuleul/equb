import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/theme/app_theme_extensions.dart';
import '../../app/theme/app_spacing.dart';
import 'kit_badge.dart';

class KitToast {
  const KitToast._();

  static OverlayEntry? _activeEntry;
  static Timer? _dismissTimer;

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

    _activeEntry?.remove();
    _dismissTimer?.cancel();

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      return;
    }

    final textStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: palette.fg);

    final entry = OverlayEntry(
      builder: (overlayContext) => IgnorePointer(
        ignoring: false,
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                0,
              ),
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: _hideCurrent,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 560),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: palette.bg,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(icon, size: 18, color: palette.fg),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            message,
                            style: textStyle,
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

    _activeEntry = entry;
    overlay.insert(entry);
    _dismissTimer = Timer(const Duration(seconds: 3), _hideCurrent);
  }

  static void _hideCurrent() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _activeEntry?.remove();
    _activeEntry = null;
  }
}
