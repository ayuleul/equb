import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../data/models/discover_section_model.dart';
import '../../data/models/join_request_model.dart';
import '../../data/models/public_group_model.dart';
import 'group_detail_controller.dart';

final publicGroupsProvider = FutureProvider<List<PublicGroupModel>>((
  ref,
) async {
  final repository = ref.watch(groupsRepositoryProvider);
  return repository.listPublicGroups();
});

final discoverSectionsProvider = FutureProvider<List<DiscoverSectionModel>>((
  ref,
) async {
  final repository = ref.watch(groupsRepositoryProvider);
  return repository.discoverPublicGroups();
});

final publicGroupDetailProvider =
    FutureProvider.family<PublicGroupModel, String>((ref, groupId) async {
      final repository = ref.watch(groupsRepositoryProvider);
      return repository.getPublicGroup(groupId, forceRefresh: true);
    });

final myJoinRequestProvider = FutureProvider.family<JoinRequestModel?, String>((
  ref,
  groupId,
) async {
  final repository = ref.watch(groupsRepositoryProvider);
  return repository.getMyJoinRequest(groupId, forceRefresh: true);
});

final pendingJoinRequestsProvider =
    FutureProvider.family<List<JoinRequestModel>, String>((ref, groupId) async {
      final repository = ref.watch(groupsRepositoryProvider);
      return repository.listJoinRequests(groupId, forceRefresh: true);
    });

final publicGroupsControllerProvider = Provider<PublicGroupsController>((ref) {
  return PublicGroupsController(ref);
});

class PublicGroupsController {
  PublicGroupsController(this._ref);

  final Ref _ref;

  Future<void> refreshPublicGroups() async {
    final repository = _ref.read(groupsRepositoryProvider);
    repository.invalidatePublicGroups();
    _ref.invalidate(publicGroupsProvider);
    _ref.invalidate(discoverSectionsProvider);
    await Future.wait([
      _ref.read(publicGroupsProvider.future),
      _ref.read(discoverSectionsProvider.future),
    ]);
  }

  Future<void> refreshPublicGroup(String groupId) async {
    final repository = _ref.read(groupsRepositoryProvider);
    repository.invalidatePublicGroup(groupId);
    repository.invalidateJoinRequests(groupId);
    _ref.invalidate(publicGroupDetailProvider(groupId));
    _ref.invalidate(myJoinRequestProvider(groupId));
    await Future.wait([
      _ref.read(publicGroupDetailProvider(groupId).future),
      _ref.read(myJoinRequestProvider(groupId).future),
    ]);
  }

  Future<JoinRequestModel> requestToJoin(
    String groupId, {
    String? message,
  }) async {
    final repository = _ref.read(groupsRepositoryProvider);
    final request = await repository.requestToJoin(groupId, message: message);
    _ref.invalidate(publicGroupDetailProvider(groupId));
    _ref.invalidate(myJoinRequestProvider(groupId));
    return request;
  }

  Future<void> refreshJoinRequests(String groupId) async {
    final repository = _ref.read(groupsRepositoryProvider);
    repository.invalidateJoinRequests(groupId);
    _ref.invalidate(pendingJoinRequestsProvider(groupId));
    await _ref.read(pendingJoinRequestsProvider(groupId).future);
  }

  Future<JoinRequestModel> approveJoinRequest(
    String groupId,
    String joinRequestId,
  ) async {
    final repository = _ref.read(groupsRepositoryProvider);
    final request = await repository.approveJoinRequest(groupId, joinRequestId);
    _ref.invalidate(pendingJoinRequestsProvider(groupId));
    _ref.invalidate(publicGroupDetailProvider(groupId));
    _ref.invalidate(groupDetailProvider(groupId));
    _ref.invalidate(groupMembersProvider(groupId));
    return request;
  }

  Future<JoinRequestModel> rejectJoinRequest(
    String groupId,
    String joinRequestId,
  ) async {
    final repository = _ref.read(groupsRepositoryProvider);
    final request = await repository.rejectJoinRequest(groupId, joinRequestId);
    _ref.invalidate(pendingJoinRequestsProvider(groupId));
    _ref.invalidate(publicGroupDetailProvider(groupId));
    return request;
  }
}
