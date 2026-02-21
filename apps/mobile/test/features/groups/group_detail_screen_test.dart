import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/bootstrap.dart';
import 'package:mobile/data/groups/groups_api.dart';
import 'package:mobile/data/groups/groups_repository.dart';
import 'package:mobile/data/models/create_group_request.dart';
import 'package:mobile/data/models/join_group_request.dart';
import 'package:mobile/features/groups/screens/group_detail_screen.dart';

void main() {
  testWidgets('GroupDetailScreen renders invite/action sections', (
    tester,
  ) async {
    final repository = GroupsRepository(_FakeGroupsApi());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [groupsRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: GroupDetailScreen(groupId: 'group-1')),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Invite new members'), findsOneWidget);
    expect(find.text('Overview'), findsOneWidget);
    expect(find.byKey(const ValueKey('group-tab-members')), findsOneWidget);
    expect(find.byKey(const ValueKey('group-tab-cycles')), findsOneWidget);
    expect(find.byKey(const ValueKey('group-tab-payoutOrder')), findsOneWidget);
    expect(find.byKey(const ValueKey('group-tab-invite')), findsNothing);
  });

  testWidgets(
    'GroupDetailScreen stays stable on narrow screens with larger text scale',
    (tester) async {
      final repository = GroupsRepository(_FakeGroupsApi());

      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [groupsRepositoryProvider.overrideWithValue(repository)],
          child: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 640),
              textScaler: TextScaler.linear(2.0),
            ),
            child: const MaterialApp(
              home: GroupDetailScreen(groupId: 'group-1'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -900));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'GroupDetailScreen stays stable on very narrow screens with very large text',
    (tester) async {
      final repository = GroupsRepository(_FakeGroupsApi());

      await tester.binding.setSurfaceSize(const Size(280, 620));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [groupsRepositoryProvider.overrideWithValue(repository)],
          child: MediaQuery(
            data: const MediaQueryData(
              size: Size(280, 620),
              textScaler: TextScaler.linear(2.6),
            ),
            child: const MaterialApp(
              home: GroupDetailScreen(groupId: 'group-1'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -1200));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    },
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
    return [];
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
