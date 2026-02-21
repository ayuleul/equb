import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/ui/ui.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../cycles/payout_order_controller.dart';

class GroupPayoutOrderTab extends ConsumerWidget {
  const GroupPayoutOrderTab({
    super.key,
    required this.groupId,
    required this.isAdmin,
  });

  final String groupId;
  final bool isAdmin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isAdmin) {
      return const KitCard(
        child: EmptyState(
          icon: Icons.lock_outline,
          title: 'Admin only',
          message: 'Only admins can update payout order.',
        ),
      );
    }

    final state = ref.watch(payoutOrderControllerProvider(groupId));
    final controller = ref.read(
      payoutOrderControllerProvider(groupId).notifier,
    );

    return KitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payout order',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Use arrows to move members up or down. Order is saved as contiguous 1..N.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          if (state.isLoading && !state.hasData)
            const LoadingView(message: 'Loading active members...'),
          if (!state.isLoading && !state.hasData)
            ErrorView(
              message: state.errorMessage ?? 'No active members found.',
              onRetry: controller.loadMembers,
            ),
          if (state.hasData)
            Column(
              children: [
                for (var i = 0; i < state.members.length; i++) ...[
                  EqubCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.members[i].displayName,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                'Position #${i + 1}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Move up',
                          onPressed: i == 0
                              ? null
                              : () => controller.reorder(i, i - 1),
                          icon: const Icon(Icons.keyboard_arrow_up_rounded),
                        ),
                        IconButton(
                          tooltip: 'Move down',
                          onPressed: i == state.members.length - 1
                              ? null
                              : () => controller.reorder(i, i + 2),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        ),
                      ],
                    ),
                  ),
                  if (i != state.members.length - 1)
                    const SizedBox(height: AppSpacing.sm),
                ],
                const SizedBox(height: AppSpacing.md),
                KitPrimaryButton(
                  label: state.isSaving ? 'Saving...' : 'Save payout order',
                  onPressed: state.isSaving
                      ? null
                      : () async {
                          final success = await controller.save();
                          if (!context.mounted || !success) {
                            return;
                          }
                          AppSnackbars.success(context, 'Payout order saved');
                        },
                ),
              ],
            ),
          if (state.errorMessage != null &&
              state.errorMessage!.isNotEmpty &&
              state.hasData) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              state.errorMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
