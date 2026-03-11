import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_spacing.dart';
import '../../shared/kit/kit.dart';
import '../auth/auth_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return KitScaffold(
      child: ListView(
        children: [
          KitSectionHeader(
            title: 'Settings',
            subtitle: 'Manage your account and app preferences.',
          ),
          KitCard(
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'Equb member',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        user?.phone ?? 'No phone number',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          KitCard(
            child: Column(
              children: [
                _SettingsNavRow(
                  title: 'Account',
                  icon: Icons.badge_outlined,
                  onTap: () => context.push(AppRoutePaths.settingsAccount),
                ),
                _SettingsNavRow(
                  title: 'Security',
                  icon: Icons.lock_outline_rounded,
                  onTap: () => context.push(AppRoutePaths.settingsSecurity),
                ),
                _SettingsNavRow(
                  title: 'Notifications',
                  icon: Icons.notifications_outlined,
                  onTap: () =>
                      context.push(AppRoutePaths.settingsNotifications),
                ),
                _SettingsNavRow(
                  title: 'Payments',
                  icon: Icons.account_balance_wallet_outlined,
                  onTap: () => context.push(AppRoutePaths.settingsPayments),
                ),
                _SettingsNavRow(
                  title: 'Equb Preferences',
                  icon: Icons.tune_rounded,
                  onTap: () =>
                      context.push(AppRoutePaths.settingsEqubPreferences),
                  showDivider: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          KitCard(
            child: Column(
              children: [
                _SettingsNavRow(
                  title: 'Data & Privacy',
                  icon: Icons.privacy_tip_outlined,
                  onTap: () => context.push(AppRoutePaths.settingsDataPrivacy),
                ),
                _SettingsNavRow(
                  title: 'Support',
                  icon: Icons.support_agent_outlined,
                  onTap: () => context.push(AppRoutePaths.settingsSupport),
                ),
                _SettingsNavRow(
                  title: 'About',
                  icon: Icons.info_outline_rounded,
                  onTap: () => context.push(AppRoutePaths.settingsAbout),
                  showDivider: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsNavRow extends StatelessWidget {
  const _SettingsNavRow({
    required this.title,
    required this.icon,
    required this.onTap,
    this.showDivider = true,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final tile = Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs, top: AppSpacing.xs),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
    if (!showDivider) {
      return tile;
    }
    return Column(children: [tile, const Divider(height: 1)]);
  }
}
