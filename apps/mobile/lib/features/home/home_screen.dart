import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_spacing.dart';
import '../../shared/widgets/primary_button.dart';
import '../auth/auth_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Logged in', style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              if (user != null) ...[
                Text('User ID: ${user.id}', style: theme.textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.xs),
                Text('Phone: ${user.phone}', style: theme.textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Full name: ${user.fullName ?? '-'}',
                  style: theme.textTheme.bodyMedium,
                ),
              ] else
                Text(
                  'No user information available.',
                  style: theme.textTheme.bodyMedium,
                ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Logout',
                isLoading: authState.isLoggingOut,
                onPressed: authState.isLoggingOut
                    ? null
                    : () => ref.read(authControllerProvider.notifier).logout(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
