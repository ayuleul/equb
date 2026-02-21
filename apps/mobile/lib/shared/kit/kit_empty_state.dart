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
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.92),
            borderRadius: AppRadius.cardRounded,
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 34, color: colorScheme.primary),
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
                const SizedBox(height: AppSpacing.lg),
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
