import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/bootstrap.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/ui/ui.dart';
import '../../../shared/utils/api_error_mapper.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../groups_list_controller.dart';

class JoinGroupScreen extends ConsumerStatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  ConsumerState<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends ConsumerState<JoinGroupScreen> {
  late final TextEditingController _codeController;
  bool _isSubmitting = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _formError = 'Invite code is required.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _formError = null;
    });

    try {
      final repository = ref.read(groupsRepositoryProvider);
      final groupId = await repository.joinByCode(code);
      if (!mounted) {
        return;
      }

      await ref.read(groupsListProvider.notifier).refresh();
      if (!mounted) {
        return;
      }
      AppSnackbars.success(context, 'Joined group successfully');
      if (context.canPop()) {
        context.pop();
      }
      context.push(AppRoutePaths.groupDetail(groupId));
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
        title: 'Join group',
        subtitle: 'Use an invite code from your group admin',
      ),
      child: ListView(
        children: [
          EqubCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: _codeController,
                  label: 'Invite code',
                  hint: 'A1B2C3D4',
                  onChanged: (_) => setState(() => _formError = null),
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
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: _isSubmitting ? null : _submit,
            child: Text(_isSubmitting ? 'Joining...' : 'Join group'),
          ),
        ],
      ),
    );
  }
}
