import 'package:flutter/material.dart';

import '../kit/kit.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionPressed,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return KitSectionHeader(
      title: title,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }
}
