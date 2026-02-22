import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/bootstrap.dart';
import 'package:mobile/data/contributions/contributions_api.dart';
import 'package:mobile/data/contributions/contributions_repository.dart';
import 'package:mobile/data/cycles/cycles_api.dart';
import 'package:mobile/data/cycles/cycles_repository.dart';
import 'package:mobile/data/groups/groups_api.dart';
import 'package:mobile/data/groups/groups_repository.dart';
import 'package:mobile/data/models/confirm_payout_request.dart';
import 'package:mobile/data/models/create_group_request.dart';
import 'package:mobile/data/models/create_payout_request.dart';
import 'package:mobile/data/models/join_group_request.dart';
import 'package:mobile/data/models/reject_contribution_request.dart';
import 'package:mobile/data/models/submit_contribution_request.dart';
import 'package:mobile/data/models/user_model.dart';
import 'package:mobile/data/payouts/payouts_api.dart';
import 'package:mobile/data/payouts/payouts_repository.dart';
import 'package:mobile/features/auth/auth_controller.dart';
import 'package:mobile/features/groups/screens/group_detail_screen.dart';
import 'package:mobile/features/groups/screens/group_overview_screen.dart';

void main() {
  testWidgets('Group detail uses current-round hub layout', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Current round'), findsOneWidget);
    expect(find.text('Cycle #3'), findsOneWidget);
    expect(find.text('Contributions'), findsWidgets);
    expect(find.text('Paid: 2 / 2'), findsOneWidget);
    expect(find.text('Round timeline'), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNothing);
    expect(find.byKey(const ValueKey('group-tab-members')), findsNothing);
  });

  testWidgets('Tapping group title pushes full-screen overview route', (
    tester,
  ) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Group summary'), findsNothing);
    await tester.tap(find.text('Family').first);
    await tester.pumpAndSettle();

    expect(find.byType(GroupOverviewScreen), findsOneWidget);
    expect(find.text('Group summary'), findsOneWidget);
    expect(find.text('Members'), findsWidgets);
    expect(find.text('Test User'), findsOneWidget);
  });
}

