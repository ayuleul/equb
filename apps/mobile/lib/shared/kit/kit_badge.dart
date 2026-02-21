import 'package:flutter/material.dart';

import '../../app/theme/app_theme_extensions.dart';
import '../../app/theme/app_spacing.dart';

enum KitBadgeTone { neutral, info, success, warning, danger }

class KitBadge extends StatelessWidget {
  const KitBadge({
    super.key,
    this.label,
    this.count,
    this.icon,
    this.isDot = false,
    this.tone = KitBadgeTone.neutral,
  });

  final String? label;
  final int? count;
  final IconData? icon;
  final bool isDot;
  final KitBadgeTone tone;

  factory KitBadge.dot({Key? key, KitBadgeTone tone = KitBadgeTone.info}) {
    return KitBadge(key: key, isDot: true, tone: tone);
  }

  factory KitBadge.number(
    int value, {
    Key? key,
    KitBadgeTone tone = KitBadgeTone.info,
  }) {
    return KitBadge(key: key, count: value, tone: tone);
  }

  factory KitBadge.icon(
    IconData icon, {
    Key? key,
    KitBadgeTone tone = KitBadgeTone.neutral,
  }) {
    return KitBadge(key: key, icon: icon, tone: tone);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = context.colors;
    final palette = switch (tone) {
      KitBadgeTone.neutral => (
        bg: colorScheme.surfaceContainerHigh,
        fg: colorScheme.onSurfaceVariant,
      ),
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
    };

    if (isDot) {
      return Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: palette.bg, shape: BoxShape.circle),
      );
    }

    final text = count != null ? '$count' : label;
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: palette.fg),
          const SizedBox(width: AppSpacing.xxs),
        ],
        if (text != null)
          Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: palette.fg),
          ),
      ],
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: palette.bg,
        borderRadius: AppRadius.pillRounded,
      ),
      child: child,
    );
  }
}
