import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/groups/groups_api.dart';
import 'package:mobile/data/groups/groups_repository.dart';
import 'package:mobile/data/models/create_group_request.dart';
import 'package:mobile/data/models/group_model.dart';
import 'package:mobile/data/models/join_group_request.dart';
import 'package:mobile/data/models/update_group_rules_request.dart';

void main() {
  group('GroupsRepository.listMyGroups', () {
    test('maps API payload to typed GroupModel list', () async {
      final repository = GroupsRepository(
        _FakeGroupsApi(
          groupsPayload: <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'group-1',
              'name': 'Family Equb',
              'currency': 'ETB',
              'contributionAmount': 500,
              'frequency': 'MONTHLY',
              'startDate': '2026-03-01T00:00:00.000Z',
              'status': 'ACTIVE',
            },
          ],
        ),
      );

      final groups = await repository.listMyGroups();

      expect(groups, hasLength(1));
      expect(groups.first.id, 'group-1');
      expect(groups.first.name, 'Family Equb');
      expect(groups.first.currency, 'ETB');
      expect(groups.first.contributionAmount, 500);
      expect(groups.first.frequency, GroupFrequencyModel.monthly);
      expect(groups.first.status, GroupStatusModel.active);
    });
  });
}

class _FakeGroupsApi implements GroupsApi {
  _FakeGroupsApi({required this.groupsPayload});

  final List<Map<String, dynamic>> groupsPayload;

  @override
  Future<List<Map<String, dynamic>>> listGroups() async => groupsPayload;

  @override
  Future<List<Map<String, dynamic>>> listPublicGroups() async => const [];

  @override
  Future<Map<String, dynamic>> createGroup(CreateGroupRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> createInvite(String groupId) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getGroup(String groupId) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getPublicGroup(String groupId) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> updateGroup(
    String groupId, {
    String? name,
    String? description,
    String? currency,
    GroupVisibilityModel? visibility,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>?> getGroupRules(String groupId) async {
    return null;
  }

  @override
  Future<Map<String, dynamic>> joinByCode(JoinGroupRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> requestToJoin(
    String groupId, {
    String? message,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>?> getMyJoinRequest(String groupId) async {
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> listJoinRequests(String groupId) async {
    return const [];
  }

  @override
  Future<Map<String, dynamic>> approveJoinRequest(
    String groupId,
    String joinRequestId,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> rejectJoinRequest(
    String groupId,
    String joinRequestId,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> listMembers(String groupId) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> verifyMember(String groupId, String memberId) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> upsertGroupRules(
    String groupId,
    UpdateGroupRulesRequest request,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<bool> hasOpenCycle(String groupId) async {
    return false;
  }
}
