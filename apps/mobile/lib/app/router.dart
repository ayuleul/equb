import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'bootstrap.dart';
import 'app_shell.dart';
import '../features/debug/theme_preview_screen.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/screens/otp_screen.dart';
import '../features/auth/screens/phone_screen.dart';
import '../features/home/home_screen.dart';
import '../features/groups/screens/create_group_screen.dart';
import '../features/groups/screens/group_detail_screen.dart';
import '../features/groups/screens/group_invite_screen.dart';
import '../features/groups/screens/group_overview_screen.dart';
import '../features/groups/screens/groups_list_screen.dart';
import '../features/groups/screens/join_group_screen.dart';
import '../features/cycles/screens/cycle_detail_screen.dart';
import '../features/cycles/screens/cycles_overview_screen.dart';
import '../features/cycles/screens/generate_cycle_screen.dart';
import '../features/contributions/screens/contributions_list_screen.dart';
import '../features/contributions/screens/submit_contribution_screen.dart';
import '../features/payouts/screens/payout_screen.dart';
import '../features/profile/screens/complete_profile_screen.dart';
import '../features/notifications/screens/notifications_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/splash/splash_screen.dart';

class AppRoutePaths {
  const AppRoutePaths._();

  static const splash = '/splash';
  static const login = '/login';
  static const otp = '/otp';
  static const onboardingProfile = '/onboarding/profile';
  static const home = '/home';
  static const groups = '/groups';
  static const notifications = '/notifications';
  static const settings = '/settings';
  static const groupsCreate = '/groups/create';
  static const groupsJoin = '/groups/join';
  static const debugTheme = '/debug/theme';

