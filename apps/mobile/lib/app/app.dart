import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/auth_controller.dart';
import '../features/notifications/deeplink_mapper.dart';
import '../features/notifications/device_token_controller.dart';
import '../features/notifications/notification_bootstrap_service.dart';
import '../features/notifications/notifications_list_provider.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class EqubApp extends ConsumerStatefulWidget {
  const EqubApp({super.key});

  @override
  ConsumerState<EqubApp> createState() => _EqubAppState();
}

class _EqubAppState extends ConsumerState<EqubApp> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref.read(authControllerProvider.notifier).bootstrap(),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      final previousUserId = previous?.user?.id;
      final nextUserId = next.user?.id;
      final becameAuthenticated =
          next.isAuthenticated &&
          nextUserId != null &&
          (previousUserId == null || previousUserId != nextUserId);

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

            ref.read(appRouterProvider).go(location);
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
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      routerConfig: router,
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
