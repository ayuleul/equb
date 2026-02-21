import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/cycle_model.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../cycle_detail_provider.dart';

class CycleDetailScreen extends ConsumerWidget {
  const CycleDetailScreen({
    super.key,
    required this.groupId,
    required this.cycleId,
  });

  final String groupId;
  final String cycleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cycleAsync = ref.watch(
      cycleDetailProvider((groupId: groupId, cycleId: cycleId)),
    );

    return KitScaffold(
      appBar: const KitAppBar(title: 'Cycle detail'),
      child: cycleAsync.when(
        loading: () => const LoadingView(message: 'Loading cycle...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(
            cycleDetailProvider((groupId: groupId, cycleId: cycleId)),
          ),
        ),
        data: (cycle) =>
            _CycleDetailBody(groupId: groupId, cycleId: cycleId, cycle: cycle),
      ),
    );
  }
}

class _CycleDetailBody extends StatelessWidget {
  const _CycleDetailBody({
    required this.groupId,
    required this.cycleId,
    required this.cycle,
  });

  final String groupId;
  final String cycleId;
  final CycleModel cycle;

  @override
  Widget build(BuildContext context) {
    final statusLabel = switch (cycle.status) {
      CycleStatusModel.open => 'OPEN',
      CycleStatusModel.closed => 'CLOSED',
      CycleStatusModel.unknown => 'UNKNOWN',
    };

    return ListView(
      children: [
        KitCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Cycle #${cycle.cycleNo}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  StatusPill.fromLabel(statusLabel),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('Due date: ${formatDate(cycle.dueDate)}'),
              const SizedBox(height: AppSpacing.xs),
              Text('Recipient: ${_recipientLabel(cycle)}'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const KitSectionHeader(title: 'Quick actions'),
        KitCard(
          child: Column(
            children: [
              ListTile(
                title: const Text('Contributions'),
                subtitle: const Text('View submissions and statuses'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(
                  AppRoutePaths.groupCycleContributions(groupId, cycleId),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              ListTile(
                title: const Text('Payout'),
                subtitle: const Text(
                  'Track payout confirmation and cycle closure',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(
                  AppRoutePaths.groupCyclePayout(groupId, cycleId),
                ),
              ),
            ],
          ),
        ),
      ],
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