  static String groupDetail(String groupId) => '/groups/$groupId';
  static String groupOverview(String groupId) => '/groups/$groupId/overview';
  static String groupInvite(String groupId) => '/groups/$groupId/invite';
  static String groupCycles(String groupId) => '/groups/$groupId/cycles';
  static String groupCyclesCurrent(String groupId) =>
      '/groups/$groupId/cycles/current';
  static String groupCycleDetail(String groupId, String cycleId) =>
      '/groups/$groupId/cycles/$cycleId';
  static String groupCyclesGenerate(String groupId) =>
      '/groups/$groupId/cycles/generate';
  static String groupCycleContributions(String groupId, String cycleId) =>
      '/groups/$groupId/cycles/$cycleId/contributions';
  static String groupCycleContributionsSubmit(String groupId, String cycleId) =>
      '/groups/$groupId/cycles/$cycleId/contributions/submit';
  static String groupCyclePayout(String groupId, String cycleId) =>
      '/groups/$groupId/cycles/$cycleId/payout';
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

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root-nav');
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home-nav');
final _groupsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'groups-nav');
final _settingsNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'settings-nav',
);

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(_routerRefreshProvider);
  final routes = <RouteBase>[
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
      path: AppRoutePaths.onboardingProfile,
      builder: (context, state) => const CompleteProfileScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => AppShell(
        navigationShell: navigationShell,
        currentLocation: state.uri.path,
      ),
      branches: [
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(
              path: AppRoutePaths.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _groupsNavigatorKey,
          routes: [
            GoRoute(
              path: AppRoutePaths.groups,
              builder: (context, state) => const GroupsListScreen(),
              routes: [
                GoRoute(
                  path: 'create',
                  builder: (context, state) => const CreateGroupScreen(),
                ),
                GoRoute(
                  path: 'join',
                  builder: (context, state) => JoinGroupScreen(
                    initialCode: state.uri.queryParameters['code'],
                  ),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final groupId = state.pathParameters['id'] ?? '';
                    return GroupDetailScreen(groupId: groupId);
                  },
                  routes: [
                    GoRoute(
                      path: 'overview',
                      builder: (context, state) {
                        final groupId = state.pathParameters['id'] ?? '';
                        return GroupOverviewScreen(groupId: groupId);
                      },
                    ),
                    GoRoute(
                      path: 'invite',
                      builder: (context, state) {
                        final groupId = state.pathParameters['id'] ?? '';
                        return GroupInviteScreen(groupId: groupId);
                      },
                    ),
                    GoRoute(
                      path: 'cycles',
                      builder: (context, state) {
                        final groupId = state.pathParameters['id'] ?? '';
                        return CyclesOverviewScreen(groupId: groupId);
                      },
                      routes: [
                        GoRoute(
                          path: 'current',
                          builder: (context, state) {
                            final groupId = state.pathParameters['id'] ?? '';
                            return CyclesOverviewScreen(groupId: groupId);
                          },
                        ),
                        GoRoute(
                          path: 'generate',
                          builder: (context, state) {
                            final groupId = state.pathParameters['id'] ?? '';
                            return GenerateCycleScreen(groupId: groupId);
                          },
                        ),
                        GoRoute(
                          path: ':cycleId',
                          builder: (context, state) {
                            final groupId = state.pathParameters['id'] ?? '';
                            final cycleId =
                                state.pathParameters['cycleId'] ?? '';
                            return CycleDetailScreen(
                              groupId: groupId,
                              cycleId: cycleId,
                            );
                          },
                          routes: [
                            GoRoute(
                              path: 'contributions',
                              builder: (context, state) {
                                final groupId =
                                    state.pathParameters['id'] ?? '';
                                final cycleId =
                                    state.pathParameters['cycleId'] ?? '';
                                return ContributionsListScreen(
                                  groupId: groupId,
                                  cycleId: cycleId,
                                );
                              },
                              routes: [
                                GoRoute(
                                  path: 'submit',
                                  builder: (context, state) {
                                    final groupId =
                                        state.pathParameters['id'] ?? '';
                                    final cycleId =
                                        state.pathParameters['cycleId'] ?? '';
                                    return SubmitContributionScreen(
                                      groupId: groupId,
                                      cycleId: cycleId,
                                    );
                                  },
                                ),
                              ],
                            ),
                            GoRoute(
                              path: 'payout',
                              builder: (context, state) {
                                final groupId =
                                    state.pathParameters['id'] ?? '';
                                final cycleId =
                                    state.pathParameters['cycleId'] ?? '';
                                return PayoutScreen(
                                  groupId: groupId,
                                  cycleId: cycleId,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _settingsNavigatorKey,
          routes: [
            GoRoute(
              path: AppRoutePaths.settings,
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutePaths.notifications,
      builder: (context, state) => const NotificationsScreen(),
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
    navigatorKey: _rootNavigatorKey,
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
      final isOnboardingProfile = location == AppRoutePaths.onboardingProfile;
      final isHomeRoute = location.startsWith(AppRoutePaths.home);
      final isGroupsRoute = location.startsWith(AppRoutePaths.groups);
      final isNotificationsRoute = location.startsWith(
        AppRoutePaths.notifications,
      );
      final isSettingsRoute = location.startsWith(AppRoutePaths.settings);
      final isDebugTheme = location == AppRoutePaths.debugTheme;
      final isProtectedRoute =
          isHomeRoute ||
          isGroupsRoute ||
          isNotificationsRoute ||
          isSettingsRoute ||
          isOnboardingProfile;

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
      final requiresProfileCompletion =
          isAuthenticated &&
          authState.user != null &&
          !authState.user!.hasCompleteProfile;
      if (isSplash) {
        if (!isAuthenticated) {
          return AppRoutePaths.login;
        }

        return requiresProfileCompletion
            ? AppRoutePaths.onboardingProfile
            : AppRoutePaths.home;
      }

      if (!isAuthenticated && isProtectedRoute) {
        return AppRoutePaths.login;
      }

      if (isAuthenticated &&
          requiresProfileCompletion &&
          !isOnboardingProfile) {
        return AppRoutePaths.onboardingProfile;
      }

      if (isAuthenticated &&
          !requiresProfileCompletion &&
          isOnboardingProfile) {
        return AppRoutePaths.home;
      }

      if (isAuthenticated && (isLogin || isOtp)) {
        return requiresProfileCompletion
            ? AppRoutePaths.onboardingProfile
            : AppRoutePaths.home;
      }

      return null;
    },
  );
});

void navigateToDeepLink(GoRouter router, String route) {
  final normalizedRoute = route.trim();
  if (normalizedRoute.isEmpty) {
    return;
  }

  if (normalizedRoute.startsWith('${AppRoutePaths.groups}/')) {
    router.go(AppRoutePaths.groups);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      router.push(normalizedRoute);
    });
    return;
  }

  if (normalizedRoute == AppRoutePaths.groups ||
      normalizedRoute == AppRoutePaths.home ||
      normalizedRoute == AppRoutePaths.settings) {
    router.go(normalizedRoute);
    return;
  }

  router.push(normalizedRoute);
}

void navigateToDeepLinkFromContext(BuildContext context, String route) {
  navigateToDeepLink(GoRouter.of(context), route);
}

class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() {
    notifyListeners();
  }
}
