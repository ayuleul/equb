import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import 'kit_badge.dart';
import 'kit_card.dart';
import 'kit_buttons.dart';

class KitBanner extends StatelessWidget {
  const KitBanner({
    super.key,
    required this.title,
    required this.message,
    this.tone = KitBadgeTone.info,
    this.ctaLabel,
    this.onCtaPressed,
    this.icon,
  });

  final String title;
  final String message;
  final KitBadgeTone tone;
  final String? ctaLabel;
  final VoidCallback? onCtaPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return KitCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            KitBadge.icon(icon!, tone: tone),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(message, style: Theme.of(context).textTheme.bodyMedium),
                if (ctaLabel != null && onCtaPressed != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  KitTertiaryButton(
                    label: ctaLabel!,
                    onPressed: onCtaPressed,
                    expand: false,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
