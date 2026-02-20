import 'package:flutter/material.dart';

import '../../app/theme/app_theme_extensions.dart';

enum StatusBadgeTone { neutral, info, success, warning, error }

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.tone = StatusBadgeTone.neutral,
  });

  final String label;
  final StatusBadgeTone tone;

  factory StatusBadge.fromLabel(String label) {
    final normalized = label.toUpperCase();
    if (normalized.contains('CONFIRMED') ||
        normalized.contains('ACTIVE') ||
        normalized.contains('OPEN') ||
        normalized.contains('ADMIN') ||
        normalized.contains('READ')) {
      return StatusBadge(label: label, tone: StatusBadgeTone.success);
    }
    if (normalized.contains('PENDING') ||
        normalized.contains('INVITED') ||
        normalized.contains('SUBMITTED')) {
      return StatusBadge(label: label, tone: StatusBadgeTone.warning);
    }
    if (normalized.contains('REJECTED') ||
        normalized.contains('ERROR') ||
        normalized.contains('LEFT') ||
        normalized.contains('REMOVED') ||
        normalized.contains('CLOSED')) {
      return StatusBadge(label: label, tone: StatusBadgeTone.error);
    }

    return StatusBadge(label: label, tone: StatusBadgeTone.neutral);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).semanticColors;
    final palette = switch (tone) {
      StatusBadgeTone.neutral => (
        background: colorScheme.surfaceContainerHighest,
        foreground: colorScheme.onSurfaceVariant,
      ),
      StatusBadgeTone.info => (
        background: semantic.infoContainer,
        foreground: semantic.onInfoContainer,
      ),
      StatusBadgeTone.success => (
        background: semantic.successContainer,
        foreground: semantic.onSuccessContainer,
      ),
      StatusBadgeTone.warning => (
        background: semantic.warningContainer,
        foreground: semantic.onWarningContainer,
      ),
      StatusBadgeTone.error => (
        background: colorScheme.errorContainer,
        foreground: colorScheme.onErrorContainer,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: palette.foreground),
      ),
    );
  }
}
