import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

class EqubListTile extends StatelessWidget {
  const EqubListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.leadingText,
    this.showChevron = true,
    this.isDense = false,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? leadingText;
  final bool showChevron;
  final bool isDense;

  @override
  Widget build(BuildContext context) {
    final resolvedLeadingText = leadingText ?? _deriveInitials(title);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      minVerticalPadding: AppSpacing.xs,
      dense: isDense,
      onTap: onTap,
      leading: CircleAvatar(
        radius: 20,
        child: Text(
          resolvedLeadingText,
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing:
          trailing ??
          (showChevron ? const Icon(Icons.chevron_right_rounded) : null),
    );
  }
}

String _deriveInitials(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return 'E';
  }

  final parts = trimmed
      .split(RegExp(r'\s+'))
      .where((element) => element.isNotEmpty)
      .toList(growable: false);

  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }

  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}
