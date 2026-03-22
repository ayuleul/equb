import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../data/models/reputation_model.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/utils/reputation_presenter.dart';
import '../../../shared/widgets/reputation_badge.dart';

class AccountSummaryCard extends StatelessWidget {
  const AccountSummaryCard({
    super.key,
    required this.userName,
    required this.phone,
    required this.profilePhotoBytes,
    this.reputationLabel,
    this.reputationIcon,
    this.reputationLevel,
    this.onTap,
    this.profileComplete,
  });

  final String userName;
  final String phone;
  final Uint8List? profilePhotoBytes;
  final String? reputationLabel;
  final String? reputationIcon;
  final String? reputationLevel;
  final VoidCallback? onTap;
  final bool? profileComplete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return KitCard(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            backgroundImage: profilePhotoBytes != null
                ? MemoryImage(profilePhotoBytes!)
                : null,
            child: profilePhotoBytes == null
                ? Icon(
                    Icons.person_rounded,
                    color: theme.colorScheme.primary,
                    size: 28,
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  phone,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (reputationLabel != null &&
              reputationLabel!.trim().isNotEmpty) ...[
            ReputationBadge(
              label: reputationLabel!,
              icon: reputationIcon,
              level: reputationLevel,
              compact: true,
            ),
            const SizedBox(width: AppSpacing.xs),
          ] else if (profileComplete != null)
            KitBadge(
              label: 'Finish profile',
              tone: KitBadgeTone.warning,
              compact: true,
            ),
          if (onTap != null) const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

class TrustIdentityCard extends StatelessWidget {
  const TrustIdentityCard({super.key, required this.profile});

  final ReputationProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onTimeRate = formatOnTimeRate(profile.onTimePaymentRate);
    final hasEarnedLevel = profile.hasEarnedLevel;
    final progress = buildTrustProgress(profile.trustScore);

    return KitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  hasEarnedLevel
                      ? 'Score ${profile.trustScore} • ${profile.displayLabel}'
                      : 'Trust score ${profile.trustScore}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (hasEarnedLevel)
                ReputationBadge(
                  label: profile.displayLabel!,
                  icon: profile.icon,
                  level: profile.level,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              TrustMetricTile(
                label: 'Trust score',
                value: '${profile.trustScore}',
              ),
              TrustMetricTile(
                label: 'Completed Equbs',
                value: '${profile.equbsCompleted}',
              ),
              TrustMetricTile(
                label: 'Equbs joined',
                value: '${profile.equbsJoined}',
              ),
              TrustMetricTile(
                label: 'Hosted Equbs',
                value: '${profile.equbsHosted}',
              ),
              TrustMetricTile(label: 'On-time rate', value: onTimeRate),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (hasEarnedLevel) ...[
            Text(
              progress.isMaxLevel
                  ? 'Progress'
                  : 'Progress • ${progress.currentLevel} to ${progress.nextLevel}',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            LinearProgressIndicator(value: progress.progress),
            const SizedBox(height: AppSpacing.xs),
            Text(
              progress.isMaxLevel
                  ? 'Max level'
                  : '${progress.currentScore} / ${progress.targetScore}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (profile.badges.isNotEmpty) ...[
            Text('Badges', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final badge in profile.badges)
                  KitBadge(label: badge.label, tone: KitBadgeTone.info),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          KitBanner(
            title: 'Hosting access',
            message: hostRestrictionMessage(profile),
            tone: profile.eligibility.hostTier == null
                ? KitBadgeTone.warning
                : KitBadgeTone.info,
            icon: Icons.shield_outlined,
          ),
        ],
      ),
    );
  }
}

class TrustMetricTile extends StatelessWidget {
  const TrustMetricTile({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 136,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: AppRadius.mdRounded,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        color: Theme.of(context).colorScheme.surfaceContainerLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class ReputationTimelineCard extends StatelessWidget {
  const ReputationTimelineCard({
    super.key,
    required this.history,
    this.limit = 4,
  });

  final ReputationHistoryPageModel? history;
  final int limit;

  @override
  Widget build(BuildContext context) {
    final items = (history?.items ?? const <ReputationHistoryEntryModel>[])
        .take(limit)
        .toList();
    return KitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (items.isEmpty)
            const Text('No activity yet.')
          else
            for (var i = 0; i < items.length; i++) ...[
              TimelineRow(entry: items[i]),
              if (i != items.length - 1)
                Divider(
                  height: AppSpacing.lg,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
            ],
        ],
      ),
    );
  }
}

class TimelineRow extends StatelessWidget {
  const TimelineRow({super.key, required this.entry});

  final ReputationHistoryEntryModel entry;

  @override
  Widget build(BuildContext context) {
    final isPositive = entry.scoreDelta >= 0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color:
                (isPositive
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error)
                    .withValues(alpha: 0.12),
            borderRadius: AppRadius.mdRounded,
          ),
          child: Icon(
            isPositive
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            size: 18,
            color: isPositive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${isPositive ? '+' : ''}${entry.scoreDelta} ${reputationHistoryLabel(entry.eventType)}',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                formatRelativeTime(entry.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
