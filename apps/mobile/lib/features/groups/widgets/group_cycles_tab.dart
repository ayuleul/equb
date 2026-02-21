import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/cycle_model.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/ui/ui.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/error_view.dart';
import '../../cycles/current_cycle_provider.dart';
import '../../cycles/cycles_list_provider.dart';

class GroupCyclesTab extends ConsumerWidget {
  const GroupCyclesTab({
    super.key,
    required this.groupId,
    required this.isAdmin,
  });

  final String groupId;
  final bool isAdmin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCycleAsync = ref.watch(currentCycleProvider(groupId));
    final cyclesAsync = ref.watch(cyclesListProvider(groupId));

    return KitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAdmin)
            KitPrimaryButton(
              label: 'Generate next cycle',
              icon: Icons.add_circle_outline,
              onPressed: () =>
                  context.push(AppRoutePaths.groupCyclesGenerate(groupId)),
            ),
          if (isAdmin) const SizedBox(height: AppSpacing.md),
          Text(
            'Current cycle',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          currentCycleAsync.when(
            loading: () => const KitSkeletonBox(height: 72),
            error: (error, _) => Text(error.toString()),
            data: (cycle) {
              if (cycle == null) {
                return const Text('No open cycle yet.');
              }
              return EqubCard(
                child: EqubListTile(
                  title: 'Cycle #${cycle.cycleNo}',
                  subtitle:
                      'Due ${formatDate(cycle.dueDate)} • ${_recipientLabel(cycle)}',
                  onTap: () => context.push(
                    AppRoutePaths.groupCycleDetail(groupId, cycle.id),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'All cycles',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          cyclesAsync.when(
            loading: () => const KitSkeletonList(itemCount: 3),
            error: (error, _) => ErrorView(
              message: error.toString(),
              onRetry: () => ref.invalidate(cyclesListProvider(groupId)),
            ),
            data: (cycles) {
              if (cycles.isEmpty) {
                return const EmptyState(
                  icon: Icons.timelapse_outlined,
                  title: 'No cycles generated',
                  message:
                      'Create or wait for admins to generate the first cycle.',
                );
              }

              return Column(
                children: [
                  for (var i = 0; i < cycles.length; i++) ...[
                    EqubCard(
                      child: EqubListTile(
                        title: 'Cycle #${cycles[i].cycleNo}',
                        subtitle:
                            'Due ${formatDate(cycles[i].dueDate)} • ${_recipientLabel(cycles[i])}',
                        onTap: () => context.push(
                          AppRoutePaths.groupCycleDetail(groupId, cycles[i].id),
                        ),
                        trailing: StatusPill.fromLabel(
                          cycles[i].status.name.toUpperCase(),
                        ),
                      ),
                    ),
                    if (i != cycles.length - 1)
                      const SizedBox(height: AppSpacing.sm),
                  ],
                ],
              );
            },
          ),
        ],
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
