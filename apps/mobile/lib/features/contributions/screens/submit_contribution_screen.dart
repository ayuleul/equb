import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../data/models/cycle_model.dart';
import '../../../data/models/group_model.dart';
import '../../../data/models/group_rules_model.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/ui/ui.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../cycles/cycle_detail_provider.dart';
import '../../groups/group_detail_controller.dart';
import '../cycle_contributions_provider.dart';
import '../submit_contribution_controller.dart';

class SubmitContributionScreen extends ConsumerStatefulWidget {
  const SubmitContributionScreen({
    super.key,
    required this.groupId,
    required this.cycleId,
    this.initialMethodKey,
  });

  final String groupId;
  final String cycleId;
  final String? initialMethodKey;

  @override
  ConsumerState<SubmitContributionScreen> createState() =>
      _SubmitContributionScreenState();
}

class _SubmitContributionScreenState
    extends ConsumerState<SubmitContributionScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _paymentRefController;
  late final TextEditingController _noteController;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _paymentRefController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _paymentRefController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = (groupId: widget.groupId, cycleId: widget.cycleId);
    final submitState = ref.watch(submitContributionControllerProvider(args));
    final groupAsync = ref.watch(groupDetailProvider(widget.groupId));
    final cycleAsync = ref.watch(
      cycleDetailProvider((groupId: widget.groupId, cycleId: widget.cycleId)),
    );

    ref.listen(submitContributionControllerProvider(args), (previous, next) {
      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;
      if (nextError != null &&
          nextError.isNotEmpty &&
          previousError != nextError) {
        AppSnackbars.error(context, nextError);
      }
    });

    final group = groupAsync.valueOrNull;
    if (group != null && _amountController.text.trim().isEmpty) {
      _amountController.text = group.contributionAmount.toString();
    }

    final selectedMethod =
        _paymentMethodFromKey(widget.initialMethodKey) ??
        GroupPaymentMethodModel.cashAck;
    final screenTitle = switch (selectedMethod) {
      GroupPaymentMethodModel.cashAck => 'Manual payment',
      GroupPaymentMethodModel.telebirr => 'Telebirr',
      _ => 'Manual payment',
    };

    return KitScaffold(
      appBar: KitAppBar(title: screenTitle),
      child: groupAsync.when(
        loading: () => const LoadingView(message: 'Loading group...'),
        error: (error, _) => ErrorView(
          message: mapFriendlyError(error),
          onRetry: () => ref
              .read(groupDetailControllerProvider)
              .refreshGroup(widget.groupId),
        ),
        data: (groupData) {
          return cycleAsync.when(
            loading: () => const LoadingView(message: 'Loading cycle...'),
            error: (error, _) => ErrorView(
              message: mapFriendlyError(error),
              onRetry: () => ref.invalidate(
                cycleDetailProvider((
                  groupId: widget.groupId,
                  cycleId: widget.cycleId,
                )),
              ),
            ),
            data: (cycleData) {
              if (selectedMethod == GroupPaymentMethodModel.telebirr) {
                return const _TelebirrComingSoonView();
              }

              return _ManualSubmitForm(
                args: args,
                group: groupData,
                cycle: cycleData,
                amountController: _amountController,
                paymentRefController: _paymentRefController,
                noteController: _noteController,
                submitState: submitState,
                formError: _formError,
                onFormErrorChanged: (value) {
                  setState(() => _formError = value);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _TelebirrComingSoonView extends StatelessWidget {
  const _TelebirrComingSoonView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: KitEmptyState(
          icon: Icons.phone_android,
          title: 'Telebirr coming soon',
          message: 'Telebirr payment is not ready yet.',
        ),
      ),
    );
  }
}

class _ManualSubmitForm extends ConsumerWidget {
  const _ManualSubmitForm({
    required this.args,
    required this.group,
    required this.cycle,
    required this.amountController,
    required this.paymentRefController,
    required this.noteController,
    required this.submitState,
    required this.formError,
    required this.onFormErrorChanged,
  });

  final CycleContributionsArgs args;
  final GroupModel group;
  final CycleModel cycle;
  final TextEditingController amountController;
  final TextEditingController paymentRefController;
  final TextEditingController noteController;
  final SubmitContributionState submitState;
  final String? formError;
  final ValueChanged<String?> onFormErrorChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      submitContributionControllerProvider(args).notifier,
    );

    final isCycleOpen = cycle.status == CycleStatusModel.open;

    Future<void> submit() async {
      final amount = int.tryParse(amountController.text.trim());
      if (amount == null || amount <= 0) {
        onFormErrorChanged('Amount must be greater than 0.');
        return;
      }

      onFormErrorChanged(null);

      final success = await controller.submit(
        method: GroupPaymentMethodModel.cashAck,
        amount: amount,
        paymentRef: paymentRefController.text,
        note: noteController.text,
        preferSocketSync: true,
      );

      if (!context.mounted || !success) {
        return;
      }

      AppSnackbars.success(context, 'Contribution submitted successfully');
      Navigator.of(context).pop();
    }

    return ListView(
      children: [
        if (!isCycleOpen) ...[
          const KitEmptyState(
            icon: Icons.lock_clock_outlined,
            title: 'Cycle is closed',
            message: 'You cannot submit new contributions for a closed cycle.',
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        KitCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Attachment',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  KitSecondaryButton(
                    onPressed: submitState.isBusy || !isCycleOpen
                        ? null
                        : controller.pickFromCamera,
                    icon: Icons.photo_camera_outlined,
                    label: 'Camera',
                    expand: false,
                  ),
                  KitSecondaryButton(
                    onPressed: submitState.isBusy || !isCycleOpen
                        ? null
                        : controller.pickFromGallery,
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    expand: false,
                  ),
                ],
              ),
              if (submitState.image != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  submitState.image!.fileName,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Image.memory(
                    submitState.image!.bytes,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        KitCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Details', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              KitNumberField(
                controller: amountController,
                label: 'Amount',
                placeholder: group.contributionAmount.toString(),
                onChanged: (_) => onFormErrorChanged(null),
              ),
              const SizedBox(height: AppSpacing.md),
              KitTextField(
                controller: paymentRefController,
                label: 'Reference (optional)',
                placeholder: 'Receipt note',
              ),
              const SizedBox(height: AppSpacing.md),
              KitTextArea(
                controller: noteController,
                label: 'Note (optional)',
                placeholder: 'Add a note',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        KitCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Submit', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              if (submitState.isBusy) ...[
                LinearProgressIndicator(value: submitState.uploadProgress),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _progressLabel(submitState.step),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              KitPrimaryButton(
                onPressed: submitState.isBusy || !isCycleOpen ? null : submit,
                label: submitState.isBusy ? 'Submitting...' : 'Submit payment',
                isLoading: submitState.isBusy,
              ),
            ],
          ),
        ),
        if (formError != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            formError!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
        if (submitState.errorMessage != null &&
            submitState.errorMessage!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            submitState.errorMessage!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

GroupPaymentMethodModel? _paymentMethodFromKey(String? value) {
  return switch (value?.toLowerCase()) {
    'manual' => GroupPaymentMethodModel.cashAck,
    'telebirr' => GroupPaymentMethodModel.telebirr,
    _ => null,
  };
}

String _progressLabel(SubmitContributionStep step) {
  return switch (step) {
    SubmitContributionStep.idle => 'Ready',
    SubmitContributionStep.pickingImage => 'Picking receipt...',
    SubmitContributionStep.requestingUpload => 'Preparing upload...',
    SubmitContributionStep.uploading => 'Uploading receipt...',
    SubmitContributionStep.submitting => 'Submitting contribution...',
    SubmitContributionStep.success => 'Done',
    SubmitContributionStep.error => 'Failed',
  };
}
