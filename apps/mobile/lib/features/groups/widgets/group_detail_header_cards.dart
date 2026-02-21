import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../shared/kit/kit.dart';

class GroupInviteBannerCard extends StatelessWidget {
  const GroupInviteBannerCard({
    super.key,
    required this.isAdmin,
    required this.onInviteTap,
  });

  final bool isAdmin;
  final VoidCallback onInviteTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final title = isAdmin ? 'Invite new members' : 'Group invites';
    final subtitle = isAdmin
        ? 'Send an invite link and grow this group.'
        : 'Only admins can invite members.';

    return KitCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textScale = MediaQuery.textScalerOf(context).scale(1.0);
          final isCompact = constraints.maxWidth < 340 || textScale > 1.2;
          final iconTile = Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.person_add_alt_1_rounded,
              color: colorScheme.primary,
            ),
          );
          final description = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
          final inviteButton = KitPrimaryButton(
            label: 'Invite',
            icon: Icons.send_rounded,
            onPressed: isAdmin ? onInviteTap : null,
            expand: false,
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    iconTile,
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: description),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                inviteButton,
              ],
            );
          }

          return Row(
            children: [
              iconTile,
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: description),
              const SizedBox(width: AppSpacing.sm),
              inviteButton,
            ],
          );
        },
      ),
    );
  }
}

class GroupOverviewCard extends StatelessWidget {
  const GroupOverviewCard({
    super.key,
    required this.statusLabel,
    required this.frequencyLabel,
    required this.memberCount,
    required this.overviewText,
  });

  final String statusLabel;
  final String frequencyLabel;
  final int memberCount;
  final String overviewText;

  @override
  Widget build(BuildContext context) {
    return KitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _MetaChip(icon: Icons.shield_outlined, label: statusLabel),
                const SizedBox(width: AppSpacing.xs),
                _MetaChip(
                  icon: Icons.event_repeat_outlined,
                  label: frequencyLabel.toLowerCase(),
                ),
                const SizedBox(width: AppSpacing.xs),
                _MetaChip(
                  icon: Icons.group_outlined,
                  label: '$memberCount members',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Overview',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(overviewText, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.primary),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
