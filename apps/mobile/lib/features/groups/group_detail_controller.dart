import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../data/groups/groups_repository.dart';
import '../../data/models/group_model.dart';
import '../../data/models/member_model.dart';

final _groupDetailVersionProvider = StateProvider.family<int, String>((
  ref,
  id,
) {
  return 0;
});

final _groupMembersVersionProvider = StateProvider.family<int, String>((
  ref,
  id,
) {
  return 0;
});

final groupDetailProvider = FutureProvider.family<GroupModel, String>((
  ref,
  groupId,
) async {
  ref.watch(_groupDetailVersionProvider(groupId));
  final repository = ref.watch(groupsRepositoryProvider);
  return repository.getGroup(groupId);
});

final groupMembersProvider = FutureProvider.family<List<MemberModel>, String>((
  ref,
  groupId,
) async {
  ref.watch(_groupMembersVersionProvider(groupId));
  final repository = ref.watch(groupsRepositoryProvider);
  return repository.listMembers(groupId);
});

final groupDetailControllerProvider = Provider<GroupDetailController>((ref) {
  final repository = ref.watch(groupsRepositoryProvider);
  return GroupDetailController(ref: ref, repository: repository);
});

class GroupDetailController {
  GroupDetailController({required Ref ref, required this.repository})
    : _ref = ref;

  final Ref _ref;
  final GroupsRepository repository;

  Future<void> refreshGroup(String groupId) async {
    repository.invalidateGroup(groupId);
    _ref.read(_groupDetailVersionProvider(groupId).notifier).state += 1;
  }

  Future<void> refreshMembers(String groupId) async {
    repository.invalidateMembers(groupId);
    _ref.read(_groupMembersVersionProvider(groupId).notifier).state += 1;
  }

  Future<void> refreshAll(String groupId) async {
    await refreshGroup(groupId);
    await refreshMembers(groupId);
  }
}
