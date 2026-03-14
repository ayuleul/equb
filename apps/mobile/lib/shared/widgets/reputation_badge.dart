import 'package:flutter/material.dart';

import '../kit/kit.dart';
import '../utils/reputation_presenter.dart';

class ReputationBadge extends StatelessWidget {
  const ReputationBadge({
    super.key,
    required this.label,
    this.icon,
    this.level,
    this.compact = false,
  });

  final String label;
  final String? icon;
  final String? level;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final spec = reputationVisualSpec(level ?? label);
    final badgeLabel = switch ((icon ?? '').trim().isNotEmpty) {
      true => '${icon!.trim()} $label',
      false => label,
    };
    return KitBadge(label: badgeLabel, tone: spec.tone, compact: compact);
  }
}
