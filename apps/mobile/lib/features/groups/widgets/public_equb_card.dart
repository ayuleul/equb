import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/public_group_model.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/reputation_badge.dart';

class PublicEqubCard extends StatelessWidget {
  const PublicEqubCard({super.key, required this.group});

  final PublicGroupModel group;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final host = group.host;
    final hostName = group.hostName ?? 'Group admin';
    final hostTitle = host?.hostTitle;
    final hasEarnedHostTitle = (hostTitle ?? '').trim().isNotEmpty;

    return KitCard(
      onTap: () => context.push(AppRoutePaths.publicGroupDetail(group.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  group.name,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (host != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xxs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  hostName,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (hasEarnedHostTitle)
                  ReputationBadge(
                    label: hostTitle!,
                    icon: host.icon,
                    level: host.level,
                    compact: true,
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              _Chip(
                icon: Icons.payments_outlined,
                label: formatCurrency(group.contributionAmount, group.currency),
              ),
              _Chip(
                icon: Icons.repeat_rounded,
                label: publicGroupFrequencyLabel(group.frequency, group.rules),
              ),
              _Chip(
                icon: Icons.groups_outlined,
                label: '${group.memberCount} members',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if ((group.description ?? '').trim().isEmpty) ...[
            Text(
              group.alreadyStarted
                  ? 'Already started.'
                  : 'Review details before requesting to join.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Row(
            children: [
              Expanded(
                child: Text(
                  'Review to join',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow.withValues(alpha: 0.45),
        borderRadius: AppRadius.pillRounded,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(height: 1),
          ),
        ],
      ),
    );
  }
}

String publicGroupFrequencyLabel(
  PublicGroupFrequencyModel frequency,
  PublicGroupRulesModel? rules,
) {
  return switch (frequency) {
    PublicGroupFrequencyModel.weekly => 'Weekly',
    PublicGroupFrequencyModel.monthly => 'Monthly',
    PublicGroupFrequencyModel.customInterval =>
      '${rules?.customIntervalDays ?? 0} day interval',
    PublicGroupFrequencyModel.unknown => 'Unknown',
  };
}
