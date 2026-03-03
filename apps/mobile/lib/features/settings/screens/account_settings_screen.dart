import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/bootstrap.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/utils/api_error_mapper.dart';
import '../../auth/auth_controller.dart';

class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() =>
      _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  static final RegExp _namePattern = RegExp(
    r'^[A-Za-z\u00C0-\u024F\u1200-\u139F\u2D80-\u2DDF\uAB00-\uAB2F ]+$',
  );

  late final TextEditingController _firstNameController;
  late final TextEditingController _middleNameController;
  late final TextEditingController _lastNameController;
  String? _firstNameError;
  String? _middleNameError;
  String? _lastNameError;
  bool _isSaving = false;
  bool _isPickingPhoto = false;
  Uint8List? _profilePhotoBytes;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _middleNameController = TextEditingController(text: user?.middleName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return KitScaffold(
      appBar: const KitAppBar(title: 'Account', showAvatar: false),
      child: ListView(
        children: [
          KitCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Profile', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.colorScheme.primary.withValues(
                        alpha: 0.12,
                      ),
                      backgroundImage: _profilePhotoBytes != null
                          ? MemoryImage(_profilePhotoBytes!)
                          : null,
                      child: _profilePhotoBytes == null
                          ? Icon(
                              Icons.person_rounded,
                              color: theme.colorScheme.primary,
                              size: 30,
                            )
                          : null,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile photo (optional)',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          TextButton.icon(
                            onPressed: _isPickingPhoto ? null : _pickPhoto,
                            icon: const Icon(Icons.photo_library_outlined),
                            label: Text(
                              _isPickingPhoto
                                  ? 'Selecting...'
                                  : (_profilePhotoBytes == null
                                        ? 'Choose photo'
                                        : 'Change photo'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                KitTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  placeholder: 'Enter your first name',
                  errorText: _firstNameError,
                  onChanged: (_) => setState(() => _firstNameError = null),
                ),
                const SizedBox(height: AppSpacing.sm),
                KitTextField(
                  controller: _middleNameController,
                  label: "Father's Name",
                  placeholder: "Enter your father's name",
                  errorText: _middleNameError,
                  onChanged: (_) => setState(() => _middleNameError = null),
                ),
                const SizedBox(height: AppSpacing.sm),
                KitTextField(
                  controller: _lastNameController,
                  label: "Grandfather's Name",
                  placeholder: "Enter your grandfather's name",
                  errorText: _lastNameError,
                  onChanged: (_) => setState(() => _lastNameError = null),
                ),
                const SizedBox(height: AppSpacing.sm),
                _ReadOnlyField(
                  label: 'Phone number',
                  value: user?.phone ?? '-',
                ),
                const SizedBox(height: AppSpacing.md),
                KitPrimaryButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  isLoading: _isSaving,
                  label: _isSaving ? 'Saving...' : 'Save profile',
                  icon: Icons.save_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPhoto() async {
    setState(() => _isPickingPhoto = true);
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 88,
      );
      if (file == null || !mounted) {
        return;
      }
      final bytes = await file.readAsBytes();
      if (!mounted) {
        return;
      }
      setState(() => _profilePhotoBytes = bytes);
    } catch (_) {
      _showSnack('Unable to pick image from gallery.');
    } finally {
      if (mounted) {
        setState(() => _isPickingPhoto = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    final firstName = _normalize(_firstNameController.text);
    final middleName = _normalize(_middleNameController.text);
    final lastName = _normalize(_lastNameController.text);

    final firstError = _validateName(firstName, label: 'First Name');
    final middleError = _validateName(middleName, label: "Father's Name");
    final lastError = _validateName(lastName, label: "Grandfather's Name");
    if (firstError != null || middleError != null || lastError != null) {
      setState(() {
        _firstNameError = firstError;
        _middleNameError = middleError;
        _lastNameError = lastError;
      });
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
      _showSnack('Profile updated.');
    } catch (error) {
      _showSnack(mapApiErrorToMessage(error));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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

  String _normalize(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  void _showSnack(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdRounded,
            border: Border.all(color: theme.colorScheme.outlineVariant),
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            child: Text(value, style: theme.textTheme.bodyLarge),
          ),
        ),
      ],
    );
  }
}
