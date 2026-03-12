import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/bootstrap.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/reputation_model.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/utils/api_error_mapper.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/utils/phone_numbers.dart';
import '../../../shared/utils/reputation_presenter.dart';
import '../../../shared/widgets/reputation_badge.dart';
import '../../auth/auth_controller.dart';
import '../../profile/profile_reputation_provider.dart';

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
    final reputationAsync = ref.watch(currentUserReputationProvider);
    final reputationHistoryAsync = ref.watch(
      currentUserReputationHistoryProvider,
    );

    return KitScaffold(
      appBar: const KitAppBar(title: 'Account', showAvatar: false),
      child: ListView(
        children: [
          reputationAsync.when(
            loading: () => const KitCard(
              child: SizedBox(
                height: 180,
                child: KitSkeletonList(itemCount: 5),
              ),
            ),
            error: (error, _) => KitCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Trust identity', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(mapApiErrorToMessage(error)),
                ],
              ),
            ),
            data: (profile) => profile == null
                ? const SizedBox.shrink()
                : _TrustIdentityCard(
                    userName: user?.displayName ?? 'Equb member',
                    profile: profile,
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          reputationHistoryAsync.when(
            loading: () => const KitCard(
              child: SizedBox(
                height: 160,
                child: KitSkeletonList(itemCount: 4),
              ),
            ),
            error: (error, _) => KitCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reputation activity',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(mapApiErrorToMessage(error)),
                ],
              ),
            ),
            data: (history) => _ReputationTimelineCard(history: history),
          ),
          const SizedBox(height: AppSpacing.md),
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
                  label: "Grandfather's Name (Optional)",
                  placeholder: "Enter your grandfather's name.",
                  errorText: _lastNameError,
                  onChanged: (_) => setState(() => _lastNameError = null),
                ),
                const SizedBox(height: AppSpacing.sm),
                KitPhoneNumberField(
                  value: phoneNumberValueFromStoredPhone(user?.phone),
                  enabled: false,
                  onChanged: (_) {},
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

  String? _validateOptionalName(String value, {required String label}) {
    if (value.isEmpty) {
      return null;
    }

    return _validateName(value, label: label);
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

class _TrustIdentityCard extends StatelessWidget {
  const _TrustIdentityCard({required this.userName, required this.profile});

  final String userName;
  final ReputationProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = buildTrustProgress(profile.trustScore);
    final onTimeRate = formatOnTimeRate(profile.onTimePaymentRate);

    return KitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Trust identity', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      userName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              ReputationBadge(trustLevel: profile.trustLevel),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _TrustMetricTile(
                label: 'Trust score',
                value: '${profile.trustScore}',
              ),
              _TrustMetricTile(label: 'Trust level', value: profile.trustLevel),
              _TrustMetricTile(
                label: 'Completed Equbs',
                value: '${profile.equbsCompleted}',
              ),
              _TrustMetricTile(
                label: 'Equbs joined',
                value: '${profile.equbsJoined}',
              ),
              _TrustMetricTile(
                label: 'Hosted Equbs',
                value: '${profile.equbsHosted}',
              ),
              _TrustMetricTile(label: 'On-time payments', value: onTimeRate),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            progress.isMaxLevel
                ? 'Trust progress'
                : 'Trust progress • ${progress.currentLevel} to ${progress.nextLevel}',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          LinearProgressIndicator(value: progress.progress),
          const SizedBox(height: AppSpacing.xs),
          Text(
            progress.isMaxLevel
                ? 'You are already at the top trust level.'
                : 'Score: ${progress.currentScore} / ${progress.targetScore}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          if (profile.badges.isNotEmpty) ...[
            Text('Badges', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final badge in profile.badges)
                  KitBadge(label: badge.label, tone: KitBadgeTone.info),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          KitBanner(
            title: 'Hosting access',
            message: hostRestrictionMessage(profile),
            tone: profile.eligibility.hostTier == null
                ? KitBadgeTone.warning
                : KitBadgeTone.info,
            icon: Icons.shield_outlined,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                builder: (context) => const _HowTrustWorksSheet(),
              ),
              child: const Text('How trust score works'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustMetricTile extends StatelessWidget {
  const _TrustMetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 152,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: AppRadius.mdRounded,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        color: Theme.of(context).colorScheme.surfaceContainerLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ReputationTimelineCard extends StatelessWidget {
  const _ReputationTimelineCard({required this.history});

  final ReputationHistoryPageModel? history;

  @override
  Widget build(BuildContext context) {
    final items = history?.items ?? const <ReputationHistoryEntryModel>[];
    return KitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reputation activity',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (items.isEmpty)
            const Text('Your trust activity will appear here as you use Equb.')
          else
            for (var i = 0; i < items.length; i++) ...[
              _TimelineRow(entry: items[i]),
              if (i != items.length - 1)
                Divider(
                  height: AppSpacing.lg,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
            ],
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.entry});

  final ReputationHistoryEntryModel entry;

  @override
  Widget build(BuildContext context) {
    final isPositive = entry.scoreDelta >= 0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color:
                (isPositive
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error)
                    .withValues(alpha: 0.12),
            borderRadius: AppRadius.mdRounded,
          ),
          child: Icon(
            isPositive
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            size: 18,
            color: isPositive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${isPositive ? '+' : ''}${entry.scoreDelta} ${reputationHistoryLabel(entry.eventType)}',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                formatRelativeTime(entry.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HowTrustWorksSheet extends StatelessWidget {
  const _HowTrustWorksSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How trust score works',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Your trust score reflects real Equb behavior over time. Completing Equbs, paying on time, and running healthy groups help. Late payments, removals, disputes, and long inactivity can reduce it. Good behavior can improve your score again.',
            ),
          ],
        ),
      ),
    );
  }
}
