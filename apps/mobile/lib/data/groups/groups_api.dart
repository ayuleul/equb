import 'package:dio/dio.dart';

import '../api/api_error.dart';
import '../api/api_client.dart';
import '../models/create_group_request.dart';
import '../models/join_group_request.dart';
import '../models/group_model.dart';
import '../models/update_group_rules_request.dart';

abstract class GroupsApi {
  Future<List<Map<String, dynamic>>> listGroups();
  Future<List<Map<String, dynamic>>> listPublicGroups();
  Future<List<Map<String, dynamic>>> discoverPublicGroups();
  Future<Map<String, dynamic>> createGroup(CreateGroupRequest request);
  Future<Map<String, dynamic>> getGroup(String groupId);
  Future<Map<String, dynamic>> getPublicGroup(String groupId);
  Future<Map<String, dynamic>> updateGroup(
    String groupId, {
    String? name,
    String? description,
    String? currency,
    GroupVisibilityModel? visibility,
  });
  Future<Map<String, dynamic>?> getGroupRules(String groupId);
  Future<Map<String, dynamic>> upsertGroupRules(
    String groupId,
    UpdateGroupRulesRequest request,
  );
  Future<Map<String, dynamic>> createInvite(String groupId);
  Future<Map<String, dynamic>> joinByCode(JoinGroupRequest request);
  Future<Map<String, dynamic>> requestToJoin(String groupId, {String? message});
  Future<Map<String, dynamic>?> getMyJoinRequest(String groupId);
  Future<List<Map<String, dynamic>>> listJoinRequests(String groupId);
  Future<Map<String, dynamic>> approveJoinRequest(
    String groupId,
    String joinRequestId,
  );
  Future<Map<String, dynamic>> rejectJoinRequest(
    String groupId,
    String joinRequestId,
  );
  Future<List<Map<String, dynamic>>> listMembers(String groupId);
  Future<Map<String, dynamic>> verifyMember(String groupId, String memberId);
  Future<bool> hasOpenCycle(String groupId);
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
  Future<List<Map<String, dynamic>>> listPublicGroups() async {
    final payload = await _apiClient.getList('/groups/public');
    return payload.map(_toMap).toList(growable: false);
  }

  @override
  Future<List<Map<String, dynamic>>> discoverPublicGroups() async {
    final payload = await _apiClient.getMap('/groups/discover');
    final sections = payload['sections'];
    if (sections is! List) {
      return const <Map<String, dynamic>>[];
    }

    return sections.map(_toMap).toList(growable: false);
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
  Future<Map<String, dynamic>> getPublicGroup(String groupId) {
    return _apiClient.getMap('/groups/public/$groupId');
  }

  @override
  Future<Map<String, dynamic>> updateGroup(
    String groupId, {
    String? name,
    String? description,
    String? currency,
    GroupVisibilityModel? visibility,
  }) {
    final data = <String, dynamic>{};
    if (name != null) {
      data['name'] = name;
    }
    if (description != null) {
      data['description'] = description;
    }
    if (currency != null) {
      data['currency'] = currency;
    }
    if (visibility != null) {
      data['visibility'] = visibility.name.toUpperCase();
    }

    return _apiClient.patchMap('/groups/$groupId', data: data);
  }

  @override
  Future<Map<String, dynamic>?> getGroupRules(String groupId) async {
    try {
      return _apiClient.getMap('/groups/$groupId/rules');
    } on ApiError catch (error) {
      if (error.statusCode == 404) {
        return null;
      }
      rethrow;
    } on DioException catch (error) {
      final mapped = ApiError.fromDioException(error);
      if (mapped.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> upsertGroupRules(
    String groupId,
    UpdateGroupRulesRequest request,
  ) {
    return _apiClient.putMap('/groups/$groupId/rules', data: request.toJson());
  }

  @override
  Future<Map<String, dynamic>> createInvite(String groupId) {
    return _apiClient.postMap(
      '/groups/$groupId/invites',
      data: <String, dynamic>{},
    );
  }

  @override
  Future<Map<String, dynamic>> joinByCode(JoinGroupRequest request) {
    return _apiClient.postMap('/groups/join', data: request.toJson());
  }

  @override
  Future<Map<String, dynamic>> requestToJoin(
    String groupId, {
    String? message,
  }) {
    return _apiClient.postMap(
      '/groups/$groupId/join-requests',
      data: <String, dynamic>{
        if (message != null && message.trim().isNotEmpty) 'message': message,
      },
    );
  }

  @override
  Future<Map<String, dynamic>?> getMyJoinRequest(String groupId) async {
    try {
      return _apiClient.getMap('/groups/$groupId/join-request/me');
    } on ApiError catch (error) {
      if (error.statusCode == 404) {
        rethrow;
      }
      final message = error.message.trim().toLowerCase();
      if (message == 'not found.' ||
          message == 'requested resource was not found.' ||
          message.contains('join request not found')) {
        return null;
      }
      rethrow;
    } on DioException catch (error) {
      final mapped = ApiError.fromDioException(error);
      if (mapped.statusCode == 404) {
        rethrow;
      }
      final message = mapped.message.trim().toLowerCase();
      if (message == 'not found.' ||
          message.contains('join request not found')) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> listJoinRequests(String groupId) async {
    final payload = await _apiClient.getList('/groups/$groupId/join-requests');
    return payload.map(_toMap).toList(growable: false);
  }

  @override
  Future<Map<String, dynamic>> approveJoinRequest(
    String groupId,
    String joinRequestId,
  ) {
    return _apiClient.postMap(
      '/groups/$groupId/join-requests/$joinRequestId/approve',
    );
  }

  @override
  Future<Map<String, dynamic>> rejectJoinRequest(
    String groupId,
    String joinRequestId,
  ) {
    return _apiClient.postMap(
      '/groups/$groupId/join-requests/$joinRequestId/reject',
    );
  }

  @override
  Future<List<Map<String, dynamic>>> listMembers(String groupId) async {
    final payload = await _apiClient.getList('/groups/$groupId/members');
    return payload.map(_toMap).toList(growable: false);
  }

  @override
  Future<Map<String, dynamic>> verifyMember(String groupId, String memberId) {
    return _apiClient.postMap('/groups/$groupId/members/$memberId/verify');
  }

  @override
  Future<bool> hasOpenCycle(String groupId) async {
    try {
      final payload = await _apiClient.getObject(
        '/groups/$groupId/cycles/current',
      );
      return payload != null;
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
