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
        ? 'Members loading...'
        : '$memberCount members';
    final turnSummary = _turnSummary(
      cycle: currentCycle,
      memberCount: memberCount,
    );
    final initials = _groupInitial(group.name);
    final avatarSize = compact ? 38.0 : 42.0;
    final sectionSpacing = compact ? AppSpacing.xs : AppSpacing.sm;
    final headerGap = compact ? AppSpacing.xs : AppSpacing.sm;
    final summaryPadding = compact ? AppSpacing.xs : AppSpacing.sm;
    final cardPadding = compact ? const EdgeInsets.all(12) : null;

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
                  child: Text(
                    group.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: compact
                        ? textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          )
                        : textTheme.titleMedium,
                  ),
                ),
              ),
              StatusPill.fromLabel(role),
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
          Row(
            children: [
              Icon(
                Icons.group_outlined,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  memberSummary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              SizedBox(width: compact ? AppSpacing.xs : AppSpacing.sm),
              _CompactMetaPill(
                label: group.status == GroupStatusModel.archived
                    ? 'Archived'
                    : 'Active',
                compact: compact,
              ),
            ],
          ),
          SizedBox(height: sectionSpacing),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? AppSpacing.xs : AppSpacing.sm,
              vertical: summaryPadding,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow.withValues(alpha: 0.7),
              borderRadius: AppRadius.mdRounded,
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.9),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    turnSummary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: compact ? 13 : null,
                    ),
                  ),
                ),
                SizedBox(width: compact ? AppSpacing.xs : AppSpacing.sm),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Next draw: ${formatShortDate(nextDrawDate)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                        fontSize: compact ? 13 : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xxs),
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
        color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.85),
        borderRadius: AppRadius.pillRounded,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.85),
        ),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
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
