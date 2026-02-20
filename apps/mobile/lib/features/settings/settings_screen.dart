import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_spacing.dart';
import '../../shared/ui/ui.dart';
import '../auth/auth_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return AppScaffold(
      title: 'Settings',
      subtitle: 'Account and app preferences',
      actions: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: () => context.push(AppRoutePaths.notifications),
          icon: const Icon(Icons.notifications_outlined),
        ),
      ],
      child: ListView(
        children: [
          EqubCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Account', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                FilledButton.icon(
                  onPressed: authState.isLoggingOut
                      ? null
                      : () =>
                            ref.read(authControllerProvider.notifier).logout(),
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(
                    authState.isLoggingOut ? 'Logging out...' : 'Logout',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onLongPress: kDebugMode
                ? () => context.push(AppRoutePaths.debugTheme)
                : null,
            child: EqubCard(
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
