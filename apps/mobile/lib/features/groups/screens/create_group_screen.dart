import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/bootstrap.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/create_group_request.dart';
import '../../../data/models/group_model.dart';
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
  late final TextEditingController _descriptionController;
  late final TextEditingController _currencyController;
  var _visibility = GroupVisibilityModel.private;

  bool _isSubmitting = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _currencyController = TextEditingController(text: 'ETB');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
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
        CreateGroupRequest(
          name: name,
          description: description.isEmpty ? null : description,
          currency: currency,
          visibility: _visibility,
        ),
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
        subtitle: 'Start with identity and access',
      ),
      child: ListView(
        children: [
          KitBanner(
            title: 'What happens next',
            message:
                'Create the group first, then finish timing, payout, and collection rules in one setup screen.',
            tone: KitBadgeTone.info,
            icon: Icons.route_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          EqubCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Identity',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Give the Equb a name, short context, and default currency.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _nameController,
                  label: 'Group name',
                  hint: 'Family Equb',
                  onChanged: (_) => setState(() => _formError = null),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'What is this Equb for?',
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
          const SizedBox(height: AppSpacing.md),
          EqubCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Access',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Decide whether people join by invite only or can request access publicly.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                KitDropdownField<GroupVisibilityModel>(
                  value: _visibility,
                  label: 'Visibility',
                  items: const [
                    DropdownMenuItem(
                      value: GroupVisibilityModel.private,
                      child: Text('Private'),
                    ),
                    DropdownMenuItem(
                      value: GroupVisibilityModel.public,
                      child: Text('Public'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _visibility = value;
                      _formError = null;
                    });
                  },
                  supportText: _visibility == GroupVisibilityModel.public
                      ? 'Visible to others. People request to join.'
                      : 'Invite code only.',
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
