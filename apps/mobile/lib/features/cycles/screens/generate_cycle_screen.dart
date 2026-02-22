import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../data/models/group_model.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/ui/ui.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../current_cycle_provider.dart';
import '../../groups/group_detail_controller.dart';
import '../generate_cycle_controller.dart';

class GenerateCycleScreen extends ConsumerWidget {
  const GenerateCycleScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupDetailProvider(groupId));

    return KitScaffold(
      appBar: const KitAppBar(title: 'Generate next cycle'),
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
              message: 'Only admins can generate cycles.',
            );
          }

          return _GenerateCycleBody(groupId: groupId);
        },
      ),
    );
  }
}

class _GenerateCycleBody extends ConsumerWidget {
  const _GenerateCycleBody({required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(generateCycleControllerProvider(groupId));
    final currentCycleAsync = ref.watch(currentCycleProvider(groupId));

    ref.listen(generateCycleControllerProvider(groupId), (previous, next) {
      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;
      if (nextError != null &&
          nextError.isNotEmpty &&
          previousError != nextError) {
        AppSnackbars.error(context, nextError);
      }
    });

    return ListView(
      children: [
        EqubCard(
          child: currentCycleAsync.when(
            loading: () =>
                const LoadingView(message: 'Checking current cycle...'),
            error: (error, _) => ErrorView(
              message: error.toString(),
              onRetry: () => ref.invalidate(currentCycleProvider(groupId)),
            ),
            data: (currentCycle) {
              if (currentCycle != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Finish current cycle first',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Cycle #${currentCycle.cycleNo} is still open. Close it before generating the next cycle.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Generate next cycle',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'This creates exactly one next cycle in sequence.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    onPressed: state.isSubmitting
                        ? null
                        : () async {
                            final generated = await ref
                                .read(
                                  generateCycleControllerProvider(
                                    groupId,
                                  ).notifier,
                                )
                                .generateNextCycle();

                            if (!context.mounted || generated == null) {
                              return;
                            }

                            AppSnackbars.success(
                              context,
                              'Next cycle generated.',
                            );
                            Navigator.of(context).pop();
                          },
                    child: Text(
                      state.isSubmitting
                          ? 'Generating next cycle...'
                          : 'Generate next cycle',
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        if (state.errorMessage != null &&
            state.errorMessage!.isNotEmpty &&
            !state.isRoundCompleted) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            state.errorMessage!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
        if (state.isRoundCompleted) ...[
          const SizedBox(height: AppSpacing.sm),
          KitCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Round completed',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'This round has finished all scheduled positions. Start a new round to continue.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
