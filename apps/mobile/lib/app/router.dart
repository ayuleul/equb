import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'bootstrap.dart';
import '../features/debug/theme_preview_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/home/home_screen.dart';
import '../features/splash/splash_screen.dart';

class AppRoutePaths {
  const AppRoutePaths._();

  static const splash = '/splash';
  static const login = '/login';
  static const home = '/home';
  static const debugTheme = '/debug/theme';
}

final authBootstrapProvider = FutureProvider<bool>((ref) async {
  final tokenStore = ref.watch(tokenStoreProvider);
  final accessToken = await tokenStore.getAccessToken();
  final refreshToken = await tokenStore.getRefreshToken();

  return (accessToken?.isNotEmpty ?? false) ||
      (refreshToken?.isNotEmpty ?? false);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final sessionExpired = ref.watch(sessionExpiredProvider);
  final authBootstrap = ref.watch(authBootstrapProvider);
  final routes = <GoRoute>[
    GoRoute(
      path: AppRoutePaths.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.login,
      builder: (context, state) => const LoginScreen(),
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
    routes: routes,
    redirect: (context, state) {
      final location = state.uri.path;
      final isSplash = location == AppRoutePaths.splash;
      final isLogin = location == AppRoutePaths.login;
      final isHome = location == AppRoutePaths.home;
      final isDebugTheme = location == AppRoutePaths.debugTheme;

      if (kDebugMode && isDebugTheme) {
        return null;
      }

      if (sessionExpired) {
        if (!isLogin) {
          return AppRoutePaths.login;
        }

        return null;
      }

      if (authBootstrap.isLoading) {
        return isSplash ? null : AppRoutePaths.splash;
      }

      if (authBootstrap.hasError) {
        return isLogin ? null : AppRoutePaths.login;
      }

      final isAuthenticated = authBootstrap.value ?? false;
      if (isSplash) {
        return isAuthenticated ? AppRoutePaths.home : AppRoutePaths.login;
      }

      if (!isAuthenticated && isHome) {
        return AppRoutePaths.login;
      }

      if (isAuthenticated && isLogin) {
        return AppRoutePaths.home;
      }

      return null;
    },
  );
});
