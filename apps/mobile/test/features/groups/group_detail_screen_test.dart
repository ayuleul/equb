import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/bootstrap.dart';
import 'package:mobile/data/contributions/contributions_api.dart';
import 'package:mobile/data/contributions/contributions_repository.dart';
import 'package:mobile/data/cycles/cycles_api.dart';
import 'package:mobile/data/cycles/cycles_repository.dart';
import 'package:mobile/data/auctions/auction_api.dart';
import 'package:mobile/data/auctions/auction_repository.dart';
import 'package:mobile/data/auctions/bids_api.dart';
import 'package:mobile/data/groups/groups_api.dart';
import 'package:mobile/data/groups/groups_repository.dart';
import 'package:mobile/data/models/confirm_payout_request.dart';
import 'package:mobile/data/models/create_group_request.dart';
import 'package:mobile/data/models/create_payout_request.dart';
import 'package:mobile/data/models/create_contribution_dispute_request.dart';
import 'package:mobile/data/models/group_rules_model.dart';
import 'package:mobile/data/models/join_group_request.dart';
import 'package:mobile/data/models/mediate_dispute_request.dart';
import 'package:mobile/data/models/reject_contribution_request.dart';
import 'package:mobile/data/models/resolve_dispute_request.dart';
import 'package:mobile/data/models/submit_contribution_request.dart';
import 'package:mobile/data/models/update_group_rules_request.dart';
import 'package:mobile/data/models/user_model.dart';
import 'package:mobile/data/payouts/payouts_api.dart';
import 'package:mobile/data/payouts/payouts_repository.dart';
import 'package:mobile/features/auth/auth_controller.dart';
import 'package:mobile/features/groups/screens/group_detail_screen.dart';
import 'package:mobile/features/groups/screens/group_overview_screen.dart';
import 'package:mobile/features/turns/screens/turn_details_screen.dart';

void main() {
  testWidgets('Group detail shows unified current turn hero above past turns', (
    tester,
  ) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Turn 3'), findsOneWidget);
    expect(find.text('This turn\'s winner: Test User'), findsOneWidget);
    expect(find.text('View details'), findsOneWidget);
    expect(find.text('Verify payments'), findsNothing);
    expect(find.text('Pay now'), findsNothing);
    expect(find.text('Admin Action'), findsNothing);
    expect(find.text('Contribution Summary'), findsNothing);

    final heroY = tester.getTopLeft(find.text('Turn 3')).dy;

    await tester.scrollUntilVisible(
      find.text('Past Turns'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Past Turns'), findsOneWidget);
    expect(find.text('Turn 2'), findsOneWidget);

    final pastTurnsY = tester.getTopLeft(find.text('Past Turns')).dy;

    expect(heroY, lessThan(pastTurnsY));
    expect(pastTurnsY, greaterThan(0));
  });

  testWidgets('Past turn row pushes turn details route', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Turn 2'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Turn 2'));
    await tester.pumpAndSettle();

    expect(find.byType(TurnDetailsScreen), findsOneWidget);
    expect(find.text('Turn Summary'), findsOneWidget);
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
    expect(find.text('Test User'), findsWidgets);
  });

  testWidgets(
    'Turn detail keeps winner pending until a winner is actually selected',
    (tester) async {
      await tester.pumpWidget(
        _buildTestApp(selectedWinnerAssignedForCurrentCycle: false),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('View details'));
      await tester.pumpAndSettle();

      expect(find.byType(TurnDetailsScreen), findsOneWidget);
      expect(
        find.text('Winner: Will be drawn after collection'),
        findsOneWidget,
      );
      expect(find.textContaining('Winner: Test User'), findsNothing);
    },
  );

  testWidgets('Group detail shows completed Equb CTA after the final payout', (
    tester,
  ) async {
    await tester.pumpWidget(_buildTestApp(completedRound: true));
    await tester.pumpAndSettle();

    expect(find.text('Equb Completed'), findsOneWidget);
    expect(find.text('All members have received their payout.'), findsOneWidget);
    expect(find.text('Start New Cycle'), findsOneWidget);
    expect(find.text('Ready for the next turn'), findsNothing);
  });
}

