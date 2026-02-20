import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'bootstrap.dart';
import '../features/debug/theme_preview_screen.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/screens/otp_screen.dart';
import '../features/auth/screens/phone_screen.dart';
import '../features/groups/screens/create_group_screen.dart';
import '../features/groups/screens/group_detail_screen.dart';
import '../features/groups/screens/group_invite_screen.dart';
import '../features/groups/screens/group_members_screen.dart';
import '../features/groups/screens/groups_list_screen.dart';
import '../features/groups/screens/join_group_screen.dart';
import '../features/cycles/screens/cycle_detail_screen.dart';
import '../features/cycles/screens/cycles_overview_screen.dart';
import '../features/cycles/screens/generate_cycle_screen.dart';
import '../features/cycles/screens/payout_order_screen.dart';
import '../features/contributions/screens/contributions_list_screen.dart';
import '../features/contributions/screens/submit_contribution_screen.dart';
import '../features/payouts/screens/payout_screen.dart';
import '../features/splash/splash_screen.dart';

class AppRoutePaths {
  const AppRoutePaths._();

  static const splash = '/splash';
  static const login = '/login';
  static const otp = '/otp';
  static const groups = '/groups';
  static const groupsCreate = '/groups/create';
  static const groupsJoin = '/groups/join';
  static const debugTheme = '/debug/theme';

  static String groupDetail(String groupId) => '/groups/$groupId';
  static String groupMembers(String groupId) => '/groups/$groupId/members';
  static String groupInvite(String groupId) => '/groups/$groupId/invite';
  static String groupCycles(String groupId) => '/groups/$groupId/cycles';
  static String groupCyclesCurrent(String groupId) =>
      '/groups/$groupId/cycles/current';
  static String groupCycleDetail(String groupId, String cycleId) =>
      '/groups/$groupId/cycles/$cycleId';
  static String groupPayoutOrder(String groupId) =>
      '/groups/$groupId/payout-order';
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
      path: AppRoutePaths.groups,
      builder: (context, state) => const GroupsListScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.groupsCreate,
      builder: (context, state) => const CreateGroupScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.groupsJoin,
      builder: (context, state) => const JoinGroupScreen(),
    ),
    GoRoute(
      path: '/groups/:id/cycles/generate',
      builder: (context, state) {
        final groupId = state.pathParameters['id'] ?? '';
        return GenerateCycleScreen(groupId: groupId);
      },
    ),
    GoRoute(
      path: '/groups/:id/payout-order',
      builder: (context, state) {
        final groupId = state.pathParameters['id'] ?? '';
        return PayoutOrderScreen(groupId: groupId);
      },
    ),
    GoRoute(
      path: '/groups/:id/cycles/current',
      builder: (context, state) {
        final groupId = state.pathParameters['id'] ?? '';
        return CyclesOverviewScreen(groupId: groupId);
      },
    ),
    GoRoute(
      path: '/groups/:groupId/cycles/:cycleId/contributions/submit',
      builder: (context, state) {
        final groupId = state.pathParameters['groupId'] ?? '';
        final cycleId = state.pathParameters['cycleId'] ?? '';
        return SubmitContributionScreen(groupId: groupId, cycleId: cycleId);
      },
    ),
    GoRoute(
      path: '/groups/:groupId/cycles/:cycleId/contributions',
      builder: (context, state) {
        final groupId = state.pathParameters['groupId'] ?? '';
        final cycleId = state.pathParameters['cycleId'] ?? '';
        return ContributionsListScreen(groupId: groupId, cycleId: cycleId);
      },
    ),
    GoRoute(
      path: '/groups/:groupId/cycles/:cycleId/payout',
      builder: (context, state) {
        final groupId = state.pathParameters['groupId'] ?? '';
        final cycleId = state.pathParameters['cycleId'] ?? '';
        return PayoutScreen(groupId: groupId, cycleId: cycleId);
      },
    ),
    GoRoute(
      path: '/groups/:id/cycles/:cycleId',
      builder: (context, state) {
        final groupId = state.pathParameters['id'] ?? '';
        final cycleId = state.pathParameters['cycleId'] ?? '';
        return CycleDetailScreen(groupId: groupId, cycleId: cycleId);
      },
    ),
    GoRoute(
      path: '/groups/:id/cycles',
      builder: (context, state) {
        final groupId = state.pathParameters['id'] ?? '';
        return CyclesOverviewScreen(groupId: groupId);
      },
    ),
    GoRoute(
      path: '/groups/:id',
      builder: (context, state) {
        final groupId = state.pathParameters['id'] ?? '';
        return GroupDetailScreen(groupId: groupId);
      },
    ),
    GoRoute(
      path: '/groups/:id/members',
      builder: (context, state) {
        final groupId = state.pathParameters['id'] ?? '';
        return GroupMembersScreen(groupId: groupId);
      },
    ),
    GoRoute(
      path: '/groups/:id/invite',
      builder: (context, state) {
        final groupId = state.pathParameters['id'] ?? '';
        return GroupInviteScreen(groupId: groupId);
      },
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
      final isGroupsRoute = location.startsWith(AppRoutePaths.groups);
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
        return isAuthenticated ? AppRoutePaths.groups : AppRoutePaths.login;
      }

      if (!isAuthenticated && isGroupsRoute) {
        return AppRoutePaths.login;
      }

      if (isAuthenticated && (isLogin || isOtp)) {
        return AppRoutePaths.groups;
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
