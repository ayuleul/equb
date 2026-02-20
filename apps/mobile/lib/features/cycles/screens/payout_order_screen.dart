import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../data/models/group_model.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../groups/group_detail_controller.dart';
import '../payout_order_controller.dart';

class PayoutOrderScreen extends ConsumerWidget {
  const PayoutOrderScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupDetailProvider(groupId));

    return Scaffold(
      appBar: AppBar(title: const Text('Payout Order')),
      body: SafeArea(
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
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'Only admins can update payout order.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              );
            }

            return _PayoutOrderBody(groupId: groupId);
          },
        ),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(nextError)));
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

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Drag members to set payout order. Positions are saved as 1..N.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (state.hasMissingNames) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Some members have no full name. Phone or fallback labels will be used.',
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
                final initials = _initials(member.displayName);

                return Card(
                  key: ValueKey(member.userId),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(initials)),
                    title: Text(member.displayName),
                    subtitle: Text('Payout position #${index + 1}'),
                    trailing: const Icon(Icons.drag_handle),
                  ),
                );
              },
            ),
          ),
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              state.errorMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: 'Save payout order',
            isLoading: state.isSaving,
            onPressed: state.isSaving
                ? null
                : () async {
                    final success = await ref
                        .read(payoutOrderControllerProvider(groupId).notifier)
                        .save();

                    if (!context.mounted || !success) {
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Payout order updated successfully.'),
                      ),
                    );
                    Navigator.of(context).pop();
                  },
          ),
        ],
      ),
    );
  }
}

String _initials(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) {
    return 'M';
  }

  final parts = trimmed
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);

  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }

  final first = parts.first.substring(0, 1);
  final last = parts.last.substring(0, 1);
  return '$first$last'.toUpperCase();
}
