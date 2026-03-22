import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/bootstrap.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/cycle_model.dart';
import '../../../data/models/group_model.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/ui/ui.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../groups/group_detail_controller.dart';
import '../current_cycle_provider.dart';
import '../cycles_list_provider.dart';

class CyclesOverviewScreen extends ConsumerWidget {
  const CyclesOverviewScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupDetailProvider(groupId));

    return KitScaffold(
      appBar: const KitAppBar(title: 'Cycles'),
      child: groupAsync.when(
        loading: () => const LoadingView(message: 'Loading group...'),
        error: (error, _) => ErrorView(
          message: mapFriendlyError(error),
          onRetry: () =>
              ref.read(groupDetailControllerProvider).refreshGroup(groupId),
        ),
        data: (group) => _CyclesOverviewBody(group: group),
      ),
    );
  }
}

class _CyclesOverviewBody extends ConsumerWidget {
  const _CyclesOverviewBody({required this.group});

  final GroupModel group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCycleAsync = ref.watch(currentCycleProvider(group.id));
    final cyclesAsync = ref.watch(cyclesListProvider(group.id));

    final isAdmin = group.membership?.role == MemberRoleModel.admin;

    Future<void> onRefresh() async {
      ref.read(cyclesRepositoryProvider).invalidateGroupCache(group.id);
      ref.read(groupsRepositoryProvider).invalidateGroup(group.id);
      await Future.wait([
        ref.refresh(groupDetailProvider(group.id).future),
        ref.refresh(currentCycleProvider(group.id).future),
        ref.refresh(cyclesListProvider(group.id).future),
      ]);
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: cyclesAsync.when(
        loading: () => ListView(
          children: [
            SizedBox(height: AppSpacing.md),
            KitCard(
              child: SizedBox(
                height: 180,
                child: KitSkeletonList(itemCount: 3),
              ),
            ),
          ],
        ),
        error: (error, _) => ListView(
          children: [
            ErrorView(
              message: mapFriendlyError(error),
              onRetry: () {
                ref
                    .read(cyclesRepositoryProvider)
                    .invalidateGroupCache(group.id);
                ref.invalidate(cyclesListProvider(group.id));
              },
            ),
          ],
        ),
        data: (cycles) {
          final cycleSummaries = _buildCycleSummaries(cycles);
          final currentCycle = currentCycleAsync.valueOrNull;
          final activeCycleSummary = currentCycle == null
              ? null
              : cycleSummaries.cast<_CycleSummary?>().firstWhere(
                  (summary) => summary?.roundId == currentCycle.roundId,
                  orElse: () => null,
                );
          final pastCycleSummaries = cycleSummaries
              .where((summary) => summary.roundId != currentCycle?.roundId)
              .toList(growable: false);

          return ListView(
            children: [
              if (isAdmin) ...[
                KitBanner(
                  title: group.canStartCycle
                      ? 'Configuration ready'
                      : 'Configuration required',
                  message: group.canStartCycle
                      ? 'Review or update the group configuration at any time.'
                      : 'Finish group configuration and ensure at least 2 eligible members before starting the first cycle.',
                  tone: group.canStartCycle
                      ? KitBadgeTone.info
                      : KitBadgeTone.warning,
                  icon: group.canStartCycle
                      ? Icons.tune_rounded
                      : Icons.rule_folder_outlined,
                  ctaLabel: group.canStartCycle
                      ? 'Edit configuration'
                      : 'Open configuration',
                  onCtaPressed: () =>
                      context.push(AppRoutePaths.groupSetup(group.id)),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              _CurrentCycleCard(
                groupId: group.id,
                currentCycle: currentCycle,
                cycleSummary: activeCycleSummary,
              ),
              const SizedBox(height: AppSpacing.md),
              if (isAdmin && currentCycle == null && group.canStartCycle)
                KitPrimaryButton(
                  onPressed: () =>
                      context.push(AppRoutePaths.groupDetail(group.id)),
                  icon: Icons.add_circle_outline,
                  label: cycles.isEmpty
                      ? 'Start First Cycle'
                      : 'Start New Cycle',
                ),
              if (isAdmin && currentCycle == null && !group.canStartCycle)
                KitPrimaryButton(
                  onPressed: () =>
                      context.push(AppRoutePaths.groupSetup(group.id)),
                  icon: Icons.rule_folder_outlined,
                  label: 'Finish configuration to start',
                ),
              if (isAdmin && currentCycle != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Text(
                    'Finish the current open turn before starting the next cycle.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              if (isAdmin && currentCycle == null)
                const SizedBox(height: AppSpacing.md),
              const KitSectionHeader(title: 'Past cycles'),
              if (cycleSummaries.isEmpty)
                _EmptyCyclesView(
                  isAdmin: isAdmin,
                  canStartCycle: group.canStartCycle,
                )
              else if (pastCycleSummaries.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.xs),
                  child: Text('No completed cycles yet.'),
                )
              else
                ...pastCycleSummaries.map(
                  (summary) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _CycleListTile(groupId: group.id, summary: summary),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CurrentCycleCard extends StatelessWidget {
  const _CurrentCycleCard({
    required this.groupId,
    required this.currentCycle,
    required this.cycleSummary,
  });

  final String groupId;
  final CycleModel? currentCycle;
  final _CycleSummary? cycleSummary;

  @override
  Widget build(BuildContext context) {
    return KitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Current cycle', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          if (currentCycle == null)
            const Text('No open cycle right now.')
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cycleSummary?.label ?? 'Current cycle',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Turn ${currentCycle!.cycleNo}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text('Due ${formatDate(currentCycle!.dueDate)}'),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Turns completed: ${cycleSummary?.completedTurnCount ?? 0} / ${cycleSummary?.turnCount ?? 0}',
                ),
                const SizedBox(height: AppSpacing.xs),
                Text('Recipient: ${_recipientLabel(currentCycle!)}'),
                const SizedBox(height: AppSpacing.sm),
                KitSecondaryButton(
                  onPressed: () => context.push(
                    AppRoutePaths.groupCycleDetail(groupId, currentCycle!.id),
                  ),
                  label: 'View current turn',
                  expand: false,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _EmptyCyclesView extends StatelessWidget {
  const _EmptyCyclesView({required this.isAdmin, required this.canStartCycle});

  final bool isAdmin;
  final bool canStartCycle;

  @override
  Widget build(BuildContext context) {
    return KitEmptyState(
      icon: Icons.timelapse_outlined,
      title: 'No cycles generated',
      message: isAdmin
          ? canStartCycle
                ? 'Start the first cycle from current turn.'
                : 'Finish configuration before starting the first cycle.'
          : 'Ask a group admin to start the first cycle.',
    );
  }
}

class _CycleListTile extends StatelessWidget {
  const _CycleListTile({required this.groupId, required this.summary});

  final String groupId;
  final _CycleSummary summary;

  @override
  Widget build(BuildContext context) {
    return KitCard(
      child: EqubListTile(
        title: summary.label,
        subtitle:
            '${summary.turnCount} turns • Last payout: ${summary.lastRecipientLabel}',
        onTap: () => context.push(
          AppRoutePaths.groupCycleDetail(groupId, summary.lastTurn.id),
        ),
        trailing: StatusPill.fromLabel(
          summary.isCompleted ? 'COMPLETED' : 'ACTIVE',
        ),
      ),
    );
  }
}

class _CycleSummary {
  const _CycleSummary({
    required this.roundId,
    required this.label,
    required this.turnCount,
    required this.completedTurnCount,
    required this.isCompleted,
    required this.lastRecipientLabel,
    required this.lastTurn,
  });

  final String roundId;
  final String label;
  final int turnCount;
  final int completedTurnCount;
  final bool isCompleted;
  final String lastRecipientLabel;
  final CycleModel lastTurn;
}

List<_CycleSummary> _buildCycleSummaries(List<CycleModel> cycles) {
  if (cycles.isEmpty) {
    return const <_CycleSummary>[];
  }

  final orderedCycles = [...cycles]
    ..sort((a, b) {
      final aCreated = a.createdAt ?? a.dueDate;
      final bCreated = b.createdAt ?? b.dueDate;
      return bCreated.compareTo(aCreated);
    });
  final grouped = <String, List<CycleModel>>{};
  for (final cycle in orderedCycles) {
    final roundId = cycle.roundId ?? cycle.id;
    grouped.putIfAbsent(roundId, () => <CycleModel>[]).add(cycle);
  }

  final roundIdsNewestFirst = grouped.keys.toList(growable: false);
  final roundIdsOldestFirst = roundIdsNewestFirst.reversed.toList(
    growable: false,
  );
  final roundNumberById = <String, int>{};
  for (var index = 0; index < roundIdsOldestFirst.length; index++) {
    roundNumberById[roundIdsOldestFirst[index]] = index + 1;
  }

  return roundIdsNewestFirst
      .map((roundId) {
        final turns = grouped[roundId]!
          ..sort((a, b) => a.cycleNo.compareTo(b.cycleNo));
        final lastTurn = turns.last;
        return _CycleSummary(
          roundId: roundId,
          label: 'Cycle ${roundNumberById[roundId]}',
          turnCount: turns.length,
          completedTurnCount: turns
              .where((turn) => turn.status == CycleStatusModel.closed)
              .length,
          isCompleted: turns.every(
            (turn) => turn.status == CycleStatusModel.closed,
          ),
          lastRecipientLabel: _recipientLabel(lastTurn),
          lastTurn: lastTurn,
        );
      })
      .toList(growable: false);
}

String _recipientLabel(CycleModel cycle) {
  final fullName = cycle.payoutUser?.fullName?.trim();
  if (fullName != null && fullName.isNotEmpty) {
    return fullName;
  }
  final phone = cycle.payoutUser?.phone?.trim();
  if (phone != null && phone.isNotEmpty) {
    return phone;
  }
  return cycle.payoutUserId;
}
