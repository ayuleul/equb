import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/bootstrap.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/cycle_model.dart';
import '../../../data/models/group_model.dart';
import '../../auth/auth_controller.dart';
import '../../../shared/utils/date_formatter.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('Cycles')),
      body: SafeArea(
        child: groupAsync.when(
          loading: () => const LoadingView(message: 'Loading group...'),
          error: (error, _) => ErrorView(
            message: error.toString(),
            onRetry: () =>
                ref.read(groupDetailControllerProvider).refreshGroup(groupId),
          ),
          data: (group) => _CyclesOverviewBody(group: group),
        ),
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
      final membersAsync = ref.watch(groupMembersProvider(group.id));
      final members = membersAsync.valueOrNull;
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
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _CurrentCycleCard(
            groupId: group.id,
            currentCycleAsync: currentCycleAsync,
          ),
          const SizedBox(height: AppSpacing.md),
          if (isAdmin)
            FilledButton.icon(
              onPressed: () =>
                  context.go(AppRoutePaths.groupCyclesGenerate(group.id)),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Generate next cycle'),
            ),
          if (isAdmin) const SizedBox(height: AppSpacing.md),
          Text('Recent cycles', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          cyclesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: LoadingView(message: 'Loading cycles...'),
            ),
            error: (error, _) => ErrorView(
              message: error.toString(),
              onRetry: () {
                ref
                    .read(cyclesRepositoryProvider)
                    .invalidateGroupCache(group.id);
                ref.invalidate(cyclesListProvider(group.id));
              },
            ),
            data: (cycles) {
              if (cycles.isEmpty) {
                return _EmptyCyclesView(groupId: group.id, isAdmin: isAdmin);
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current cycle',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            currentCycleAsync.when(
              loading: () => const Text('Loading current cycle...'),
              error: (error, _) => Text(error.toString()),
              data: (cycle) {
                if (cycle == null) {
                  return const Text('No open cycle yet.');
                }

                final recipient = _recipientLabel(cycle);
                final statusLabel = switch (cycle.status) {
                  CycleStatusModel.open => 'OPEN',
                  CycleStatusModel.closed => 'CLOSED',
                  CycleStatusModel.unknown => 'UNKNOWN',
                };

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cycle #${cycle.cycleNo}'),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Due date: ${formatFriendlyDate(cycle.dueDate)}'),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Recipient: $recipient'),
                    const SizedBox(height: AppSpacing.xs),
                    Chip(label: Text(statusLabel)),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton(
                      onPressed: () => context.go(
                        AppRoutePaths.groupCycleDetail(groupId, cycle.id),
                      ),
                      child: const Text('View current cycle'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCyclesView extends StatelessWidget {
  const _EmptyCyclesView({required this.groupId, required this.isAdmin});

  final String groupId;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAdmin
                  ? 'No cycles yet. Set payout order, then generate the first cycle.'
                  : 'No cycles generated yet. Ask a group admin to generate the first cycle.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (isAdmin) ...[
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  OutlinedButton.icon(
                    onPressed: () =>
                        context.go(AppRoutePaths.groupPayoutOrder(groupId)),
                    icon: const Icon(Icons.swap_vert),
                    label: const Text('Set payout order'),
                  ),
                  FilledButton.icon(
                    onPressed: () =>
                        context.go(AppRoutePaths.groupCyclesGenerate(groupId)),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Generate first cycle'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
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

    return Card(
      child: ListTile(
        onTap: () =>
            context.go(AppRoutePaths.groupCycleDetail(groupId, cycle.id)),
        title: Text('Cycle #${cycle.cycleNo}'),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Due: ${formatFriendlyDate(cycle.dueDate)}'),
              const SizedBox(height: AppSpacing.xs),
              Text('Recipient: ${_recipientLabel(cycle)}'),
            ],
          ),
        ),
        trailing: Chip(label: Text(statusLabel)),
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
