import '../api/api_error.dart';
import '../models/create_group_request.dart';
import '../models/group_model.dart';
import '../models/invite_model.dart';
import '../models/join_group_request.dart';
import '../models/member_model.dart';
import 'groups_api.dart';

class GroupsRepository {
  GroupsRepository(this._groupsApi);

  final GroupsApi _groupsApi;

  final Map<String, GroupModel> _groupCache = <String, GroupModel>{};
  final Map<String, List<MemberModel>> _membersCache =
      <String, List<MemberModel>>{};

  Future<List<GroupModel>> listMyGroups() async {
    final payload = await _groupsApi.listGroups();
    final groups = payload.map(GroupModel.fromJson).toList(growable: false);

    for (final group in groups) {
      final existing = _groupCache[group.id];

      if (existing != null &&
          existing.membership != null &&
          group.membership == null) {
        continue;
      }

      _groupCache[group.id] = group;
    }

    return groups;
  }

  Future<GroupModel> createGroup(CreateGroupRequest request) async {
    final payload = await _groupsApi.createGroup(request);
    final group = GroupModel.fromJson(payload);
    _groupCache[group.id] = group;
    return group;
  }

  Future<GroupModel> getGroup(
    String groupId, {
    bool forceRefresh = false,
  }) async {
    final cached = _groupCache[groupId];
    if (!forceRefresh && cached != null && cached.membership != null) {
      return cached;
    }

    final payload = await _groupsApi.getGroup(groupId);
    final group = GroupModel.fromJson(payload);
    _groupCache[group.id] = group;
    return group;
  }

  Future<InviteModel> createInvite(String groupId) async {
    final payload = await _groupsApi.createInvite(groupId);
    return InviteModel.fromJson(payload);
  }

  Future<String> joinByCode(String code) async {
    final payload = await _groupsApi.joinByCode(JoinGroupRequest(code: code));

    final groupId = payload['groupId'];
    if (groupId is! String || groupId.isEmpty) {
      throw const ApiError(
        type: ApiErrorType.unknown,
        message: 'Join response did not include groupId.',
      );
    }

    invalidateGroup(groupId);
    invalidateMembers(groupId);

    return groupId;
  }

  Future<List<MemberModel>> listMembers(
    String groupId, {
    bool forceRefresh = false,
  }) async {
    final cached = _membersCache[groupId];
    if (!forceRefresh && cached != null) {
      return cached;
    }

    final payload = await _groupsApi.listMembers(groupId);
    final members = payload
        .map((json) => MemberModel.fromJson({...json, 'groupId': groupId}))
        .toList(growable: false);

    _membersCache[groupId] = members;

    return members;
  }

  Future<bool> hasActiveRound(String groupId) {
    return _groupsApi.hasActiveRound(groupId);
  }

  void invalidateGroup(String groupId) {
    _groupCache.remove(groupId);
  }

  void invalidateMembers(String groupId) {
    _membersCache.remove(groupId);
  }
}
