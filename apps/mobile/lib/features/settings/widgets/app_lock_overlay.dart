import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../shared/kit/kit.dart';
import '../app_lock_controller.dart';

class AppLockOverlayHost extends ConsumerWidget {
  const AppLockOverlayHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lockState = ref.watch(appLockControllerProvider);

    return PopScope(
      canPop: !lockState.isLocked,
      child: Stack(
        children: [
          child,
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: lockState.isLocked
                ? SizedBox.expand(
                    key: const ValueKey('app-lock-overlay'),
                    child: _AppLockOverlay(lockState: lockState),
                  )
                : const SizedBox.shrink(
                    key: ValueKey('app-lock-overlay-hidden'),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AppLockOverlay extends ConsumerWidget {
  const _AppLockOverlay({required this.lockState});

  final AppLockState lockState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      child: Container(
        color: theme.colorScheme.surface,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: KitCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.12,
                          ),
                        ),
                        child: Icon(
                          Icons.lock_rounded,
                          size: 34,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Equb',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Unlock with biometrics',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                      if (lockState.errorMessage != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          lockState.errorMessage!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      KitPrimaryButton(
                        label: lockState.isAuthenticating
                            ? 'Checking...'
                            : 'Unlock with biometrics',
                        icon: Icons.fingerprint_rounded,
                        isLoading: lockState.isAuthenticating,
                        onPressed: lockState.isAuthenticating
                            ? null
                            : () => ref
                                  .read(appLockControllerProvider.notifier)
                                  .unlockWithBiometrics(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
