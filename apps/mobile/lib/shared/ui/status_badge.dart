import 'package:flutter/material.dart';

import '../kit/kit.dart';

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
    final kitTone = switch (tone) {
      StatusBadgeTone.neutral => KitBadgeTone.neutral,
      StatusBadgeTone.info => KitBadgeTone.info,
      StatusBadgeTone.success => KitBadgeTone.success,
      StatusBadgeTone.warning => KitBadgeTone.warning,
      StatusBadgeTone.error => KitBadgeTone.danger,
    };
    return KitBadge(label: label, tone: kitTone);
  }
}
