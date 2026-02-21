import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

class KitSectionHeader extends StatelessWidget {
  const KitSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionPressed,
    this.action,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final resolvedAction =
        action ??
        ((actionLabel != null && onActionPressed != null)
            ? TextButton(onPressed: onActionPressed, child: Text(actionLabel!))
            : null);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          ?resolvedAction,
        ],
      ),
    );
  }
}
