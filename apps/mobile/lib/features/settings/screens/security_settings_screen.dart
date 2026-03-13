import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../shared/kit/kit.dart';
import '../app_lock_controller.dart';
import '../widgets/settings_list.dart';

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
    final lockState = ref.watch(appLockControllerProvider);

    return KitScaffold(
      appBar: const KitAppBar(title: 'Security', showAvatar: false),
      child: ListView(
        children: [
          SettingsListCard(
            children: [
              SettingsSwitchRow(
                title: 'Biometric lock',
                value: lockState.biometricEnabled,
                onChanged: lockState.biometricAvailable
                    ? (value) => ref
                          .read(appLockControllerProvider.notifier)
                          .setBiometricEnabled(value)
                    : null,
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          KitCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LockTimeoutOption {
  const _LockTimeoutOption({required this.seconds, required this.label});

  final int seconds;
  final String label;
}
