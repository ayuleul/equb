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

  late final TextEditingController _firstNameController;
  late final TextEditingController _middleNameController;
  late final TextEditingController _lastNameController;
  late final FocusNode _firstNameFocusNode;
  late final FocusNode _middleNameFocusNode;
  late final FocusNode _lastNameFocusNode;
  String? _firstNameError;
  String? _middleNameError;
  String? _lastNameError;
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
    final firstName = _normalizeName(_firstNameController.text);
    final middleName = _normalizeName(_middleNameController.text);
    final lastName = _normalizeName(_lastNameController.text);

    final firstError = _validateName(firstName, label: 'First Name');
    final middleError = _validateName(middleName, label: "Father's Name");
    final lastError = _validateOptionalName(
      lastName,
      label: "Grandfather's Name",
    );
    if (firstError != null || middleError != null || lastError != null) {
      setState(() {
        _firstNameError = firstError;
        _middleNameError = middleError;
        _lastNameError = lastError;
      });
      _showSnackBar('Please fix the highlighted fields.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final profileRepository = ref.read(profileRepositoryProvider);
      final user = await profileRepository.updateProfile(
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
      );

      await ref
          .read(authControllerProvider.notifier)
          .setAuthenticatedUser(user);
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
          title: 'Complete profile',
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSpacing.xs),
                          KitTextField(
                            controller: _firstNameController,
                            focusNode: _firstNameFocusNode,
                            label: 'First Name',
                            placeholder: 'First name',
                            errorText: _firstNameError,
                            onChanged: (_) {
                              if (_firstNameError != null) {
                                setState(() => _firstNameError = null);
                              }
                            },
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          KitTextField(
                            controller: _middleNameController,
                            focusNode: _middleNameFocusNode,
                            label: "Father's Name",
                            placeholder: "Father's name",
                            errorText: _middleNameError,
                            onChanged: (_) {
                              if (_middleNameError != null) {
                                setState(() => _middleNameError = null);
                              }
                            },
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          KitTextField(
                            controller: _lastNameController,
                            focusNode: _lastNameFocusNode,
                            label: "Grandfather's Name (Optional)",
                            placeholder: "Grandfather's name",
                            errorText: _lastNameError,
                            onChanged: (_) {
                              if (_lastNameError != null) {
                                setState(() => _lastNameError = null);
                              }
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          KitPrimaryButton(
                            label: _isSaving ? 'Saving...' : 'Save',
                            onPressed: _isSaving ? null : _saveProfile,
                            isLoading: _isSaving,
                          ),
                        ],
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

  String? _validateName(String value, {required String label}) {
    if (value.isEmpty) {
      return '$label is required.';
    }
    if (value.length < 2) {
      return '$label must be at least 2 characters.';
    }
    if (value.length > 50) {
      return '$label must be at most 50 characters.';
    }
    if (!_namePattern.hasMatch(value)) {
      return '$label can contain letters and spaces only.';
    }
    return null;
  }

  String? _validateOptionalName(String value, {required String label}) {
    if (value.isEmpty) {
      return null;
    }

    return _validateName(value, label: label);
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
