import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../data/models/group_model.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/ui/ui.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../groups/group_detail_controller.dart';
import '../payout_order_controller.dart';

class PayoutOrderScreen extends ConsumerWidget {
  const PayoutOrderScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupDetailProvider(groupId));

    return KitScaffold(
      appBar: const KitAppBar(title: 'Payout order'),
      child: groupAsync.when(
        loading: () => const LoadingView(message: 'Loading group...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () =>
              ref.read(groupDetailControllerProvider).refreshGroup(groupId),
        ),
        data: (group) {
          final isAdmin = group.membership?.role == MemberRoleModel.admin;
          if (!isAdmin) {
            return const EmptyState(
              icon: Icons.lock_outline,
              title: 'Admin only',
              message: 'Only admins can update payout order.',
            );
          }

          return _PayoutOrderBody(groupId: groupId);
        },
      ),
    );
  }
}

class _PayoutOrderBody extends ConsumerWidget {
  const _PayoutOrderBody({required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(payoutOrderControllerProvider(groupId));

    ref.listen(payoutOrderControllerProvider(groupId), (previous, next) {
      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;
      if (nextError != null &&
          nextError.isNotEmpty &&
          previousError != nextError) {
        AppSnackbars.error(context, nextError);
      }
    });

    if (state.isLoading && !state.hasData) {
      return const LoadingView(message: 'Loading active members...');
    }

    if (!state.isLoading && !state.hasData) {
      return ErrorView(
        message: state.errorMessage ?? 'No active members found.',
        onRetry: () => ref
            .read(payoutOrderControllerProvider(groupId).notifier)
            .loadMembers(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EqubCard(
          child: Text(
            'Drag to reorder. Positions are always saved as contiguous 1..N.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        if (state.hasMissingNames) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Some members have no full name. Fallback labels are shown.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: ReorderableListView.builder(
            itemCount: state.members.length,
            onReorder: (oldIndex, newIndex) {
              ref
                  .read(payoutOrderControllerProvider(groupId).notifier)
                  .reorder(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final member = state.members[index];
              return EqubCard(
                key: ValueKey(member.userId),
                child: EqubListTile(
                  title: member.displayName,
                  subtitle: 'Payout position #${index + 1}',
                  showChevron: false,
                  trailing: const Icon(Icons.drag_indicator_rounded),
                ),
              );
            },
          ),
        ),
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            state.errorMessage!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        FilledButton(
          onPressed: state.isSaving
              ? null
              : () async {
                  final success = await ref
                      .read(payoutOrderControllerProvider(groupId).notifier)
                      .save();

                  if (!context.mounted || !success) {
                    return;
                  }

                  AppSnackbars.success(context, 'Payout order saved');
                  Navigator.of(context).pop();
                },
          child: Text(state.isSaving ? 'Saving...' : 'Save payout order'),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}