Widget _buildTestApp() {
  final groupsRepository = GroupsRepository(_FakeGroupsApi());
  final cyclesRepository = CyclesRepository(_FakeCyclesApi());
  final contributionsRepository = ContributionsRepository(
    _FakeContributionsApi(),
  );
  final payoutsRepository = PayoutsRepository(_FakePayoutsApi());

  final router = GoRouter(
    initialLocation: '/groups/group-1',
    routes: [
      GoRoute(
        path: '/groups/:id',
        builder: (context, state) =>
            GroupDetailScreen(groupId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/groups/:id/overview',
        builder: (context, state) =>
            GroupOverviewScreen(groupId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/groups/:id/invite',
        builder: (context, state) => const Scaffold(body: Text('Invite')),
      ),
      GoRoute(
        path: '/groups/:id/cycles/generate',
        builder: (context, state) => const Scaffold(body: Text('Generate')),
      ),
      GoRoute(
        path: '/groups/:id/cycles/:cycleId',
        builder: (context, state) => const Scaffold(body: Text('Cycle detail')),
      ),
      GoRoute(
        path: '/groups/:id/cycles/:cycleId/contributions',
        builder: (context, state) =>
            const Scaffold(body: Text('Contributions list')),
      ),
      GoRoute(
        path: '/groups/:id/cycles/:cycleId/contributions/submit',
        builder: (context, state) =>
            const Scaffold(body: Text('Submit contribution')),
      ),
      GoRoute(
        path: '/groups/:id/cycles/:cycleId/payout',
        builder: (context, state) => const Scaffold(body: Text('Payout')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      groupsRepositoryProvider.overrideWithValue(groupsRepository),
      cyclesRepositoryProvider.overrideWithValue(cyclesRepository),
      contributionsRepositoryProvider.overrideWithValue(
        contributionsRepository,
      ),
      payoutsRepositoryProvider.overrideWithValue(payoutsRepository),
      currentUserProvider.overrideWithValue(
        const UserModel(id: 'user-2', phone: '+251922000000'),
      ),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

class _FakeGroupsApi implements GroupsApi {
  @override
  Future<Map<String, dynamic>> createGroup(CreateGroupRequest request) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> createInvite(String groupId) async {
    return {
      'code': 'ABCDEFGH',
      'expiresAt': DateTime.now()
          .add(const Duration(days: 7))
          .toIso8601String(),
      'joinUrl': 'https://equb.example/invite/ABCDEFGH',
    };
  }

  @override
  Future<Map<String, dynamic>> getGroup(String groupId) async {
    return {
      'id': groupId,
      'name': 'Family',
      'currency': 'ETB',
      'contributionAmount': 1000,
      'frequency': 'MONTHLY',
      'startDate': DateTime(2026, 1, 1).toIso8601String(),
      'status': 'ACTIVE',
      'membership': {'role': 'ADMIN', 'status': 'ACTIVE'},
    };
  }

  @override
  Future<Map<String, dynamic>> joinByCode(JoinGroupRequest request) async {
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> listGroups() async {
    return <Map<String, dynamic>>[];
  }

  @override
  Future<List<Map<String, dynamic>>> listMembers(String groupId) async {
    return [
      {
        'groupId': groupId,
        'role': 'ADMIN',
        'status': 'ACTIVE',
        'payoutPosition': 1,
        'user': {
          'id': 'user-1',
          'phone': '+251911000000',
          'fullName': 'Test User',
        },
      },
      {
        'groupId': groupId,
        'role': 'MEMBER',
        'status': 'ACTIVE',
        'payoutPosition': 2,
        'user': {
          'id': 'user-2',
          'phone': '+251922000000',
          'fullName': 'Second User',
        },
      },
    ];
  }
}

class _FakeCyclesApi implements CyclesApi {
  @override
  Future<Map<String, dynamic>> generateCycles(String groupId) async {
    return _cycle(groupId, 'cycle-generated');
  }

  @override
  Future<Map<String, dynamic>> getCycle(String groupId, String cycleId) async {
    return _cycle(groupId, cycleId);
  }

  @override
  Future<Map<String, dynamic>?> getCurrentCycle(String groupId) async {
    return _cycle(groupId, 'cycle-1');
  }

  @override
  Future<List<Map<String, dynamic>>> listCycles(String groupId) async {
    return [_cycle(groupId, 'cycle-1')];
  }

  @override
  Future<List<Map<String, dynamic>>> setPayoutOrder(
    String groupId,
    List<Map<String, dynamic>> payload,
  ) async {
    return <Map<String, dynamic>>[];
  }

  @override
  Future<Map<String, dynamic>> startRound(String groupId) async {
    return <String, dynamic>{'success': true};
  }

  @override
  Future<Map<String, dynamic>> getCurrentRoundSchedule(String groupId) async {
    return <String, dynamic>{
      'roundId': 'round-1',
      'roundNo': 1,
      'drawSeedHash': 'abc123',
      'schedule': <Map<String, dynamic>>[
        <String, dynamic>{
          'position': 1,
          'userId': 'user-1',
          'displayName': 'Test User',
        },
      ],
    };
  }

  Map<String, dynamic> _cycle(String groupId, String cycleId) {
    return {
      'id': cycleId,
      'groupId': groupId,
      'roundId': 'round-1',
      'cycleNo': 3,
      'dueDate': DateTime(2026, 3, 1).toIso8601String(),
      'scheduledPayoutUserId': 'user-1',
      'finalPayoutUserId': 'user-1',
      'payoutUserId': 'user-1',
      'auctionStatus': 'NONE',
      'winningBidAmount': null,
      'winningBidUserId': null,
      'status': 'OPEN',
      'scheduledPayoutUser': {
        'id': 'user-1',
        'phone': '+251911000000',
        'fullName': 'Test User',
      },
      'finalPayoutUser': {
        'id': 'user-1',
        'phone': '+251911000000',
        'fullName': 'Test User',
      },
      'payoutUser': {
        'id': 'user-1',
        'phone': '+251911000000',
        'fullName': 'Test User',
      },
    };
  }
}

class _FakeContributionsApi implements ContributionsApi {
  @override
  Future<Map<String, dynamic>> confirmContribution(
    String contributionId, {
    String? note,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> listCycleContributions(
    String groupId,
    String cycleId,
  ) async {
    return {
      'items': [
        {
          'id': 'contrib-1',
          'groupId': groupId,
          'cycleId': cycleId,
          'userId': 'user-1',
          'amount': 1000,
          'status': 'SUBMITTED',
          'user': {
            'id': 'user-1',
            'fullName': 'Test User',
            'phone': '+251911000000',
          },
        },
        {
          'id': 'contrib-2',
          'groupId': groupId,
          'cycleId': cycleId,
          'userId': 'user-2',
          'amount': 1000,
          'status': 'CONFIRMED',
          'user': {
            'id': 'user-2',
            'fullName': 'Second User',
            'phone': '+251922000000',
          },
        },
      ],
      'summary': {
        'total': 2,
        'pending': 0,
        'submitted': 1,
        'confirmed': 1,
        'rejected': 0,
      },
    };
  }

  @override
  Future<Map<String, dynamic>> rejectContribution(
    String contributionId,
    RejectContributionRequest request,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> submitContribution(
    String cycleId,
    SubmitContributionRequest request,
  ) async {
    throw UnimplementedError();
  }
}

class _FakePayoutsApi implements PayoutsApi {
  @override
  Future<Map<String, dynamic>> closeCycle(String cycleId) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> confirmPayout(
    String payoutId,
    ConfirmPayoutRequest request,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> createPayout(
    String cycleId,
    CreatePayoutRequest request,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>?> getPayout(String cycleId) async {
    return null;
  }
}
