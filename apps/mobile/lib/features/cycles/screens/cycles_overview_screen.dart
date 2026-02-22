import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/bootstrap.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/cycle_model.dart';
import '../../../data/models/group_model.dart';
import '../../../shared/copy/lottery_copy.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/ui/ui.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../auth/auth_controller.dart';
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

    final isAdminFromGroup = group.membership?.role == MemberRoleModel.admin;
    final currentUser = ref.watch(currentUserProvider);
    var isAdminFromMembers = false;
    if (!isAdminFromGroup && currentUser != null) {
      final members = ref.watch(groupMembersProvider(group.id)).valueOrNull;
      if (members != null) {
        for (final member in members) {
          if (member.userId == currentUser.id &&
              member.status == MemberStatusModel.active &&
              member.role == MemberRoleModel.admin) {
            isAdminFromMembers = true;
            break;
          }
        }
      }
    }
    final isAdmin = isAdminFromGroup || isAdminFromMembers;

    Future<void> onRefresh() async {
      ref.read(cyclesRepositoryProvider).invalidateGroupCache(group.id);
      ref.read(groupsRepositoryProvider).invalidateGroup(group.id);
      ref.read(groupsRepositoryProvider).invalidateMembers(group.id);
      await Future.wait([
        ref.refresh(groupDetailProvider(group.id).future),
        ref.refresh(groupMembersProvider(group.id).future),
        ref.refresh(currentCycleProvider(group.id).future),
        ref.refresh(cyclesListProvider(group.id).future),
      ]);
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        children: [
          _CurrentCycleCard(
            groupId: group.id,
            currentCycleAsync: currentCycleAsync,
          ),
          const SizedBox(height: AppSpacing.md),
          if (isAdmin && currentCycleAsync.valueOrNull == null)
            KitPrimaryButton(
              onPressed: () =>
                  context.push(AppRoutePaths.groupCyclesGenerate(group.id)),
              icon: Icons.add_circle_outline,
              label: LotteryCopy.drawWinnerButton,
            ),
          if (isAdmin && currentCycleAsync.valueOrNull != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                'Finish the current open turn before drawing the next winner.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          if (isAdmin && currentCycleAsync.valueOrNull == null)
            const SizedBox(height: AppSpacing.md),
          const KitSectionHeader(title: 'Past cycles'),
          cyclesAsync.when(
            loading: () => const SizedBox(
              height: 300,
              child: KitSkeletonList(itemCount: 3),
            ),
            error: (error, _) => ErrorView(
              message: mapFriendlyError(error),
              onRetry: () {
                ref
                    .read(cyclesRepositoryProvider)
                    .invalidateGroupCache(group.id);
                ref.invalidate(cyclesListProvider(group.id));
              },
            ),
            data: (cycles) {
              if (cycles.isEmpty) {
                return _EmptyCyclesView(isAdmin: isAdmin);
              }

              return Column(
                children: cycles
                    .map(
                      (cycle) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _CycleListTile(groupId: group.id, cycle: cycle),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CurrentCycleCard extends StatelessWidget {
  const _CurrentCycleCard({
    required this.groupId,
    required this.currentCycleAsync,
  });

  final String groupId;
  final AsyncValue<CycleModel?> currentCycleAsync;

  @override
  Widget build(BuildContext context) {
    return KitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Current cycle', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          currentCycleAsync.when(
            loading: () => const KitSkeletonBox(height: 72),
            error: (error, _) => Text(error.toString()),
            data: (cycle) {
              if (cycle == null) {
                return const Text('No open cycle yet.');
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Turn ${cycle.cycleNo}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Due ${formatDate(cycle.dueDate)}'),
                  const SizedBox(height: AppSpacing.xs),
                  Text('🎲 Winner: ${_recipientLabel(cycle)}'),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Progress: --/-- paid',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  KitSecondaryButton(
                    onPressed: () => context.push(
                      AppRoutePaths.groupCycleDetail(groupId, cycle.id),
                    ),
                    label: 'View current turn',
                    expand: false,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EmptyCyclesView extends StatelessWidget {
  const _EmptyCyclesView({required this.isAdmin});

  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return KitEmptyState(
      icon: Icons.timelapse_outlined,
      title: 'No cycles generated',
      message: isAdmin
          ? 'Draw the first winner to start the round.'
          : 'Ask a group admin to draw the first winner.',
    );
  }
}

class _CycleListTile extends StatelessWidget {
  const _CycleListTile({required this.groupId, required this.cycle});

  final String groupId;
  final CycleModel cycle;

  @override
  Widget build(BuildContext context) {
    final statusLabel = switch (cycle.status) {
      CycleStatusModel.open => 'OPEN',
      CycleStatusModel.closed => 'CLOSED',
      CycleStatusModel.unknown => 'UNKNOWN',
    };

    return KitCard(
      child: EqubListTile(
        title: 'Cycle #${cycle.cycleNo}',
        subtitle:
            'Due ${formatDate(cycle.dueDate)} • ${_recipientLabel(cycle)}',
        onTap: () =>
            context.push(AppRoutePaths.groupCycleDetail(groupId, cycle.id)),
        trailing: StatusPill.fromLabel(statusLabel),
      ),
    );
  }
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
