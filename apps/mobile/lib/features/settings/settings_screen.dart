import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_spacing.dart';
import '../../shared/kit/kit.dart';
import '../../shared/widgets/reputation_badge.dart';
import '../auth/auth_controller.dart';
import '../profile/profile_reputation_provider.dart';
import 'widgets/settings_list.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final reputationAsync = ref.watch(currentUserReputationProvider);
    final theme = Theme.of(context);

    return KitScaffold(
      child: ListView(
        children: [
          KitCard(
            onTap: () => context.push(AppRoutePaths.settingsAccountProfile),
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
                reputationAsync.maybeWhen(
                  data: (profile) => profile == null || !profile.hasEarnedLevel
                      ? const Icon(Icons.chevron_right_rounded)
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ReputationBadge(
                              label: profile.displayLabel!,
                              icon: profile.icon,
                              level: profile.level,
                              compact: true,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            const Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                  orElse: () => const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const KitSectionHeader(title: 'Account'),
          const SizedBox(height: AppSpacing.xs),
          SettingsListCard(
            children: [
              SettingsNavRow(
                title: 'Account',
                icon: Icons.badge_outlined,
                onTap: () => context.push(AppRoutePaths.settingsAccount),
              ),
              SettingsNavRow(
                title: 'Security',
                icon: Icons.lock_outline_rounded,
                onTap: () => context.push(AppRoutePaths.settingsSecurity),
              ),
              SettingsNavRow(
                title: 'Notifications',
                icon: Icons.notifications_outlined,
                onTap: () => context.push(AppRoutePaths.settingsNotifications),
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const KitSectionHeader(title: 'Preferences'),
          const SizedBox(height: AppSpacing.xs),
          SettingsListCard(
            children: [
              SettingsNavRow(
                title: 'Payments',
                icon: Icons.account_balance_wallet_outlined,
                onTap: () => context.push(AppRoutePaths.settingsPayments),
              ),
              SettingsNavRow(
                title: 'Equb Preferences',
                icon: Icons.tune_rounded,
                onTap: () =>
                    context.push(AppRoutePaths.settingsEqubPreferences),
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const KitSectionHeader(title: 'More'),
          const SizedBox(height: AppSpacing.xs),
          SettingsListCard(
            children: [
              SettingsNavRow(
                title: 'Data & Privacy',
                icon: Icons.privacy_tip_outlined,
                onTap: () => context.push(AppRoutePaths.settingsDataPrivacy),
              ),
              SettingsNavRow(
                title: 'Support',
                icon: Icons.support_agent_outlined,
                onTap: () => context.push(AppRoutePaths.settingsSupport),
              ),
              SettingsNavRow(
                title: 'About',
                icon: Icons.info_outline_rounded,
                onTap: () => context.push(AppRoutePaths.settingsAbout),
                showDivider: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
