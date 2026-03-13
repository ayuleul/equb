import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/cycle_model.dart';
import '../../../data/models/group_model.dart';
import '../../../data/models/group_rules_model.dart';
import '../../../data/models/member_model.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/utils/formatters.dart';
import '../../auth/auth_controller.dart';
import '../../cycles/current_cycle_provider.dart';
import '../group_detail_controller.dart';
import '../group_rules_provider.dart';

class MyEqubCard extends ConsumerWidget {
  const MyEqubCard({
    super.key,
    required this.group,
    this.width,
    this.compact = false,
  });

  final GroupModel group;
  final double? width;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currentUserId = ref.watch(currentUserProvider)?.id;
    final membersAsync = ref.watch(groupMembersProvider(group.id));
    final rulesAsync = ref.watch(groupRulesProvider(group.id));
    final currentCycleAsync = ref.watch(currentCycleProvider(group.id));
    final memberCount = membersAsync.valueOrNull
        ?.where(_isCountedMember)
        .length;
    final memberRole = _resolveCurrentUserRole(
      members: membersAsync.valueOrNull,
      currentUserId: currentUserId,
    );
    final role = switch (group.membership?.role ?? memberRole) {
      MemberRoleModel.admin => 'ADMIN',
      MemberRoleModel.member => 'MEMBER',
      _ => 'MEMBER',
    };
    final cadenceLabel = _cadenceLabel(group.frequency, rulesAsync.valueOrNull);
    final currentCycle = currentCycleAsync.valueOrNull;
    final nextDrawDate = currentCycle?.dueDate ?? group.startDate;
    final memberSummary = memberCount == null
        ? 'Loading'
        : '$memberCount members';
    final turnSummary = _turnSummary(
      cycle: currentCycle,
      memberCount: memberCount,
    );
    final initials = _groupInitial(group.name);
    final avatarSize = compact ? 34.0 : 40.0;
    final sectionSpacing = compact ? AppSpacing.xs : AppSpacing.sm;
    final headerGap = compact ? AppSpacing.xs : AppSpacing.sm;
    final cardPadding = compact
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 11)
        : null;
    final isArchived = group.status == GroupStatusModel.archived;
    final nextDrawLabel = formatShortDate(nextDrawDate);

    final card = KitCard(
      onTap: () => context.push(AppRoutePaths.groupDetail(group.id)),
      padding: cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.18),
                      colorScheme.secondary.withValues(alpha: 0.14),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.18),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(width: headerGap),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: headerGap),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: compact
                            ? textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              )
                            : textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        role == 'ADMIN'
                            ? 'You manage this group'
                            : 'You are a member',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _CompactMetaPill(
                label: isArchived ? 'Archived' : role,
                compact: compact,
              ),
            ],
          ),
          SizedBox(height: sectionSpacing),
          Text(
            '${formatCurrency(group.contributionAmount, group.currency)} / $cadenceLabel',
            style: (compact ? textTheme.bodyLarge : textTheme.titleSmall)
                ?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: sectionSpacing),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              _InfoChip(icon: Icons.group_outlined, label: memberSummary),
              _InfoChip(icon: Icons.schedule_rounded, label: turnSummary),
            ],
          ),
          SizedBox(height: sectionSpacing),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? AppSpacing.xs : AppSpacing.sm,
              vertical: compact ? AppSpacing.xs : AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow.withValues(alpha: 0.55),
              borderRadius: AppRadius.mdRounded,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event_outlined,
                  size: compact ? 15 : 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'Next draw $nextDrawLabel',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontSize: compact ? 13 : null,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: compact ? 16 : 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (width == null) {
      return card;
    }

    return SizedBox(width: width, child: card);
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: AppRadius.pillRounded,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactMetaPill extends StatelessWidget {
  const _CompactMetaPill({required this.label, required this.compact});

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: AppRadius.pillRounded,
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.16)),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: compact ? 0.1 : 0.2,
        ),
      ),
    );
  }
}

String _groupInitial(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) {
    return 'E';
  }

  return String.fromCharCode(trimmed.runes.first).toUpperCase();
}

MemberRoleModel? _resolveCurrentUserRole({
  required List<MemberModel>? members,
  required String? currentUserId,
}) {
  if (members == null || currentUserId == null || currentUserId.isEmpty) {
    return null;
  }

  for (final member in members) {
    if (member.userId == currentUserId) {
      return member.role;
    }
  }

  return null;
}

String _cadenceLabel(GroupFrequencyModel frequency, GroupRulesModel? rules) {
  final rulesFrequency = rules?.frequency;
  if (rulesFrequency == GroupRuleFrequencyModel.customInterval) {
    final customDays = rules?.customIntervalDays;
    if (customDays == 1) {
      return 'day';
    }
    if (customDays != null && customDays > 1) {
      return '$customDays days';
    }
    return 'custom cycle';
  }

  if (rulesFrequency == GroupRuleFrequencyModel.weekly) {
    return 'week';
  }
  if (rulesFrequency == GroupRuleFrequencyModel.monthly) {
    return 'month';
  }

  return switch (frequency) {
    GroupFrequencyModel.weekly => 'week',
    GroupFrequencyModel.monthly => 'month',
    GroupFrequencyModel.unknown => 'cycle',
  };
}

bool _isCountedMember(MemberModel member) {
  return switch (member.status) {
    MemberStatusModel.suspended ||
    MemberStatusModel.left ||
    MemberStatusModel.removed => false,
    _ => true,
  };
}

String _turnSummary({required CycleModel? cycle, required int? memberCount}) {
  if (cycle == null) {
    return 'Turn pending';
  }
  if (memberCount == null || memberCount <= 0) {
    return 'Turn ${cycle.cycleNo}';
  }

  return 'Turn ${cycle.cycleNo} / $memberCount';
}
