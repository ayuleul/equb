import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../data/models/group_model.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/ui/ui.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../groups/group_detail_controller.dart';
import '../generate_cycle_controller.dart';

class GenerateCycleScreen extends ConsumerWidget {
  const GenerateCycleScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupDetailProvider(groupId));

    return KitScaffold(
      appBar: const KitAppBar(title: 'Generate cycles'),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Generate count',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Choose how many cycles to generate (1-12).',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<int>(
                initialValue: state.count,
                decoration: const InputDecoration(labelText: 'Cycle count'),
                items: List<DropdownMenuItem<int>>.generate(
                  12,
                  (index) => DropdownMenuItem<int>(
                    value: index + 1,
                    child: Text('${index + 1}'),
                  ),
                ),
                onChanged: state.isSubmitting
                    ? null
                    : (value) {
                        if (value != null) {
                          ref
                              .read(
                                generateCycleControllerProvider(
                                  groupId,
                                ).notifier,
                              )
                              .setCount(value);
                        }
                      },
              ),
            ],
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
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: state.isSubmitting
              ? null
              : () async {
                  final generated = await ref
                      .read(generateCycleControllerProvider(groupId).notifier)
                      .generate();

                  if (!context.mounted || generated == null) {
                    return;
                  }

                  AppSnackbars.success(
                    context,
                    'Generated ${generated.length} cycle(s).',
                  );
                  Navigator.of(context).pop();
                },
          child: Text(state.isSubmitting ? 'Generating...' : 'Generate'),
        ),
      ],
    );
  }
}
