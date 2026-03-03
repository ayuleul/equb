import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../shared/kit/kit.dart';
import '../../auth/auth_controller.dart';
import '../app_lock_controller.dart';

class SecuritySettingsScreen extends ConsumerWidget {
  const SecuritySettingsScreen({super.key});

  static const List<_LockTimeoutOption> _lockTimeoutOptions = [
    _LockTimeoutOption(seconds: 0, label: 'Immediately'),
    _LockTimeoutOption(seconds: 30, label: '30 seconds'),
    _LockTimeoutOption(seconds: 60, label: '1 minute'),
    _LockTimeoutOption(seconds: 300, label: '5 minutes'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final lockState = ref.watch(appLockControllerProvider);
    final theme = Theme.of(context);

    return KitScaffold(
      appBar: const KitAppBar(title: 'Security', showAvatar: false),
      child: ListView(
        children: [
          KitCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile.adaptive(
                  value: lockState.biometricEnabled,
                  onChanged: lockState.biometricAvailable
                      ? (value) => ref
                            .read(appLockControllerProvider.notifier)
                            .setBiometricEnabled(value)
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  title: const Text('Biometric lock'),
                  subtitle: Text(
                    lockState.biometricAvailable
                        ? 'Require biometrics to unlock the app.'
                        : 'Biometric not available on this device.',
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                KitDropdownField<int>(
                  label: 'Auto-lock timeout',
                  value: lockState.lockTimeoutSeconds,
                  items: _lockTimeoutOptions
                      .map(
                        (option) => DropdownMenuItem<int>(
                          value: option.seconds,
                          child: Text(option.label),
                        ),
                      )
                      .toList(),
                  onChanged: lockState.biometricEnabled
                      ? (value) {
                          if (value == null) {
                            return;
                          }
                          ref
                              .read(appLockControllerProvider.notifier)
                              .setLockTimeoutSeconds(value);
                        }
                      : null,
                  supportText: lockState.biometricEnabled
                      ? null
                      : 'Enable biometric lock to configure timeout.',
                ),
                const SizedBox(height: AppSpacing.md),
                KitSecondaryButton(
                  onPressed: authState.isLoggingOut
                      ? null
                      : () async {
                          final shouldLogout = await KitDialog.confirm(
                            context: context,
                            title: 'Logout?',
                            message:
                                'You will need OTP verification again next time you sign in.',
                            confirmLabel: 'Logout',
                            isDestructive: true,
                          );
                          if (shouldLogout != true) {
                            return;
                          }
                          if (!context.mounted) {
                            return;
                          }
                          await ref
                              .read(authControllerProvider.notifier)
                              .logout();
                        },
                  icon: Icons.logout_rounded,
                  label: authState.isLoggingOut ? 'Logging out...' : 'Logout',
                  isLoading: authState.isLoggingOut,
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withValues(
                      alpha: 0.42,
                    ),
                    borderRadius: AppRadius.mdRounded,
                    border: Border.all(
                      color: theme.colorScheme.error.withValues(alpha: 0.4),
                    ),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Danger zone',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Delete your account and associated app access.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      KitSecondaryButton(
                        onPressed: () => _confirmDeleteAccount(context),
                        icon: Icons.delete_forever_outlined,
                        label: 'Delete account',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final shouldDelete = await KitDialog.confirm(
      context: context,
      title: 'Delete account?',
      message:
          'This will permanently remove your account once backend delete is enabled.',
      confirmLabel: 'Delete account',
      isDestructive: true,
    );
    if (shouldDelete != true || !context.mounted) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          'Delete account request is not yet connected to backend.',
        ),
      ),
    );
  }
}

class _LockTimeoutOption {
  const _LockTimeoutOption({required this.seconds, required this.label});

  final int seconds;
  final String label;
}
