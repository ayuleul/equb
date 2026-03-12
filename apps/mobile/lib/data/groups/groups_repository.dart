import '../api/api_error.dart';
import '../models/create_group_request.dart';
import '../models/group_model.dart';
import '../models/group_rules_model.dart';
import '../models/invite_model.dart';
import '../models/join_request_model.dart';
import '../models/join_group_request.dart';
import '../models/member_model.dart';
import '../models/public_group_model.dart';
import '../models/update_group_rules_request.dart';
import 'groups_api.dart';

class GroupsRepository {
  GroupsRepository(this._groupsApi);

  final GroupsApi _groupsApi;

  final Map<String, GroupModel> _groupCache = <String, GroupModel>{};
  final Map<String, List<MemberModel>> _membersCache =
      <String, List<MemberModel>>{};
  final Map<String, GroupRulesModel?> _rulesCache =
      <String, GroupRulesModel?>{};
  final Map<String, PublicGroupModel> _publicGroupCache =
      <String, PublicGroupModel>{};
  List<PublicGroupModel>? _publicGroupsCache;
  final Map<String, JoinRequestModel?> _joinRequestCache =
      <String, JoinRequestModel?>{};
  final Map<String, List<JoinRequestModel>> _joinRequestsCache =
      <String, List<JoinRequestModel>>{};

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

  Future<List<PublicGroupModel>> listPublicGroups({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _publicGroupsCache != null) {
      return _publicGroupsCache!;
    }

    final payload = await _groupsApi.listPublicGroups();
    final groups = payload
        .map(PublicGroupModel.fromJson)
        .toList(growable: false);

    _publicGroupsCache = groups;
    for (final group in groups) {
      _publicGroupCache[group.id] = group;
    }

    return groups;
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

  Future<GroupModel> updateGroup(
    String groupId, {
    String? name,
    String? description,
    String? currency,
    GroupVisibilityModel? visibility,
  }) async {
    final payload = await _groupsApi.updateGroup(
      groupId,
      name: name,
      description: description,
      currency: currency,
      visibility: visibility,
    );
    final group = GroupModel.fromJson(payload);
    _groupCache[group.id] = group;
    invalidatePublicGroup(groupId);
    return group;
  }

  Future<PublicGroupModel> getPublicGroup(
    String groupId, {
    bool forceRefresh = false,
  }) async {
    final cached = _publicGroupCache[groupId];
    if (!forceRefresh && cached != null && cached.rules != null) {
      return cached;
    }

    final payload = await _groupsApi.getPublicGroup(groupId);
    final group = PublicGroupModel.fromJson(payload);
    _publicGroupCache[groupId] = group;
    return group;
  }

  Future<InviteModel> createInvite(String groupId) async {
    final payload = await _groupsApi.createInvite(groupId);
    return InviteModel.fromJson(payload);
  }

  Future<GroupRulesModel?> getGroupRules(
    String groupId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _rulesCache.containsKey(groupId)) {
      return _rulesCache[groupId];
    }

    final payload = await _groupsApi.getGroupRules(groupId);
    if (payload == null || payload.isEmpty) {
      _rulesCache[groupId] = null;
      return null;
    }

    final rules = GroupRulesModel.fromJson(payload);
    _rulesCache[groupId] = rules;
    return rules;
  }

  Future<GroupRulesModel> upsertGroupRules(
    String groupId,
    UpdateGroupRulesRequest request,
  ) async {
    final payload = await _groupsApi.upsertGroupRules(groupId, request);
    final rules = GroupRulesModel.fromJson(payload);
    _rulesCache[groupId] = rules;
    invalidateGroup(groupId);
    return rules;
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

  Future<JoinRequestModel> requestToJoin(
    String groupId, {
    String? message,
  }) async {
    final payload = await _groupsApi.requestToJoin(groupId, message: message);
    final request = JoinRequestModel.fromJson(payload);
    _joinRequestCache[groupId] = request;
    invalidatePublicGroup(groupId);
    return request;
  }

  Future<JoinRequestModel?> getMyJoinRequest(
    String groupId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _joinRequestCache.containsKey(groupId)) {
      return _joinRequestCache[groupId];
    }

    final payload = await _groupsApi.getMyJoinRequest(groupId);
    if (payload == null || payload.isEmpty) {
      _joinRequestCache[groupId] = null;
      return null;
    }

    final request = JoinRequestModel.fromJson(payload);
    _joinRequestCache[groupId] = request;
    return request;
  }

  Future<List<JoinRequestModel>> listJoinRequests(
    String groupId, {
    bool forceRefresh = false,
  }) async {
    final cached = _joinRequestsCache[groupId];
    if (!forceRefresh && cached != null) {
      return cached;
    }

    final payload = await _groupsApi.listJoinRequests(groupId);
    final requests = payload
        .map(JoinRequestModel.fromJson)
        .toList(growable: false);
    _joinRequestsCache[groupId] = requests;
    return requests;
  }

  Future<JoinRequestModel> approveJoinRequest(
    String groupId,
    String joinRequestId,
  ) async {
    final payload = await _groupsApi.approveJoinRequest(groupId, joinRequestId);
    final request = JoinRequestModel.fromJson(payload);
    invalidateJoinRequests(groupId);
    invalidateMembers(groupId);
    invalidateGroup(groupId);
    invalidatePublicGroup(groupId);
    return request;
  }

  Future<JoinRequestModel> rejectJoinRequest(
    String groupId,
    String joinRequestId,
  ) async {
    final payload = await _groupsApi.rejectJoinRequest(groupId, joinRequestId);
    final request = JoinRequestModel.fromJson(payload);
    invalidateJoinRequests(groupId);
    invalidatePublicGroup(groupId);
    return request;
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

  Future<MemberModel> verifyMember(String groupId, String memberId) async {
    final payload = await _groupsApi.verifyMember(groupId, memberId);
    final member = MemberModel.fromJson({...payload, 'groupId': groupId});
    invalidateMembers(groupId);
    invalidateGroup(groupId);
    return member;
  }

  Future<bool> hasOpenCycle(String groupId) {
    return _groupsApi.hasOpenCycle(groupId);
  }

  void invalidateGroup(String groupId) {
    _groupCache.remove(groupId);
    _rulesCache.remove(groupId);
  }

  void invalidatePublicGroups() {
    _publicGroupsCache = null;
  }

  void invalidatePublicGroup(String groupId) {
    _publicGroupCache.remove(groupId);
    invalidatePublicGroups();
  }

  void invalidateMembers(String groupId) {
    _membersCache.remove(groupId);
  }

  void invalidateJoinRequests(String groupId) {
    _joinRequestsCache.remove(groupId);
    _joinRequestCache.remove(groupId);
  }
}
