import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/auth_controller.dart';
import '../features/notifications/deeplink_mapper.dart';
import '../features/notifications/device_token_controller.dart';
import '../features/notifications/notification_bootstrap_service.dart';
import '../features/notifications/notifications_list_provider.dart';
import '../features/settings/app_lock_controller.dart';
import '../features/settings/widgets/app_lock_overlay.dart';
import 'bootstrap.dart';
import '../data/realtime/realtime_sync_controller.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class EqubApp extends ConsumerStatefulWidget {
  const EqubApp({super.key});

  @override
  ConsumerState<EqubApp> createState() => _EqubAppState();
}

class _EqubAppState extends ConsumerState<EqubApp> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future<void>.microtask(
      () => ref.read(authControllerProvider.notifier).bootstrap(),
    );
    Future<void>.microtask(
      () => ref.read(appLockControllerProvider.notifier).initialize(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ref.read(appLockControllerProvider.notifier).handleLifecycleChange(state);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(realtimeSyncControllerProvider);

    ref.listen(authControllerProvider, (previous, next) {
      final previousUserId = previous?.user?.id;
      final nextUserId = next.user?.id;
      final wasAuthenticated = previous?.isAuthenticated ?? false;
      final becameAuthenticated =
          next.isAuthenticated &&
          nextUserId != null &&
          (previousUserId == null || previousUserId != nextUserId);
      final becameUnauthenticated = wasAuthenticated && !next.isAuthenticated;

      if (becameAuthenticated) {
        Future<void>.microtask(
          () => ref.read(realtimeClientProvider).connect(),
        );
      } else if (becameUnauthenticated) {
        ref.read(realtimeClientProvider).disconnect();
      }

      if (!becameAuthenticated) {
        return;
      }

      Future<void>.microtask(() async {
        final bootstrap = ref.read(notificationBootstrapProvider);
        await bootstrap.initialize(
          onForegroundNotification: ({required title, required body}) {
            _showForegroundSnack(title, body);
            ref.invalidate(notificationsListProvider);
          },
          onPayloadOpened: (payload) {
            final location = mapNotificationPayloadToLocation(payload);
            if (location == null) {
              _showForegroundSnack('Notification', 'No details available.');
              return;
            }

            navigateToDeepLink(ref.read(appRouterProvider), location);
          },
          onTokenRefresh: (token) async {
            final currentUserId = ref.read(currentUserProvider)?.id;
            if (currentUserId == null) {
              return;
            }

            await ref
                .read(deviceTokenControllerProvider.notifier)
                .registerTokenIfChanged(userId: currentUserId, token: token);
          },
        );

        await ref
            .read(deviceTokenControllerProvider.notifier)
            .syncTokenForUser(nextUserId);
      });
    });

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Equb',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      routerConfig: router,
      builder: (context, child) {
        return AppLockOverlayHost(child: child ?? const SizedBox.shrink());
      },
    );
  }

  void _showForegroundSnack(String title, String body) {
    final messenger = _scaffoldMessengerKey.currentState;
    if (messenger == null) {
      return;
    }

    final text = body.trim().isEmpty ? title : '$title\n$body';
    messenger.showSnackBar(SnackBar(content: Text(text)));
  }
}
