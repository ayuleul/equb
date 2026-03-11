import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_theme_extensions.dart';
import '../utils/formatters.dart';
import 'kit_badge.dart';

class DueCountdown extends StatelessWidget {
  const DueCountdown({
    super.key,
    required this.dueDate,
    this.now,
    this.showAbsoluteLabel = true,
    this.compact = false,
  });

  final DateTime dueDate;
  final DateTime? now;
  final bool showAbsoluteLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final countdown = getDueCountdown(dueDate, now: now);
    final dateLabel = showAbsoluteLabel
        ? 'Due date: ${formatCalendarDate(dueDate)}'
        : formatCalendarDate(dueDate);
    final tone = switch (countdown.tone) {
      DueCountdownTone.neutral => KitBadgeTone.info,
      DueCountdownTone.warning => KitBadgeTone.warning,
      DueCountdownTone.danger => KitBadgeTone.danger,
    };
    final emphasisColor = switch (countdown.tone) {
      DueCountdownTone.neutral => context.colors.info,
      DueCountdownTone.warning => context.colors.warning,
      DueCountdownTone.danger => context.colors.danger,
    };
    final countdownStyle = compact
        ? Theme.of(context).textTheme.labelLarge
        : Theme.of(context).textTheme.titleMedium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (!compact)
              Text(
                countdown.label,
                style: countdownStyle?.copyWith(
                  color: emphasisColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (compact) KitBadge(label: countdown.label, tone: tone),
          ],
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          dateLabel,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
