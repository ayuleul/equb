import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'bootstrap.dart';
import '../features/debug/theme_preview_screen.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/screens/otp_screen.dart';
import '../features/auth/screens/phone_screen.dart';
import '../features/home/home_screen.dart';
import '../features/splash/splash_screen.dart';

class AppRoutePaths {
  const AppRoutePaths._();

  static const splash = '/splash';
  static const login = '/login';
  static const otp = '/otp';
  static const home = '/home';
  static const debugTheme = '/debug/theme';
}

final _routerRefreshProvider = Provider<_RouterRefreshNotifier>((ref) {
  final notifier = _RouterRefreshNotifier();

  ref.listen(authControllerProvider, (previous, next) {
    notifier.refresh();
  });
  ref.listen(sessionExpiredProvider, (previous, next) {
    notifier.refresh();
  });

  ref.onDispose(notifier.dispose);
  return notifier;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(_routerRefreshProvider);
  final routes = <GoRoute>[
    GoRoute(
      path: AppRoutePaths.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.login,
      builder: (context, state) => const PhoneScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.otp,
      builder: (context, state) =>
          OtpScreen(phone: state.uri.queryParameters['phone']),
    ),
    GoRoute(
      path: AppRoutePaths.home,
      builder: (context, state) => const HomeScreen(),
    ),
  ];

  if (kDebugMode) {
    routes.add(
      GoRoute(
        path: AppRoutePaths.debugTheme,
        builder: (context, state) => const ThemePreviewScreen(),
      ),
    );
  }

  return GoRouter(
    initialLocation: AppRoutePaths.splash,
    refreshListenable: refreshNotifier,
    routes: routes,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final sessionExpired = ref.read(sessionExpiredProvider);
      final location = state.uri.path;
      final isSplash = location == AppRoutePaths.splash;
      final isLogin = location == AppRoutePaths.login;
      final isOtp = location == AppRoutePaths.otp;
      final isDebugTheme = location == AppRoutePaths.debugTheme;

      if (kDebugMode && isDebugTheme) {
        return null;
      }

      if (sessionExpired) {
        if (!isLogin && !isOtp) {
          return AppRoutePaths.login;
        }
      }

      if (authState.isBootstrapping) {
        return isSplash ? null : AppRoutePaths.splash;
      }

      final isAuthenticated = authState.isAuthenticated;
      if (isSplash) {
        return isAuthenticated ? AppRoutePaths.home : AppRoutePaths.login;
      }

      if (!isAuthenticated && !isLogin && !isOtp) {
        return AppRoutePaths.login;
      }

      if (isAuthenticated && (isLogin || isOtp)) {
        return AppRoutePaths.home;
      }

      return null;
    },
  );
});

class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() {
    notifyListeners();
  }
}
