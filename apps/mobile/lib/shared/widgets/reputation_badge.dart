import 'package:flutter/material.dart';

import '../kit/kit.dart';
import '../utils/reputation_presenter.dart';

class ReputationBadge extends StatelessWidget {
  const ReputationBadge({
    super.key,
    required this.trustLevel,
    this.compact = false,
  });

  final String trustLevel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final spec = reputationVisualSpec(trustLevel);
    return KitBadge(
      icon: spec.icon,
      label: spec.label,
      tone: spec.tone,
      compact: compact,
    );
  }
}
