import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/bootstrap.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/create_group_request.dart';
import '../../../data/models/group_model.dart';
import '../../../shared/ui/ui.dart';
import '../../../shared/utils/api_error_mapper.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../groups_list_controller.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _currencyController;

  GroupFrequencyModel _frequency = GroupFrequencyModel.monthly;
  DateTime _startDate = DateTime.now();
  bool _isSubmitting = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _amountController = TextEditingController();
    _currencyController = TextEditingController(text: 'ETB');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 3650)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _startDate = DateTime(picked.year, picked.month, picked.day);
    });
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final amount = int.tryParse(_amountController.text.trim());
    final currency = _currencyController.text.trim().toUpperCase();

    if (name.isEmpty) {
      setState(() => _formError = 'Group name is required.');
      return;
    }
    if (amount == null || amount <= 0) {
      setState(
        () => _formError = 'Contribution amount must be greater than 0.',
      );
      return;
    }
    if (currency.length != 3) {
      setState(() => _formError = 'Currency must be a 3-letter code.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _formError = null;
    });

    try {
      final repository = ref.read(groupsRepositoryProvider);
      final group = await repository.createGroup(
        CreateGroupRequest(
          name: name,
          contributionAmount: amount,
          frequency: _frequency,
          startDate: _startDate,
          currency: currency,
        ),
      );

      if (!mounted) {
        return;
      }

      await ref.read(groupsListProvider.notifier).refresh();
      if (!mounted) {
        return;
      }
      AppSnackbars.success(context, 'Group created');
      if (context.canPop()) {
        context.pop();
      }
      context.push(AppRoutePaths.groupDetail(group.id));
    } catch (error) {
      if (!mounted) {
        return;
      }
      final message = mapApiErrorToMessage(error);
      setState(() => _formError = message);
      AppSnackbars.error(context, message);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Create group',
      subtitle: 'Set up a new Equb group',
      child: ListView(
        children: [
          EqubCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: _nameController,
                  label: 'Group name',
                  hint: 'Family Equb',
                  onChanged: (_) => setState(() => _formError = null),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _amountController,
                  label: 'Contribution amount',
                  hint: '500',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() => _formError = null),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _currencyController,
                  label: 'Currency',
                  hint: 'ETB',
                  onChanged: (_) => setState(() => _formError = null),
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<GroupFrequencyModel>(
                  initialValue: _frequency,
                  decoration: const InputDecoration(labelText: 'Frequency'),
                  items: const [
                    DropdownMenuItem(
                      value: GroupFrequencyModel.weekly,
                      child: Text('WEEKLY'),
                    ),
                    DropdownMenuItem(
                      value: GroupFrequencyModel.monthly,
                      child: Text('MONTHLY'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() => _frequency = value);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: _pickStartDate,
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text('Start date: ${formatDate(_startDate)}'),
                ),
              ],
            ),
          ),
          if (_formError != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _formError!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: _isSubmitting ? null : _submit,
            child: Text(_isSubmitting ? 'Creating...' : 'Create group'),
          ),
        ],
      ),
    );
  }
}