Widget _buildTestApp({
  bool selectedWinnerAssignedForCurrentCycle = true,
  bool completedRound = false,
}) {
  final groupsRepository = GroupsRepository(_FakeGroupsApi());
  final cyclesRepository = CyclesRepository(
    _FakeCyclesApi(
      selectedWinnerAssignedForCurrentCycle:
          selectedWinnerAssignedForCurrentCycle,
      completedRound: completedRound,
    ),
  );
  final auctionRepository = AuctionRepository(
    auctionApi: _FakeAuctionApi(),
    bidsApi: _FakeBidsApi(),
  );
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
        path: '/groups/:id/cycles/:cycleId',
        builder: (context, state) => TurnDetailsScreen(
          groupId: state.pathParameters['id'] ?? '',
          turnId: state.pathParameters['cycleId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/groups/:id/turns/:turnId',
        builder: (context, state) => TurnDetailsScreen(
          groupId: state.pathParameters['id'] ?? '',
          turnId: state.pathParameters['turnId'] ?? '',
        ),
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
      auctionRepositoryProvider.overrideWithValue(auctionRepository),
      contributionsRepositoryProvider.overrideWithValue(
        contributionsRepository,
      ),
      payoutsRepositoryProvider.overrideWithValue(payoutsRepository),
      appBootstrapConfigProvider.overrideWithValue(
        const AppBootstrapConfig(
          apiBaseUrl: 'http://localhost:3000',
          apiTimeoutMs: 15000,
        ),
      ),
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
      'rulesetConfigured': true,
      'canInviteMembers': true,
      'canStartCycle': true,
      'membership': {'role': 'ADMIN', 'status': 'ACTIVE'},
    };
  }

  @override
  Future<Map<String, dynamic>?> getGroupRules(String groupId) async {
    return {
      'groupId': groupId,
      'contributionAmount': 1000,
      'frequency': 'MONTHLY',
      'customIntervalDays': null,
      'graceDays': 0,
      'fineType': 'NONE',
      'fineAmount': 0,
      'payoutMode': 'LOTTERY',
      'paymentMethods': ['CASH_ACK'],
      'requiresMemberVerification': false,
      'strictCollection': false,
      'roundSize': 8,
      'startPolicy': 'WHEN_FULL',
      'startAt': null,
      'minToStart': null,
      'requiredToStart': 8,
      'readiness': {
        'eligibleCount': 2,
        'isReadyToStart': false,
        'isWaitingForMembers': true,
        'isWaitingForDate': false,
      },
      'createdAt': DateTime(2026, 1, 1).toIso8601String(),
      'updatedAt': DateTime(2026, 1, 1).toIso8601String(),
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

  @override
  Future<bool> hasOpenCycle(String groupId) async {
    return true;
  }

  @override
  Future<Map<String, dynamic>> verifyMember(
    String groupId,
    String memberId,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> upsertGroupRules(
    String groupId,
    UpdateGroupRulesRequest request,
  ) async {
    return {
      'groupId': groupId,
      'contributionAmount': request.contributionAmount,
      'frequency': switch (request.frequency) {
        GroupRuleFrequencyModel.weekly => 'WEEKLY',
        GroupRuleFrequencyModel.monthly => 'MONTHLY',
        GroupRuleFrequencyModel.customInterval => 'CUSTOM_INTERVAL',
        GroupRuleFrequencyModel.unknown => 'MONTHLY',
      },
      'customIntervalDays': request.customIntervalDays,
      'graceDays': request.graceDays,
      'fineType': switch (request.fineType) {
        GroupRuleFineTypeModel.none => 'NONE',
        GroupRuleFineTypeModel.fixedAmount => 'FIXED_AMOUNT',
        GroupRuleFineTypeModel.unknown => 'NONE',
      },
      'fineAmount': request.fineAmount,
      'payoutMode': switch (request.payoutMode) {
        GroupRulePayoutModeModel.lottery => 'LOTTERY',
        GroupRulePayoutModeModel.auction => 'AUCTION',
        GroupRulePayoutModeModel.rotation => 'ROTATION',
        GroupRulePayoutModeModel.decision => 'DECISION',
        GroupRulePayoutModeModel.unknown => 'LOTTERY',
      },
      'paymentMethods': request.paymentMethods
          .map(
            (method) => switch (method) {
              GroupPaymentMethodModel.bank => 'BANK',
              GroupPaymentMethodModel.telebirr => 'TELEBIRR',
              GroupPaymentMethodModel.cashAck => 'CASH_ACK',
              GroupPaymentMethodModel.unknown => 'CASH_ACK',
            },
          )
          .toList(growable: false),
      'requiresMemberVerification': request.requiresMemberVerification,
      'strictCollection': request.strictCollection,
      'roundSize': request.roundSize,
      'startPolicy': switch (request.startPolicy) {
        StartPolicyModel.whenFull => 'WHEN_FULL',
        StartPolicyModel.onDate => 'ON_DATE',
        StartPolicyModel.manual => 'MANUAL',
        StartPolicyModel.unknown => 'WHEN_FULL',
      },
      'startAt': request.startAt?.toIso8601String(),
      'minToStart': request.minToStart,
      'requiredToStart': request.minToStart ?? request.roundSize,
      'readiness': {
        'eligibleCount': 2,
        'isReadyToStart': false,
        'isWaitingForMembers': true,
        'isWaitingForDate': false,
      },
      'createdAt': DateTime(2026, 1, 1).toIso8601String(),
      'updatedAt': DateTime(2026, 1, 1).toIso8601String(),
    };
  }
}

class _FakeCyclesApi implements CyclesApi {
  _FakeCyclesApi({
    this.selectedWinnerAssignedForCurrentCycle = true,
    this.completedRound = false,
  });

  final bool selectedWinnerAssignedForCurrentCycle;
  final bool completedRound;

  @override
  Future<Map<String, dynamic>> startCycle(String groupId) async {
    return _cycle(groupId, 'cycle-generated', isCurrent: true);
  }

  @override
  Future<Map<String, dynamic>> getCycle(String groupId, String cycleId) async {
    if (completedRound) {
      return _completedCycle(
        groupId,
        cycleId,
        cycleId == 'cycle-1' ? 1 : 2,
        cycleId == 'cycle-1' ? 'user-1' : 'user-2',
      );
    }
    return _cycle(groupId, cycleId, isCurrent: cycleId == 'cycle-1');
  }

  @override
  Future<Map<String, dynamic>?> getCurrentCycle(String groupId) async {
    if (completedRound) {
      return null;
    }
    return _cycle(groupId, 'cycle-1', isCurrent: true);
  }

  @override
  Future<List<Map<String, dynamic>>> listCycles(String groupId) async {
    if (completedRound) {
      return [
        _completedCycle(groupId, 'cycle-2', 2, 'user-2'),
        _completedCycle(groupId, 'cycle-1', 1, 'user-1'),
      ];
    }
    return [
      _cycle(groupId, 'cycle-1', isCurrent: true),
      _cycle(groupId, 'cycle-2', isCurrent: false),
    ];
  }

  Map<String, dynamic> _cycle(
    String groupId,
    String cycleId, {
    required bool isCurrent,
  }) {
    return {
      'id': cycleId,
      'groupId': groupId,
      'roundId': 'round-1',
      'cycleNo': isCurrent ? 3 : 2,
      'dueDate': DateTime(2026, isCurrent ? 3 : 2, 1).toIso8601String(),
      'state': isCurrent ? 'COLLECTING' : 'CLOSED',
      'scheduledPayoutUserId': 'user-1',
      'finalPayoutUserId': 'user-1',
      'selectedWinnerUserId': isCurrent
          ? (selectedWinnerAssignedForCurrentCycle ? 'user-1' : null)
          : 'user-1',
      'payoutUserId': 'user-1',
      'auctionStatus': isCurrent ? 'NONE' : 'CLOSED',
      'winningBidAmount': null,
      'winningBidUserId': null,
      'payoutReceivedConfirmedAt': isCurrent
          ? null
          : DateTime(2026, 2, 2).toIso8601String(),
      'status': isCurrent ? 'OPEN' : 'CLOSED',
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
      'selectedWinnerUser': isCurrent && !selectedWinnerAssignedForCurrentCycle
          ? null
          : {'id': 'user-1', 'phone': '+251911000000', 'fullName': 'Test User'},
      'payoutUser': {
        'id': 'user-1',
        'phone': '+251911000000',
        'fullName': 'Test User',
      },
    };
  }

  Map<String, dynamic> _completedCycle(
    String groupId,
    String cycleId,
    int cycleNo,
    String winnerUserId,
  ) {
    final winnerName = winnerUserId == 'user-1' ? 'Test User' : 'Second User';
    final winnerPhone =
        winnerUserId == 'user-1' ? '+251911000000' : '+251922000000';

    return {
      'id': cycleId,
      'groupId': groupId,
      'roundId': 'round-1',
      'cycleNo': cycleNo,
      'dueDate': DateTime(2026, cycleNo, 1).toIso8601String(),
      'state': 'COMPLETED',
      'scheduledPayoutUserId': winnerUserId,
      'finalPayoutUserId': winnerUserId,
      'selectedWinnerUserId': winnerUserId,
      'payoutUserId': winnerUserId,
      'auctionStatus': 'CLOSED',
      'winningBidAmount': null,
      'winningBidUserId': null,
      'payoutReceivedConfirmedAt':
          DateTime(2026, cycleNo, 2).toIso8601String(),
      'status': 'CLOSED',
      'scheduledPayoutUser': {
        'id': winnerUserId,
        'phone': winnerPhone,
        'fullName': winnerName,
      },
      'finalPayoutUser': {
        'id': winnerUserId,
        'phone': winnerPhone,
        'fullName': winnerName,
      },
      'selectedWinnerUser': {
        'id': winnerUserId,
        'phone': winnerPhone,
        'fullName': winnerName,
      },
      'payoutUser': {
        'id': winnerUserId,
        'phone': winnerPhone,
        'fullName': winnerName,
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
  Future<Map<String, dynamic>> verifyContribution(
    String contributionId, {
    String? note,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> evaluateCycleCollection(String cycleId) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> createContributionDispute(
    String contributionId,
    CreateContributionDisputeRequest request,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> listContributionDisputes(
    String contributionId,
  ) async {
    return <Map<String, dynamic>>[];
  }

  @override
  Future<Map<String, dynamic>> mediateDispute(
    String disputeId,
    MediateDisputeRequest request,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> resolveDispute(
    String disputeId,
    ResolveDisputeRequest request,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> listCycleContributions(
    String groupId,
    String cycleId,
  ) async {
    final isCurrent = cycleId == 'cycle-1';
    return {
      'items': [
        {
          'id': 'contrib-1',
          'groupId': groupId,
          'cycleId': cycleId,
          'userId': 'user-1',
          'amount': 1000,
          'status': isCurrent ? 'SUBMITTED' : 'CONFIRMED',
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
        'submitted': isCurrent ? 1 : 0,
        'confirmed': isCurrent ? 1 : 2,
        'rejected': 0,
        'verified': 0,
        'paidSubmitted': 0,
        'late': 0,
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
  Future<Map<String, dynamic>> closeCycle(
    String cycleId, {
    bool autoNext = false,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> disbursePayout(
    String cycleId, {
    String? proofFileKey,
    String? paymentRef,
    String? note,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> sendTurnPayout(
    String turnId, {
    String? proofFileKey,
    String? paymentRef,
    String? note,
  }) async {
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
  Future<Map<String, dynamic>> confirmTurnPayoutReceived(String turnId) async {
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
  Future<Map<String, dynamic>> selectWinner(
    String cycleId, {
    String? userId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>?> getPayout(String cycleId) async {
    return null;
  }
}

class _FakeAuctionApi implements AuctionApi {
  @override
  Future<Map<String, dynamic>> closeAuction(String cycleId) async {
    return {
      'cycleId': cycleId,
      'auctionStatus': 'CLOSED',
      'selectedWinnerUserId': 'user-1',
      'finalPayoutUserId': 'user-1',
      'winningBidAmount': 200,
      'winningBidUserId': 'user-2',
    };
  }

  @override
  Future<Map<String, dynamic>> openAuction(String cycleId) async {
    return {
      'cycleId': cycleId,
      'auctionStatus': 'OPEN',
      'selectedWinnerUserId': 'user-1',
      'finalPayoutUserId': 'user-1',
      'winningBidAmount': null,
      'winningBidUserId': null,
    };
  }
}

class _FakeBidsApi implements BidsApi {
  @override
  Future<List<Map<String, dynamic>>> listBids(String cycleId) async {
    if (cycleId != 'cycle-2') {
      return <Map<String, dynamic>>[];
    }

    return [
      {
        'id': 'bid-1',
        'cycleId': cycleId,
        'userId': 'user-2',
        'amount': 200,
        'createdAt': DateTime(2026, 2, 1, 9).toIso8601String(),
        'updatedAt': DateTime(2026, 2, 1, 9).toIso8601String(),
        'user': {
          'id': 'user-2',
          'fullName': 'Second User',
          'phone': '+251922000000',
        },
      },
    ];
  }

  @override
  Future<Map<String, dynamic>> submitBid(String cycleId, int amount) async {
    return {
      'id': 'bid-new',
      'cycleId': cycleId,
      'userId': 'user-2',
      'amount': amount,
      'createdAt': DateTime(2026, 2, 1, 9).toIso8601String(),
      'updatedAt': DateTime(2026, 2, 1, 9).toIso8601String(),
      'user': {
        'id': 'user-2',
        'fullName': 'Second User',
        'phone': '+251922000000',
      },
    };
  }
}
