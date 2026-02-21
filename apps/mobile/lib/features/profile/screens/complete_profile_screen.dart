import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/bootstrap.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../features/auth/auth_controller.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/utils/api_error_mapper.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  static final RegExp _namePattern = RegExp(
    r'^[A-Za-z\u00C0-\u024F\u1200-\u139F\u2D80-\u2DDF\uAB00-\uAB2F ]+$',
  );

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _middleNameController;
  late final TextEditingController _lastNameController;
  late final FocusNode _firstNameFocusNode;
  late final FocusNode _middleNameFocusNode;
  late final FocusNode _lastNameFocusNode;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _middleNameController = TextEditingController(text: user?.middleName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _firstNameFocusNode = FocusNode();
    _middleNameFocusNode = FocusNode();
    _lastNameFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _firstNameFocusNode.dispose();
    _middleNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      _showSnackBar('Please fix the highlighted fields.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final profileRepository = ref.read(profileRepositoryProvider);
      final user = await profileRepository.updateProfile(
        firstName: _firstNameController.text,
        middleName: _middleNameController.text,
        lastName: _lastNameController.text,
      );

      await ref.read(authControllerProvider.notifier).setAuthenticatedUser(user);
      if (!mounted) {
        return;
      }
      context.go(AppRoutePaths.home);
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showSnackBar(mapApiErrorToMessage(error));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: KitScaffold(
        appBar: const KitAppBar(
          title: 'Complete your profile',
          showBackButton: false,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: KitCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your legal Equb profile requires three names.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextFormField(
                              controller: _firstNameController,
                              focusNode: _firstNameFocusNode,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'First Name',
                                hintText: 'Enter your first name',
                              ),
                              onFieldSubmitted: (_) =>
                                  _middleNameFocusNode.requestFocus(),
                              validator: (value) =>
                                  _validateName(value, label: 'First Name'),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            TextFormField(
                              controller: _middleNameController,
                              focusNode: _middleNameFocusNode,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: "Father's Name",
                                hintText: "Enter your father's name",
                              ),
                              onFieldSubmitted: (_) =>
                                  _lastNameFocusNode.requestFocus(),
                              validator: (value) => _validateName(
                                value,
                                label: "Father's Name",
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            TextFormField(
                              controller: _lastNameController,
                              focusNode: _lastNameFocusNode,
                              textInputAction: TextInputAction.done,
                              decoration: const InputDecoration(
                                labelText: "Grandfather's Name",
                                hintText: "Enter your grandfather's name",
                              ),
                              onFieldSubmitted: (_) => _saveProfile(),
                              validator: (value) => _validateName(
                                value,
                                label: "Grandfather's Name",
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            KitPrimaryButton(
                              label: _isSaving ? 'Saving...' : 'Save Profile',
                              onPressed: _isSaving ? null : _saveProfile,
                              isLoading: _isSaving,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String? _validateName(String? value, {required String label}) {
    final normalized = _normalizeName(value ?? '');
    if (normalized.isEmpty) {
      return '$label is required.';
    }
    if (normalized.length < 2) {
      return '$label must be at least 2 characters.';
    }
    if (normalized.length > 50) {
      return '$label must be at most 50 characters.';
    }
    if (!_namePattern.hasMatch(normalized)) {
      return '$label can contain letters and spaces only.';
    }
    return null;
  }

  String _normalizeName(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  void _showSnackBar(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}
