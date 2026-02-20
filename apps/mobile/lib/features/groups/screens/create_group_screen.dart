import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/bootstrap.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/create_group_request.dart';
import '../../../data/models/group_model.dart';
import '../../../shared/utils/api_error_mapper.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
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

    if (picked != null) {
      setState(() {
        _startDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  Future<void> _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    final name = _nameController.text.trim();
    final amountRaw = _amountController.text.trim();
    final currencyRaw = _currencyController.text.trim().toUpperCase();

    if (name.isEmpty) {
      setState(() {
        _formError = 'Group name is required.';
      });
      return;
    }

    final amount = int.tryParse(amountRaw);
    if (amount == null || amount <= 0) {
      setState(() {
        _formError = 'Contribution amount must be greater than 0.';
      });
      return;
    }

    if (currencyRaw.isEmpty || currencyRaw.length != 3) {
      setState(() {
        _formError = 'Currency must be a 3-letter code (e.g. ETB).';
      });
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
          currency: currencyRaw,
        ),
      );

      if (!mounted) {
        return;
      }

      messenger.showSnackBar(
        const SnackBar(content: Text('Group created successfully.')),
      );

      await ref.read(groupsListProvider.notifier).refresh();
      if (mounted) {
        context.go(AppRoutePaths.groupDetail(group.id));
      }
    } catch (error) {
      setState(() {
        _formError = mapApiErrorToMessage(error);
      });
      messenger.showSnackBar(SnackBar(content: Text(_formError!)));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Group')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            AppTextField(
              controller: _nameController,
              label: 'Group name',
              hint: 'Family Equb',
              onChanged: (_) {
                if (_formError != null) {
                  setState(() {
                    _formError = null;
                  });
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _amountController,
              label: 'Contribution amount',
              hint: '500',
              keyboardType: TextInputType.number,
              onChanged: (_) {
                if (_formError != null) {
                  setState(() {
                    _formError = null;
                  });
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _currencyController,
              label: 'Currency',
              hint: 'ETB',
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
                if (value != null) {
                  setState(() {
                    _frequency = value;
                  });
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: _pickStartDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                'Start date: ${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}',
              ),
            ),
            if (_formError != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _formError!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Create Group',
              isLoading: _isSubmitting,
              onPressed: _isSubmitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
