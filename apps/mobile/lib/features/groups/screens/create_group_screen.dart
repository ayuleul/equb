import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/bootstrap.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/create_group_request.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/ui/ui.dart';
import '../../../shared/utils/api_error_mapper.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../groups_list_controller.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _currencyController;

  bool _isSubmitting = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _currencyController = TextEditingController(text: 'ETB');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final currency = _currencyController.text.trim().toUpperCase();

    if (name.isEmpty) {
      setState(() => _formError = 'Group name is required.');
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
        CreateGroupRequest(name: name, currency: currency),
      );

      if (!mounted) {
        return;
      }

      await ref.read(groupsListProvider.notifier).refresh();
      if (!mounted) {
        return;
      }
      AppSnackbars.success(
        context,
        'Group created. Complete setup before inviting members or starting cycles.',
      );
      if (context.canPop()) {
        context.pop();
      }
      context.push(AppRoutePaths.groupSetup(group.id));
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
    return KitScaffold(
      appBar: const KitAppBar(
        title: 'Create group',
        subtitle: 'Create a group, then configure its rules',
      ),
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
                  controller: _currencyController,
                  label: 'Currency',
                  hint: 'ETB',
                  onChanged: (_) => setState(() => _formError = null),
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
