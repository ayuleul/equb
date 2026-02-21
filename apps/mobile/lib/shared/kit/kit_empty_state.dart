import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import 'kit_buttons.dart';

class KitEmptyState extends StatelessWidget {
  const KitEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.ctaLabel,
    this.onCtaPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? ctaLabel;
  final VoidCallback? onCtaPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 44,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (ctaLabel != null && onCtaPressed != null) ...[
                const SizedBox(height: AppSpacing.md),
                KitPrimaryButton(
                  label: ctaLabel!,
                  onPressed: onCtaPressed,
                  expand: false,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
