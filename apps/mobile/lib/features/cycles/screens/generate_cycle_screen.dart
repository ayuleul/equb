import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/group_model.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../groups/group_detail_controller.dart';
import '../generate_cycle_controller.dart';

class GenerateCycleScreen extends ConsumerWidget {
  const GenerateCycleScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupDetailProvider(groupId));

    return Scaffold(
      appBar: AppBar(title: const Text('Generate Cycles')),
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
                    'Only admins can generate cycles.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              );
            }

            return _GenerateCycleBody(groupId: groupId);
          },
        ),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(nextError)));
      }
    });

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text(
          'Select how many cycles to generate (1 to 12).',
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
                        .read(generateCycleControllerProvider(groupId).notifier)
                        .setCount(value);
                  }
                },
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
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: 'Generate',
          isLoading: state.isSubmitting,
          onPressed: state.isSubmitting
              ? null
              : () async {
                  final generated = await ref
                      .read(generateCycleControllerProvider(groupId).notifier)
                      .generate();

                  if (!context.mounted || generated == null) {
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Generated ${generated.length} cycle(s).'),
                    ),
                  );

                  context.go(AppRoutePaths.groupCycles(groupId));
                },
        ),
      ],
    );
  }
}
