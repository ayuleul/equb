import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../data/groups/groups_repository.dart';
import '../../data/models/group_model.dart';
import '../../data/models/member_model.dart';
import '../contributions/cycle_contributions_provider.dart';
import '../cycles/current_cycle_provider.dart';
import '../cycles/cycles_list_provider.dart';
import '../payouts/cycle_payout_provider.dart';
import 'group_rules_provider.dart';

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

  Future<void> refreshGroupPage(String groupId, {String? cycleId}) async {
    repository.invalidateGroup(groupId);
    repository.invalidateMembers(groupId);
    _ref.read(cyclesRepositoryProvider).invalidateGroupCache(groupId);

    _ref.invalidate(groupDetailProvider(groupId));
    _ref.invalidate(groupMembersProvider(groupId));
    _ref.invalidate(groupRulesProvider(groupId));
    _ref.invalidate(currentCycleProvider(groupId));
    _ref.invalidate(cyclesListProvider(groupId));

    final currentCycleFuture = _ref.read(currentCycleProvider(groupId).future);

    await Future.wait([
      _ref.read(groupDetailProvider(groupId).future),
      _ref.read(groupMembersProvider(groupId).future),
      _ref.read(groupRulesProvider(groupId).future),
      _ref.read(cyclesListProvider(groupId).future),
      currentCycleFuture,
    ]);

    final resolvedCycleId = cycleId ?? (await currentCycleFuture)?.id;
    if (resolvedCycleId == null) {
      return;
    }

    _ref.read(payoutsRepositoryProvider).invalidatePayout(resolvedCycleId);
    _ref.invalidate(
      cycleContributionsProvider((groupId: groupId, cycleId: resolvedCycleId)),
    );
    _ref.invalidate(cyclePayoutProvider(resolvedCycleId));

    await Future.wait([
      _ref.read(
        cycleContributionsProvider((
          groupId: groupId,
          cycleId: resolvedCycleId,
        )).future,
      ),
      _ref.read(cyclePayoutProvider(resolvedCycleId).future),
    ]);
  }

  Future<void> refreshCurrentTurnState(
    String groupId, {
    String? cycleId,
  }) async {
    _ref.read(cyclesRepositoryProvider).invalidateGroupCache(groupId);
    _ref.invalidate(currentCycleProvider(groupId));
    _ref.invalidate(cyclesListProvider(groupId));

    final currentCycleFuture = _ref.read(currentCycleProvider(groupId).future);
    final cyclesFuture = _ref.read(cyclesListProvider(groupId).future);

    await Future.wait([currentCycleFuture, cyclesFuture]);

    final resolvedCycleId = cycleId ?? (await currentCycleFuture)?.id;
    if (resolvedCycleId == null) {
      return;
    }

    _ref.read(payoutsRepositoryProvider).invalidatePayout(resolvedCycleId);
    _ref.invalidate(
      cycleContributionsProvider((groupId: groupId, cycleId: resolvedCycleId)),
    );
    _ref.invalidate(cyclePayoutProvider(resolvedCycleId));

    await Future.wait([
      _ref.read(
        cycleContributionsProvider((
          groupId: groupId,
          cycleId: resolvedCycleId,
        )).future,
      ),
      _ref.read(cyclePayoutProvider(resolvedCycleId).future),
    ]);
  }

  Future<void> refreshAfterCycleStart(String groupId) {
    return refreshGroupPage(groupId);
  }
}
