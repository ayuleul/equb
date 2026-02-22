import '../api/api_error.dart';
import '../api/api_client.dart';
import '../models/create_group_request.dart';
import '../models/join_group_request.dart';

abstract class GroupsApi {
  Future<List<Map<String, dynamic>>> listGroups();
  Future<Map<String, dynamic>> createGroup(CreateGroupRequest request);
  Future<Map<String, dynamic>> getGroup(String groupId);
  Future<Map<String, dynamic>> createInvite(String groupId);
  Future<Map<String, dynamic>> joinByCode(JoinGroupRequest request);
  Future<List<Map<String, dynamic>>> listMembers(String groupId);
  Future<bool> hasActiveRound(String groupId);
}

class DioGroupsApi implements GroupsApi {
  DioGroupsApi(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<Map<String, dynamic>>> listGroups() async {
    final payload = await _apiClient.getList('/groups');
    return payload.map(_toMap).toList(growable: false);
  }

  @override
  Future<Map<String, dynamic>> createGroup(CreateGroupRequest request) {
    return _apiClient.postMap('/groups', data: request.toJson());
  }

  @override
  Future<Map<String, dynamic>> getGroup(String groupId) {
    return _apiClient.getMap('/groups/$groupId');
  }

  @override
  Future<Map<String, dynamic>> createInvite(String groupId) {
    return _apiClient.postMap(
      '/groups/$groupId/invite',
      data: <String, dynamic>{},
    );
  }

  @override
  Future<Map<String, dynamic>> joinByCode(JoinGroupRequest request) {
    return _apiClient.postMap('/groups/join', data: request.toJson());
  }

  @override
  Future<List<Map<String, dynamic>>> listMembers(String groupId) async {
    final payload = await _apiClient.getList('/groups/$groupId/members');
    return payload.map(_toMap).toList(growable: false);
  }

  @override
  Future<bool> hasActiveRound(String groupId) async {
    try {
      await _apiClient.getMap('/groups/$groupId/rounds/current/schedule');
      return true;
    } on ApiError catch (error) {
      if (error.statusCode == 404) {
        return false;
      }
      rethrow;
    }
  }

  Map<String, dynamic> _toMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }
}
