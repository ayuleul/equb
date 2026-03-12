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
import '../../../shared/ui/ui.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/error_view.dart';
import '../../auth/auth_controller.dart';
import '../../cycles/current_cycle_provider.dart';
import '../group_detail_controller.dart';
import '../group_rules_provider.dart';
import '../groups_list_controller.dart';

class GroupsListScreen extends ConsumerStatefulWidget {
  const GroupsListScreen({super.key});

  @override
  ConsumerState<GroupsListScreen> createState() => _GroupsListScreenState();
}

class _GroupsListScreenState extends ConsumerState<GroupsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _query = '';
  bool _isSearching = false;

  Future<void> _showGroupActions() {
    return KitActionSheet.show(
      context: context,
      title: 'Group actions',
      actions: [
        KitActionSheetItem(
          label: 'Create Equb',
          icon: Icons.add,
          onPressed: () => context.push(AppRoutePaths.groupsCreate),
        ),
        KitActionSheetItem(
          label: 'Join Equb',
          icon: Icons.group_add_outlined,
          onPressed: () => context.push(AppRoutePaths.groupsJoin),
        ),
        KitActionSheetItem(
          label: 'Discover Public',
          icon: Icons.travel_explore_outlined,
          onPressed: () => context.push(AppRoutePaths.groupsDiscover),
        ),
      ],
    );
  }

  void _openSearch() {
    setState(() => _isSearching = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _searchFocusNode.requestFocus();
    });
  }

  void _closeSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _isSearching = false;
      _query = '';
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(groupsListProvider);

    ref.listen(groupsListProvider, (previous, next) {
      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;
      if (nextError != null &&
          nextError.isNotEmpty &&
          previousError != nextError) {
        AppSnackbars.error(context, nextError);
      }
    });

    Future<void> onRefresh() {
      return ref.read(groupsListProvider.notifier).refresh();
    }

    return KitScaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showGroupActions,
        icon: const Icon(Icons.add),
        label: const Text('New'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KitSectionHeader(
            title: 'My Equbs',
            subtitle: 'Manage active groups and create new ones.',
            searchConfig: KitSectionHeaderSearchConfig(
              controller: _searchController,
              focusNode: _searchFocusNode,
              isSearching: _isSearching,
              onOpen: _openSearch,
              onClose: _closeSearch,
              onChanged: (value) => setState(() => _query = value.trim()),
              hintText: 'Search groups',
            ),
            action: IconButton(
              tooltip: 'Notifications',
              onPressed: () => context.push(AppRoutePaths.notifications),
              icon: const Icon(Icons.notifications_outlined),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: _GroupsBody(
              state: state,
              query: _query,
              onRetry: () => ref.read(groupsListProvider.notifier).load(),
              onRefresh: onRefresh,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupsBody extends StatelessWidget {
  const _GroupsBody({
    required this.state,
    required this.query,
    required this.onRetry,
    required this.onRefresh,
  });

  final GroupsListState state;
  final String query;
  final VoidCallback onRetry;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && !state.hasData) {
      return const KitSkeletonList(itemCount: 4);
    }

    if (state.errorMessage != null && !state.hasData) {
      return ErrorView(message: state.errorMessage!, onRetry: onRetry);
    }

    if (!state.hasData) {
      return KitEmptyState(
        icon: Icons.groups_2_outlined,
        title: 'No groups yet',
        message: 'Create a group or join one with an invite code.',
        ctaLabel: 'Create group',
        onCtaPressed: () => context.push(AppRoutePaths.groupsCreate),
      );
    }

    final normalizedQuery = query.toLowerCase();
    final filtered = normalizedQuery.isEmpty
        ? state.items
        : state.items
              .where(
                (group) => group.name.toLowerCase().contains(normalizedQuery),
              )
              .toList(growable: false);

    if (filtered.isEmpty) {
      return const KitEmptyState(
        icon: Icons.search_off_outlined,
        title: 'No matching groups',
        message: 'Try a different name or clear the search.',
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        itemCount: filtered.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) => _GroupCard(group: filtered[index]),
      ),
    );
  }
}

class _GroupCard extends ConsumerWidget {
  const _GroupCard({required this.group});

  final GroupModel group;

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

    return KitCard(
      onTap: () => context.push(AppRoutePaths.groupDetail(group.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
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
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: Text(
                    group.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium,
                  ),
                ),
              ),
              StatusPill.fromLabel(role),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${formatCurrency(group.contributionAmount, group.currency)} / $cadenceLabel',
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
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
              const SizedBox(width: AppSpacing.sm),
              _CompactMetaPill(
                label: group.status == GroupStatusModel.archived
                    ? 'Archived'
                    : 'Active',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
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
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
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
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xxs),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactMetaPill extends StatelessWidget {
  const _CompactMetaPill({required this.label});

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
          letterSpacing: 0.2,
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
