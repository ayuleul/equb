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

    return KitScaffold(
      title: 'Settings',
      actions: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: () => context.push(AppRoutePaths.notifications),
          icon: const Icon(Icons.notifications_outlined),
        ),
      ],
      child: ListView(
        children: [
          KitCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Profile', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  user?.fullName?.trim().isNotEmpty == true
                      ? user!.fullName!
                      : 'Equb member',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  user?.phone ?? 'No phone available',
                  style: Theme.of(context).textTheme.bodyMedium,
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
              child: Text(
                kDebugMode
                    ? 'Build: Debug (long-press to open Theme Preview)'
                    : 'Build: Production',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
