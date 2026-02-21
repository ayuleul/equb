import 'package:flutter/material.dart';

import 'kit_badge.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, this.tone});

  final String label;
  final KitBadgeTone? tone;

  factory StatusPill.fromLabel(String label) {
    final normalized = label.toUpperCase();
    if (normalized.contains('CONFIRMED') ||
        normalized.contains('ACTIVE') ||
        normalized.contains('OPEN') ||
        normalized.contains('ADMIN') ||
        normalized.contains('READ')) {
      return StatusPill(label: label, tone: KitBadgeTone.success);
    }
    if (normalized.contains('PENDING') ||
        normalized.contains('INVITED') ||
        normalized.contains('SUBMITTED')) {
      return StatusPill(label: label, tone: KitBadgeTone.warning);
    }
    if (normalized.contains('REJECTED') ||
        normalized.contains('ERROR') ||
        normalized.contains('LEFT') ||
        normalized.contains('REMOVED') ||
        normalized.contains('CLOSED')) {
      return StatusPill(label: label, tone: KitBadgeTone.danger);
    }
    return StatusPill(label: label, tone: KitBadgeTone.info);
  }

  @override
  Widget build(BuildContext context) {
    return KitBadge(label: label, tone: tone ?? KitBadgeTone.info);
  }
}
