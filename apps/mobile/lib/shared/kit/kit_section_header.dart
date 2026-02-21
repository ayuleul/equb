import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_theme_extensions.dart';

class KitSectionHeader extends StatelessWidget {
  const KitSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.kicker,
    this.actionLabel,
    this.onActionPressed,
    this.action,
  });

  final String title;
  final String? subtitle;
  final String? kicker;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final resolvedAction =
        action ??
        ((actionLabel != null && onActionPressed != null)
            ? TextButton(
                onPressed: onActionPressed,
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.xxs,
                  ),
                ),
                child: Text(actionLabel!),
              )
            : null);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                if (kicker != null && kicker!.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.brand.cardAccentStart,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        kicker!.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ],
                if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?resolvedAction,
        ],
      ),
    );
  }
}
