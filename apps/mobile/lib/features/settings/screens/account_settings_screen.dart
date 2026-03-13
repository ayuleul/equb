import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/kit/kit.dart';
import '../../auth/auth_controller.dart';
import '../widgets/settings_list.dart';

class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return KitScaffold(
      appBar: const KitAppBar(title: 'Account', showAvatar: false),
      child: ListView(
        children: [
          SettingsListCard(
            children: [
              SettingsNavRow(
                title: 'My profile',
                icon: Icons.badge_outlined,
                onTap: () => context.push(AppRoutePaths.settingsAccountProfile),
              ),
              SettingsNavRow(
                title: 'Trust identity',
                icon: Icons.verified_user_outlined,
                onTap: () => context.push(AppRoutePaths.settingsAccountTrust),
              ),
              SettingsNavRow(
                title: 'Recent activity',
                icon: Icons.timeline_rounded,
                onTap: () =>
                    context.push(AppRoutePaths.settingsAccountActivity),
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SettingsListCard(
            children: [
              SettingsActionRow(
                title: 'Logout',
                icon: Icons.logout_rounded,
                onTap: () => _confirmLogout(context, ref),
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          KitCard(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.errorContainer.withValues(alpha: 0.42),
                borderRadius: AppRadius.mdRounded,
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.error.withValues(alpha: 0.4),
                ),
              ),
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Danger zone',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Delete your account and associated app access.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SettingsActionRow(
                    title: 'Delete account',
                    icon: Icons.delete_forever_outlined,
                    isDestructive: true,
                    showDivider: false,
                    onTap: () => _confirmDeleteAccount(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await KitDialog.confirm(
      context: context,
      title: 'Logout?',
      message: 'You will need OTP verification again next time you sign in.',
      confirmLabel: 'Logout',
      isDestructive: true,
    );
    if (shouldLogout != true || !context.mounted) {
      return;
    }
    await ref.read(authControllerProvider.notifier).logout();
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
