import 'package:flutter/foundation.dart';
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
    final authState = ref.watch(authControllerProvider);
    final user = ref.watch(currentUserProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return KitScaffold(
      child: ListView(
        children: [
          KitSectionHeader(
            title: 'Settings',
            kicker: 'Account',
            subtitle: 'Manage your profile and app session.',
            action: IconButton(
              tooltip: 'Notifications',
              onPressed: () => context.push(AppRoutePaths.notifications),
              icon: const Icon(Icons.notifications_outlined),
            ),
          ),
          KitCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Profile', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  user?.displayName ?? 'Equb member',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  user?.phone ?? 'No phone available',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: const [
                    KitBadge(
                      label: 'SECURE SESSION',
                      icon: Icons.verified_user_outlined,
                      tone: KitBadgeTone.info,
                    ),
                    KitBadge(
                      label: 'OTP LOGIN',
                      icon: Icons.password_outlined,
                      tone: KitBadgeTone.success,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
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
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onLongPress: kDebugMode
                ? () => context.push(AppRoutePaths.debugTheme)
                : null,
            child: KitCard(
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      size: 18,
                      color: colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      kDebugMode
                          ? 'Build: Debug (long-press to open Theme Preview)'
                          : 'Build: Production',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
