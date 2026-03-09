import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/bootstrap.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme_extensions.dart';
import '../../../data/models/contribution_model.dart';
import '../../../data/models/cycle_model.dart';
import '../../../data/models/group_model.dart';
import '../../../data/models/group_rules_model.dart';
import '../../../data/models/member_model.dart';
import '../../../data/models/member_status_utils.dart';
import '../../../data/models/payout_model.dart';
import '../../../data/realtime/socket_sync_policy.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/utils/turn_status_mapper.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../contributions/cycle_contributions_provider.dart';
import '../../cycles/current_cycle_provider.dart';
import '../../cycles/cycles_list_provider.dart';
import '../../cycles/start_cycle_controller.dart';
import '../../payouts/cycle_payout_provider.dart';
import '../group_detail_controller.dart';
import '../group_rules_provider.dart';
import '../widgets/group_invite_sheet.dart';
import '../widgets/group_more_actions_button.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  bool _wasCurrentRoute = false;
  bool _hasSeenCurrentRoute = false;

  @override
  void initState() {
    super.initState();
    ref.read(realtimeClientProvider).joinGroup(widget.groupId);
  }

  @override
  void dispose() {
    ref.read(realtimeClientProvider).leaveGroup(widget.groupId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scheduleCatchUpRefreshIfNeeded();

    final groupId = widget.groupId;
    final groupAsync = ref.watch(groupDetailProvider(groupId));
    final group = groupAsync.valueOrNull;
    final isAdmin = group?.membership?.role == MemberRoleModel.admin;

    return KitScaffold(
      appBar: KitAppBar(
        title: group?.name ?? 'Group detail',
        subtitle: group == null ? null : 'Tap for details',
        onTitleTap: group == null
            ? null
            : () => context.push(AppRoutePaths.groupOverview(groupId)),
        actions: [
          if (group != null)
            GroupMoreActionsButton(groupName: group.name, isAdmin: isAdmin),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref
                .read(groupDetailControllerProvider)
                .refreshGroupPage(groupId),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      child: groupAsync.when(
        loading: () => const LoadingView(message: 'Loading group...'),
        error: (error, _) => ErrorView(
          message: mapFriendlyError(error),
          onRetry: () =>
              ref.read(groupDetailControllerProvider).refreshGroupPage(groupId),
        ),
        data: (group) => _GroupTurnOverview(group: group),
      ),
    );
  }

  void _scheduleCatchUpRefreshIfNeeded() {
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
    if (!isCurrentRoute) {
      _wasCurrentRoute = false;
      return;
    }

    if (_wasCurrentRoute) {
      return;
    }

    _wasCurrentRoute = true;
    if (!_hasSeenCurrentRoute) {
      _hasSeenCurrentRoute = true;
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(
        ref
            .read(groupDetailControllerProvider)
            .refreshCurrentTurnState(widget.groupId),
      );
    });
  }
}

class _GroupTurnOverview extends ConsumerWidget {
  const _GroupTurnOverview({required this.group});

  final GroupModel group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCycleAsync = ref.watch(currentCycleProvider(group.id));
    final cyclesAsync = ref.watch(cyclesListProvider(group.id));
    final membersAsync = ref.watch(groupMembersProvider(group.id));
    final hasStarted =
        currentCycleAsync.valueOrNull != null ||
        (cyclesAsync.valueOrNull?.isNotEmpty ?? false);

    return RefreshIndicator(
      onRefresh: () => ref
          .read(groupDetailControllerProvider)
          .refreshGroupPage(
            group.id,
            cycleId: currentCycleAsync.valueOrNull?.id,
          ),
      child: hasStarted
          ? ListView(
              children: [
                _CurrentTurnHeroCard(
                  group: group,
                  currentCycleAsync: currentCycleAsync,
                  cyclesAsync: cyclesAsync,
                  membersAsync: membersAsync,
                ),
                const SizedBox(height: AppSpacing.lg),
                _PastTurnsSection(
                  groupId: group.id,
                  currentCycleAsync: currentCycleAsync,
                  cyclesAsync: cyclesAsync,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            )
          : _PreStartGroupView(
              group: group,
              currentCycleAsync: currentCycleAsync,
              cyclesAsync: cyclesAsync,
            ),
    );
  }
}

enum _GroupPageMode { preStart, active }

class _PreStartGroupView extends ConsumerWidget {
  const _PreStartGroupView({
    required this.group,
    required this.currentCycleAsync,
    required this.cyclesAsync,
  });

  final GroupModel group;
  final AsyncValue<CycleModel?> currentCycleAsync;
  final AsyncValue<List<CycleModel>> cyclesAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(groupMembersProvider(group.id));
    final resolvedMode = _resolveMode(
      currentCycle: currentCycleAsync.valueOrNull,
      cycles: cyclesAsync.valueOrNull,
    );

    if (resolvedMode == _GroupPageMode.active) {
      return ListView(
        children: [
          _CurrentTurnHeroCard(
            group: group,
            currentCycleAsync: currentCycleAsync,
            cyclesAsync: cyclesAsync,
            membersAsync: membersAsync,
          ),
          const SizedBox(height: AppSpacing.lg),
          _PastTurnsSection(
            groupId: group.id,
            currentCycleAsync: currentCycleAsync,
            cyclesAsync: cyclesAsync,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      );
    }

    if (currentCycleAsync.isLoading && currentCycleAsync.valueOrNull == null) {
      return ListView(
        children: const [
          KitCard(child: _HeroSkeleton()),
          SizedBox(height: AppSpacing.lg),
          KitCard(
            child: SizedBox(height: 220, child: KitSkeletonList(itemCount: 4)),
          ),
          SizedBox(height: AppSpacing.lg),
        ],
      );
    }

    final rulesAsync = ref.watch(groupRulesProvider(group.id));

    return ListView(
      children: [
        _SetupProgressCard(group: group, rulesAsync: rulesAsync),
        const SizedBox(height: AppSpacing.lg),
        _PreStartMembersSection(
          group: group,
          rulesAsync: rulesAsync,
          membersAsync: membersAsync,
        ),
        const SizedBox(height: AppSpacing.lg),
        _StartGroupCard(
          group: group,
          rulesAsync: rulesAsync,
          membersAsync: membersAsync,
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

_GroupPageMode _resolveMode({
  required CycleModel? currentCycle,
  required List<CycleModel>? cycles,
}) {
  if (currentCycle != null || (cycles?.isNotEmpty ?? false)) {
    return _GroupPageMode.active;
  }
  return _GroupPageMode.preStart;
}

class _SetupProgressCard extends ConsumerWidget {
  const _SetupProgressCard({required this.group, required this.rulesAsync});

  final GroupModel group;
  final AsyncValue<GroupRulesModel?> rulesAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return rulesAsync.when(
      loading: () => const KitCard(child: _HeroSkeleton()),
      error: (error, _) => KitCard(
        child: ErrorView(
          message: mapFriendlyError(error),
          onRetry: () => ref.invalidate(groupRulesProvider(group.id)),
        ),
      ),
      data: (rules) {
        final stepStates = [
          _SetupStepState(
            key: 'basics',
            title: 'Basics',
            isComplete: _isBasicsComplete(rules),
            summary: _basicsSummary(group, rules),
          ),
          _SetupStepState(
            key: 'timing',
            title: 'Timing',
            isComplete: _isTimingComplete(rules),
            summary: _timingSummary(rules),
          ),
          _SetupStepState(
            key: 'policy',
            title: 'Policy',
            isComplete: _isPolicyComplete(rules),
            summary: _policySummary(rules),
          ),
        ];
        final completedSteps = stepStates
            .where((step) => step.isComplete)
            .length;

        return KitCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                completedSteps == stepStates.length
                    ? 'Setup is ready.'
                    : 'Complete the remaining setup steps.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$completedSteps of ${stepStates.length} steps completed',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  StatusPill(
                    label: completedSteps == stepStates.length
                        ? 'Ready'
                        : 'In progress',
                    tone: completedSteps == stepStates.length
                        ? KitBadgeTone.success
                        : KitBadgeTone.info,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: AppRadius.pillRounded,
                child: LinearProgressIndicator(
                  value: stepStates.isEmpty
                      ? 0
                      : completedSteps / stepStates.length,
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (var index = 0; index < stepStates.length; index++) ...[
                _SetupStepRow(
                  groupId: group.id,
                  step: stepStates[index],
                  isAdmin: group.membership?.role == MemberRoleModel.admin,
                ),
                if (index != stepStates.length - 1)
                  const Divider(height: AppSpacing.lg),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SetupStepState {
  const _SetupStepState({
    required this.key,
    required this.title,
    required this.isComplete,
    required this.summary,
  });

  final String key;
  final String title;
  final bool isComplete;
  final String summary;
}

class _SetupStepRow extends StatelessWidget {
  const _SetupStepRow({
    required this.groupId,
    required this.step,
    required this.isAdmin,
  });

  final String groupId;
  final _SetupStepState step;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          step.isComplete
              ? Icons.task_alt_rounded
              : Icons.radio_button_unchecked,
          color: step.isComplete
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(step.summary, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        if (isAdmin)
          KitTertiaryButton(
            onPressed: () =>
                context.push(AppRoutePaths.groupSetup(groupId, step: step.key)),
            label: step.isComplete ? 'Edit' : 'Open',
            icon: Icons.chevron_right_rounded,
            expand: false,
          ),
      ],
    );
  }
}

class _PreStartMembersSection extends ConsumerStatefulWidget {
  const _PreStartMembersSection({
    required this.group,
    required this.rulesAsync,
    required this.membersAsync,
  });

  final GroupModel group;
  final AsyncValue<GroupRulesModel?> rulesAsync;
  final AsyncValue<List<MemberModel>> membersAsync;

  @override
  ConsumerState<_PreStartMembersSection> createState() =>
      _PreStartMembersSectionState();
}

class _PreStartMembersSectionState
    extends ConsumerState<_PreStartMembersSection> {
  bool _isGeneratingInvite = false;
  String? _verifyingMemberId;

  Future<void> _openInviteSheet() async {
    if (_isGeneratingInvite) {
      return;
    }
    setState(() => _isGeneratingInvite = true);
    await showGroupInviteSheet(
      context: context,
      ref: ref,
      groupId: widget.group.id,
    );
    if (mounted) {
      setState(() => _isGeneratingInvite = false);
    }
  }

  Future<void> _verifyMember(MemberModel member) async {
    if (_verifyingMemberId != null) {
      return;
    }

    setState(() => _verifyingMemberId = member.id);
    try {
      await ref
          .read(groupsRepositoryProvider)
          .verifyMember(widget.group.id, member.id);
      unawaited(
        ref
            .read(socketSyncPolicyProvider)
            .waitForSocketOrFallback(
              eventTypes: const {'member.updated'},
              groupId: widget.group.id,
              entityId: member.id,
              fallback: () => ref
                  .read(groupDetailControllerProvider)
                  .refreshGroupPage(widget.group.id),
            ),
      );
      if (!mounted) {
        return;
      }
      KitToast.success(context, '${member.displayName} verified.');
    } catch (error) {
      if (!mounted) {
        return;
      }
      KitToast.error(context, mapFriendlyError(error));
    } finally {
      if (mounted) {
        setState(() => _verifyingMemberId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.membersAsync.when(
      loading: () => const KitCard(
        child: SizedBox(height: 220, child: KitSkeletonList(itemCount: 4)),
      ),
      error: (error, _) => KitCard(
        child: ErrorView(
          message: mapFriendlyError(error),
          onRetry: () => ref
              .read(groupDetailControllerProvider)
              .refreshMembers(widget.group.id),
        ),
      ),
      data: (members) {
        final rules = widget.rulesAsync.valueOrNull;
        final verifiedCount = members
            .where((member) => isVerifiedMemberStatus(member.status))
            .length;
        final requiredCount = rules?.requiredToStart ?? (rules?.roundSize ?? 0);
        final isAdmin = widget.group.membership?.role == MemberRoleModel.admin;
        final joinedCount = members
            .where((member) => isParticipatingMemberStatus(member.status))
            .length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KitSectionHeader(
              title: 'Members',
              subtitle: requiredCount > 0
                  ? '$verifiedCount of $requiredCount verified'
                  : '$joinedCount members',
            ),
            KitCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isAdmin) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Invite and verify members here.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        KitPrimaryButton(
                          onPressed: !widget.group.canInviteMembers
                              ? null
                              : _openInviteSheet,
                          label: _isGeneratingInvite
                              ? 'Inviting...'
                              : 'Invite members',
                          icon: Icons.person_add_alt_1_rounded,
                          expand: false,
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      'Members will appear here as they join.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  if (isAdmin && !widget.group.canInviteMembers) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Finish setup before sending invites.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  if (members.isEmpty)
                    const KitEmptyState(
                      icon: Icons.people_outline_rounded,
                      title: 'No members yet',
                      message:
                          'Invite members here, then verify them when they join.',
                    )
                  else
                    Column(
                      children: [
                        for (
                          var index = 0;
                          index < members.length;
                          index++
                        ) ...[
                          _PreStartMemberRow(
                            member: members[index],
                            canVerify:
                                isAdmin &&
                                _canVerifyMember(members[index].status),
                            isVerifying:
                                _verifyingMemberId == members[index].id,
                            onVerify: () => _verifyMember(members[index]),
                          ),
                          if (index != members.length - 1)
                            const Divider(height: AppSpacing.lg),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PreStartMemberRow extends StatelessWidget {
  const _PreStartMemberRow({
    required this.member,
    required this.canVerify,
    required this.isVerifying,
    required this.onVerify,
  });

  final MemberModel member;
  final bool canVerify;
  final bool isVerifying;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        KitAvatar(name: member.displayName, size: KitAvatarSize.sm),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                _memberStatusCopy(member.status),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (canVerify) ...[
          const SizedBox(width: AppSpacing.sm),
          KitSecondaryButton(
            onPressed: isVerifying ? null : onVerify,
            label: isVerifying ? 'Verifying...' : 'Verify',
            icon: Icons.verified_outlined,
            expand: false,
          ),
        ],
      ],
    );
  }
}

class _StartGroupCard extends ConsumerStatefulWidget {
  const _StartGroupCard({
    required this.group,
    required this.rulesAsync,
    required this.membersAsync,
  });

  final GroupModel group;
  final AsyncValue<GroupRulesModel?> rulesAsync;
  final AsyncValue<List<MemberModel>> membersAsync;

  @override
  ConsumerState<_StartGroupCard> createState() => _StartGroupCardState();
}

class _StartGroupCardState extends ConsumerState<_StartGroupCard> {
  bool _isStarting = false;

  Future<void> _startGroup() async {
    if (_isStarting) {
      return;
    }

    setState(() => _isStarting = true);
    final created = await ref
        .read(startCycleControllerProvider(widget.group.id).notifier)
        .startCycle();
    if (!mounted) {
      return;
    }

    setState(() => _isStarting = false);
    if (created == null) {
      final message =
          ref
              .read(startCycleControllerProvider(widget.group.id))
              .errorMessage ??
          'Could not start the group right now.';
      KitToast.error(context, message);
      return;
    }

    KitToast.success(context, 'New cycle started. Turn 1 is now active.');
  }

  @override
  Widget build(BuildContext context) {
    final rules = widget.rulesAsync.valueOrNull;
    final members = widget.membersAsync.valueOrNull ?? const <MemberModel>[];
    final isAdmin = widget.group.membership?.role == MemberRoleModel.admin;
    final readiness = rules?.readiness;
    final missingCount = rules == null || readiness == null
        ? null
        : (rules.requiredToStart - readiness.eligibleCount)
              .clamp(0, rules.requiredToStart)
              .toInt();
    final reason = _startDisabledReason(
      isAdmin: isAdmin,
      group: widget.group,
      rules: rules,
      missingCount: missingCount,
    );
    final verifiedCount = members
        .where((member) => isVerifiedMemberStatus(member.status))
        .length;

    if (!isAdmin) {
      return KitCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Waiting for start',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.group.canStartCycle
                  ? 'An admin can start the group now.'
                  : reason,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return KitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Start the group when everything is ready',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.group.canStartCycle
                ? 'The first turn can start now.'
                : reason,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          if (rules != null) ...[
            Text(
              '$verifiedCount verified',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          KitPrimaryButton(
            onPressed: widget.group.canStartCycle ? _startGroup : null,
            label: _isStarting ? 'Starting group...' : 'Start group',
            icon: Icons.play_arrow_rounded,
          ),
          if (!widget.group.canStartCycle) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              reason,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CurrentTurnHeroCard extends ConsumerWidget {
  const _CurrentTurnHeroCard({
    required this.group,
    required this.currentCycleAsync,
    required this.cyclesAsync,
    required this.membersAsync,
  });

  final GroupModel group;
  final AsyncValue<CycleModel?> currentCycleAsync;
  final AsyncValue<List<CycleModel>> cyclesAsync;
  final AsyncValue<List<MemberModel>> membersAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return currentCycleAsync.when(
      loading: () => const KitCard(child: _HeroSkeleton()),
      error: (error, _) => KitCard(
        child: ErrorView(
          message: mapFriendlyError(error),
          onRetry: () => ref.invalidate(currentCycleProvider(group.id)),
        ),
      ),
      data: (cycle) {
        if (cycle == null) {
          return _NoCurrentTurnHeroCard(
            group: group,
            cyclesAsync: cyclesAsync,
            membersAsync: membersAsync,
          );
        }

        final contributionsAsync = ref.watch(
          cycleContributionsProvider((groupId: group.id, cycleId: cycle.id)),
        );
        final payoutAsync = ref.watch(cyclePayoutProvider(cycle.id));
        final contributionList = contributionsAsync.valueOrNull;
        final summary = contributionList?.summary;
        final payout = payoutAsync.valueOrNull;
        final status = mapTurnStatus(
          cycle: cycle,
          contributionSummary: summary,
          payout: payout,
        );
        final paid = _paidCount(summary);
        final total = summary?.total ?? 0;
        final potSize = _turnPotSize(
          contributions: contributionList,
          fallbackAmount: group.contributionAmount,
          totalMembers: total,
        );
        final hasAuction =
            (cycle.auctionStatus ?? AuctionStatusModel.none) !=
            AuctionStatusModel.none;
        final hasLate = (summary?.late ?? 0) > 0;

        return KitCard(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [context.brand.heroTop, context.brand.heroBottom],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.cardRounded,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Turn ${cycle.cycleNo}',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      _buildStagePill(status),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Due ${formatDate(cycle.dueDate)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _winnerCopy(cycle, payout),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Pot size: ${formatCurrency(potSize, group.currency)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (hasAuction || hasLate) ...[
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        if (hasAuction)
                          const StatusPill(
                            label: 'Auction',
                            tone: KitBadgeTone.info,
                          ),
                        if (hasLate)
                          const StatusPill(
                            label: 'Late',
                            tone: KitBadgeTone.warning,
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  Divider(color: Theme.of(context).colorScheme.outlineVariant),
                  const SizedBox(height: AppSpacing.md),
                  _ProgressSummaryBar(paid: paid, total: total),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.xs,
                    children: [
                      _InlineMetric(label: 'Paid', value: '$paid / $total'),
                      _InlineMetric(
                        label: 'Verified',
                        value:
                            '${(summary?.verified ?? 0) + (summary?.confirmed ?? 0)}',
                      ),
                      _InlineMetric(
                        label: 'Pending',
                        value:
                            '${(summary?.pending ?? 0) + (summary?.submitted ?? 0) + (summary?.paidSubmitted ?? 0)}',
                      ),
                      _InlineMetric(
                        label: 'Late',
                        value: '${summary?.late ?? 0}',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  KitTertiaryButton(
                    onPressed: () => context.push(
                      AppRoutePaths.groupTurnDetail(group.id, cycle.id),
                    ),
                    label: 'View details',
                    icon: Icons.chevron_right_rounded,
                    expand: false,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PastTurnsSection extends StatelessWidget {
  const _PastTurnsSection({
    required this.groupId,
    required this.currentCycleAsync,
    required this.cyclesAsync,
  });

  final String groupId;
  final AsyncValue<CycleModel?> currentCycleAsync;
  final AsyncValue<List<CycleModel>> cyclesAsync;

  @override
  Widget build(BuildContext context) {
    final currentCycleId = currentCycleAsync.valueOrNull?.id;

    return cyclesAsync.when(
      loading: () => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KitSectionHeader(title: 'Past Turns'),
          KitCard(
            child: SizedBox(height: 220, child: KitSkeletonList(itemCount: 3)),
          ),
        ],
      ),
      error: (error, _) => KitCard(
        child: Text(
          mapFriendlyError(error),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      data: (cycles) {
        final pastTurns =
            cycles
                .where((cycle) => cycle.id != currentCycleId)
                .toList(growable: false)
              ..sort((a, b) => b.cycleNo.compareTo(a.cycleNo));

        if (pastTurns.isEmpty) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KitSectionHeader(title: 'Past Turns'),
              Padding(
                padding: EdgeInsets.only(top: AppSpacing.xs),
                child: Text('No past turns yet'),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const KitSectionHeader(
              title: 'Past Turns',
              subtitle: 'Recent history for this group',
            ),
            KitCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var index = 0; index < pastTurns.length; index++) ...[
                    _PastTurnRow(groupId: groupId, cycle: pastTurns[index]),
                    if (index != pastTurns.length - 1)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PastTurnRow extends ConsumerWidget {
  const _PastTurnRow({required this.groupId, required this.cycle});

  final String groupId;
  final CycleModel cycle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contributionsAsync = ref.watch(
      cycleContributionsProvider((groupId: groupId, cycleId: cycle.id)),
    );
    final payoutAsync = ref.watch(cyclePayoutProvider(cycle.id));
    final status = mapTurnStatus(
      cycle: cycle,
      contributionSummary: contributionsAsync.valueOrNull?.summary,
      payout: payoutAsync.valueOrNull,
    );
    final winnerLabel = _turnWinnerLabel(cycle, payoutAsync.valueOrNull);
    final hasLate = (contributionsAsync.valueOrNull?.summary.late ?? 0) > 0;
    final hasAuction =
        (cycle.auctionStatus ?? AuctionStatusModel.none) !=
        AuctionStatusModel.none;

    return InkWell(
      onTap: () =>
          context.push(AppRoutePaths.groupTurnDetail(groupId, cycle.id)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Turn ${cycle.cycleNo}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _buildStagePill(status),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    winnerLabel == null
                        ? 'Winner pending'
                        : 'Winner: $winnerLabel',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (hasAuction || hasLate) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        if (hasAuction) const _MiniIndicator(label: 'Auction'),
                        if (hasLate) const _MiniIndicator(label: 'Late'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _NoCurrentTurnHeroCard extends ConsumerStatefulWidget {
  const _NoCurrentTurnHeroCard({
    required this.group,
    required this.cyclesAsync,
    required this.membersAsync,
  });

  final GroupModel group;
  final AsyncValue<List<CycleModel>> cyclesAsync;
  final AsyncValue<List<MemberModel>> membersAsync;

  @override
  ConsumerState<_NoCurrentTurnHeroCard> createState() =>
      _NoCurrentTurnHeroCardState();
}

class _NoCurrentTurnHeroCardState
    extends ConsumerState<_NoCurrentTurnHeroCard> {
  bool _isStarting = false;

  Future<void> _startTurn() async {
    if (_isStarting) {
      return;
    }

    setState(() => _isStarting = true);
    final created = await ref
        .read(startCycleControllerProvider(widget.group.id).notifier)
        .startCycle();
    if (!mounted) {
      return;
    }

    setState(() => _isStarting = false);
    if (created == null) {
      final message =
          ref
              .read(startCycleControllerProvider(widget.group.id))
              .errorMessage ??
          'Could not start a turn right now.';
      KitToast.error(context, message);
      return;
    }

    KitToast.success(context, 'New cycle started. Turn 1 is now active.');
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.group.membership?.role == MemberRoleModel.admin;
    final roundProgress = _buildRoundProgress(
      members: widget.membersAsync.valueOrNull ?? const <MemberModel>[],
      cycles: widget.cyclesAsync.valueOrNull ?? const <CycleModel>[],
      currentCycle: null,
    );
    final isCompleted = roundProgress.isCompleted;

    return KitCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isCompleted
                  ? 'Equb Completed'
                  : isAdmin
                  ? 'Ready for the next turn'
                  : 'No turn is open right now',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isCompleted
                  ? 'All members have received their payout.'
                  : isAdmin
                  ? 'Start the next turn when the group is ready.'
                  : 'Check back after an admin starts the next turn.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            KitPrimaryButton(
              onPressed: !isAdmin
                  ? null
                  : widget.group.canStartCycle
                  ? _startTurn
                  : () =>
                        context.push(AppRoutePaths.groupSetup(widget.group.id)),
              label: !isAdmin
                  ? (isCompleted ? 'Equb completed' : 'Waiting for admin start')
                  : widget.group.canStartCycle
                  ? (_isStarting
                        ? (isCompleted
                              ? 'Starting new cycle...'
                              : 'Starting turn...')
                        : (isCompleted ? 'Start New Cycle' : 'Start turn'))
                  : 'Complete setup to start',
              icon: !isAdmin
                  ? Icons.check_circle_outline_rounded
                  : widget.group.canStartCycle
                  ? (isCompleted
                        ? Icons.autorenew_rounded
                        : Icons.play_arrow_rounded)
                  : Icons.rule_folder_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundProgressSummary {
  const _RoundProgressSummary({
    required this.isCompleted,
    required this.members,
  });

  final bool isCompleted;
  final List<_RoundMemberProgress> members;
}

class _RoundMemberProgress {
  const _RoundMemberProgress({
    required this.member,
    required this.receivedTurnNo,
  });

  final MemberModel member;
  final int? receivedTurnNo;
}

_RoundProgressSummary _buildRoundProgress({
  required List<MemberModel> members,
  required List<CycleModel> cycles,
  required CycleModel? currentCycle,
}) {
  final participatingMembers = members
      .where((member) => isParticipatingMemberStatus(member.status))
      .toList(growable: false);
  final latestRoundId =
      currentCycle?.roundId ??
      (cycles.isNotEmpty ? cycles.first.roundId : null);
  final latestRoundCycles =
      latestRoundId == null
            ? const <CycleModel>[]
            : cycles
                  .where((cycle) => cycle.roundId == latestRoundId)
                  .toList(growable: true)
        ..sort((a, b) => a.cycleNo.compareTo(b.cycleNo));

  final receivedTurnByUserId = <String, int>{};
  for (final cycle in latestRoundCycles) {
    final winnerUserId = cycle.selectedWinnerUserId;
    if (winnerUserId == null || cycle.payoutReceivedConfirmedAt == null) {
      continue;
    }
    receivedTurnByUserId[winnerUserId] = cycle.cycleNo;
  }

  final memberProgress = participatingMembers
      .map(
        (member) => _RoundMemberProgress(
          member: member,
          receivedTurnNo: receivedTurnByUserId[member.userId],
        ),
      )
      .toList(growable: false);

  final isCompleted =
      currentCycle == null &&
      memberProgress.isNotEmpty &&
      memberProgress.every((item) => item.receivedTurnNo != null);

  return _RoundProgressSummary(
    isCompleted: isCompleted,
    members: memberProgress,
  );
}

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KitSkeletonBox(height: 28, width: 150),
          SizedBox(height: AppSpacing.sm),
          KitSkeletonBox(height: 20, width: 120),
          SizedBox(height: AppSpacing.sm),
          KitSkeletonBox(height: 22, width: 240),
          SizedBox(height: AppSpacing.md),
          KitSkeletonBox(height: 46, width: 220),
          SizedBox(height: AppSpacing.md),
          KitSkeletonBox(height: 8, width: double.infinity),
          SizedBox(height: AppSpacing.md),
          KitSkeletonBox(height: 18, width: 260),
        ],
      ),
    );
  }
}

class _InlineMetric extends StatelessWidget {
  const _InlineMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label: $value',
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class _MiniIndicator extends StatelessWidget {
  const _MiniIndicator({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return StatusPill(label: label, tone: KitBadgeTone.info);
  }
}

class _ProgressSummaryBar extends StatelessWidget {
  const _ProgressSummaryBar({required this.paid, required this.total});

  final int paid;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : (paid / total).clamp(0, 1).toDouble();
    return ClipRRect(
      borderRadius: AppRadius.pillRounded,
      child: LinearProgressIndicator(value: progress, minHeight: 10),
    );
  }
}

bool _isBasicsComplete(GroupRulesModel? rules) {
  return rules != null && rules.contributionAmount > 0 && rules.roundSize >= 2;
}

bool _isTimingComplete(GroupRulesModel? rules) {
  if (rules == null) {
    return false;
  }
  if (rules.frequency == GroupRuleFrequencyModel.unknown ||
      rules.startPolicy == StartPolicyModel.unknown) {
    return false;
  }
  if (rules.frequency == GroupRuleFrequencyModel.customInterval &&
      (rules.customIntervalDays ?? 0) <= 0) {
    return false;
  }
  if (rules.startPolicy == StartPolicyModel.onDate && rules.startAt == null) {
    return false;
  }
  return true;
}

bool _isPolicyComplete(GroupRulesModel? rules) {
  if (rules == null) {
    return false;
  }
  if (rules.payoutMode == GroupRulePayoutModeModel.unknown ||
      rules.winnerSelectionTiming == WinnerSelectionTimingModel.unknown ||
      rules.paymentMethods.isEmpty ||
      rules.graceDays < 0) {
    return false;
  }
  if (rules.fineType == GroupRuleFineTypeModel.fixedAmount &&
      rules.fineAmount <= 0) {
    return false;
  }
  return true;
}

String _basicsSummary(GroupModel group, GroupRulesModel? rules) {
  if (!_isBasicsComplete(rules)) {
    return 'Set contribution amount and round size.';
  }
  return '${formatCurrency(rules!.contributionAmount, group.currency)} contribution, ${rules.roundSize} members per round.';
}

String _timingSummary(GroupRulesModel? rules) {
  if (!_isTimingComplete(rules)) {
    return 'Choose frequency, start policy, and start timing.';
  }

  final frequency = switch (rules!.frequency) {
    GroupRuleFrequencyModel.weekly => 'Weekly',
    GroupRuleFrequencyModel.monthly => 'Monthly',
    GroupRuleFrequencyModel.customInterval =>
      'Every ${rules.customIntervalDays} days',
    GroupRuleFrequencyModel.unknown => 'Custom',
  };
  final startPolicy = switch (rules.startPolicy) {
    StartPolicyModel.whenFull => 'Starts when full',
    StartPolicyModel.manual =>
      'Manual start at ${rules.requiredToStart} ready members',
    StartPolicyModel.onDate =>
      'Starts ${rules.startAt == null ? 'on date' : formatDate(rules.startAt!)}',
    StartPolicyModel.unknown => 'Start policy pending',
  };
  return '$frequency cadence. $startPolicy.';
}

String _policySummary(GroupRulesModel? rules) {
  if (!_isPolicyComplete(rules)) {
    return 'Set payout mode, late rules, and verification requirements.';
  }

  final payoutMode = switch (rules!.payoutMode) {
    GroupRulePayoutModeModel.lottery => 'Lottery payout',
    GroupRulePayoutModeModel.auction => 'Auction payout',
    GroupRulePayoutModeModel.rotation => 'Rotation payout',
    GroupRulePayoutModeModel.decision => 'Decision payout',
    GroupRulePayoutModeModel.unknown => 'Custom payout',
  };
  final finePolicy = switch (rules.fineType) {
    GroupRuleFineTypeModel.none => 'no late fine',
    GroupRuleFineTypeModel.fixedAmount => 'fine ${rules.fineAmount}',
    GroupRuleFineTypeModel.unknown => 'custom fine',
  };
  final winnerTiming = switch (rules.winnerSelectionTiming) {
    WinnerSelectionTimingModel.beforeCollection => 'winner before collection',
    WinnerSelectionTimingModel.afterCollection => 'winner after collection',
    WinnerSelectionTimingModel.unknown => 'winner timing pending',
  };
  final verification = rules.requiresMemberVerification
      ? 'verification required'
      : 'joined members eligible';
  return '$payoutMode, $winnerTiming, ${rules.graceDays} grace day(s), $finePolicy, $verification.';
}

bool _canVerifyMember(MemberStatusModel status) {
  return status == MemberStatusModel.joined ||
      status == MemberStatusModel.invited ||
      status == MemberStatusModel.active;
}

String _memberStatusCopy(MemberStatusModel status) {
  return switch (status) {
    MemberStatusModel.invited => 'Invited',
    MemberStatusModel.joined => 'Joined',
    MemberStatusModel.verified => 'Verified',
    MemberStatusModel.suspended => 'Suspended',
    MemberStatusModel.active => 'Verified',
    MemberStatusModel.left => 'Left',
    MemberStatusModel.removed => 'Removed',
    MemberStatusModel.unknown => 'Unknown',
  };
}

String _startDisabledReason({
  required bool isAdmin,
  required GroupModel group,
  required GroupRulesModel? rules,
  required int? missingCount,
}) {
  if (!isAdmin) {
    return 'An admin will start the group when everything is ready.';
  }
  if (!_isBasicsComplete(rules) ||
      !_isTimingComplete(rules) ||
      !_isPolicyComplete(rules)) {
    return 'Complete setup first.';
  }
  if (rules == null) {
    return 'Complete setup first.';
  }
  if (rules.readiness.isWaitingForDate) {
    return rules.startAt == null
        ? 'Wait until the scheduled start date.'
        : 'Wait until ${formatDate(rules.startAt!)} to start.';
  }
  if (rules.readiness.isWaitingForMembers || !group.canStartCycle) {
    final count = missingCount ?? 0;
    if (count <= 0) {
      return 'Invite and verify members before starting.';
    }
    if (rules.requiresMemberVerification) {
      return 'Verify at least $count more member${count == 1 ? '' : 's'}.';
    }
    return 'Add at least $count more eligible member${count == 1 ? '' : 's'}.';
  }
  return 'Start the group when everything is ready.';
}

StatusPill _buildStagePill(TurnStatusPresentation status) {
  final tone = switch (status.stage) {
    TurnStage.waiting => KitBadgeTone.warning,
    TurnStage.collecting => KitBadgeTone.info,
    TurnStage.readyForWinnerSelection => KitBadgeTone.warning,
    TurnStage.auction => KitBadgeTone.info,
    TurnStage.readyForPayout => KitBadgeTone.warning,
    TurnStage.payoutSent => KitBadgeTone.info,
    TurnStage.completed => KitBadgeTone.success,
  };
  return StatusPill(label: status.label, tone: tone);
}

String? _turnWinnerLabel(CycleModel cycle, PayoutModel? payout) {
  final payoutLabel = payout?.recipientLabel.trim();
  if (payoutLabel != null && payoutLabel.isNotEmpty) {
    return payoutLabel;
  }
  if (cycle.selectedWinnerUserId == null) {
    return null;
  }

  final user =
      cycle.selectedWinnerUser ?? cycle.finalPayoutUser ?? cycle.payoutUser;
  final fullName = user?.fullName?.trim();
  if (fullName != null && fullName.isNotEmpty) {
    return fullName;
  }

  final phone = user?.phone?.trim();
  if (phone != null && phone.isNotEmpty) {
    return phone;
  }

  final fallbackId = cycle.selectedWinnerUserId;
  if (fallbackId == null || fallbackId.trim().isEmpty) {
    return null;
  }
  return fallbackId;
}

String _winnerCopy(CycleModel cycle, PayoutModel? payout) {
  final winnerLabel = _turnWinnerLabel(cycle, payout);
  if (winnerLabel != null) {
    return 'This turn\'s winner: $winnerLabel';
  }
  return _winnerPendingCopy(cycle);
}

String _winnerPendingCopy(CycleModel cycle) {
  final auctionStatus = cycle.auctionStatus ?? AuctionStatusModel.none;
  if (auctionStatus == AuctionStatusModel.open) {
    return 'Winner is pending while the auction is still open.';
  }
  if (cycle.state == CycleStateModel.collecting &&
      cycle.selectedWinnerUserId == null) {
    return 'Winner will be drawn after collection is complete.';
  }
  if (cycle.state == CycleStateModel.readyForWinnerSelection) {
    return 'Collection is complete. Draw the winner to continue.';
  }
  if (cycle.state == CycleStateModel.readyForPayout) {
    return 'Winner selected. Mark payout sent to continue.';
  }
  if (cycle.state == CycleStateModel.payoutSent) {
    return 'Payout was sent. Waiting for the winner to confirm receipt.';
  }
  return 'Winner selection will appear here once this turn progresses.';
}

int _paidCount(ContributionSummaryModel? summary) {
  if (summary == null) {
    return 0;
  }
  return summary.submitted +
      summary.paidSubmitted +
      summary.verified +
      summary.confirmed;
}

int _turnPotSize({
  required ContributionListModel? contributions,
  required int fallbackAmount,
  required int totalMembers,
}) {
  final items = contributions?.items ?? const <ContributionModel>[];
  if (items.isNotEmpty) {
    return items.fold<int>(0, (sum, item) => sum + item.amount);
  }
  return fallbackAmount * totalMembers;
}
