import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../data/cycles/cycles_repository.dart';
import '../../data/groups/groups_repository.dart';
import '../../data/models/group_model.dart';
import '../../data/models/member_model.dart';
import '../../data/models/payout_order_item.dart';
import '../../shared/utils/api_error_mapper.dart';
import '../groups/group_detail_controller.dart';
import 'current_cycle_provider.dart';
import 'cycles_list_provider.dart';

class PayoutOrderState {
  const PayoutOrderState({
    required this.members,
    required this.isLoading,
    required this.isSaving,
    this.errorMessage,
  });

  const PayoutOrderState.initial()
    : this(members: const <MemberModel>[], isLoading: false, isSaving: false);

  final List<MemberModel> members;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  bool get hasData => members.isNotEmpty;

  bool get hasMissingNames => members.any((member) {
    final fullName = member.user.fullName?.trim();
    return fullName == null || fullName.isEmpty;
  });

  PayoutOrderState copyWith({
    List<MemberModel>? members,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PayoutOrderState(
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final payoutOrderControllerProvider =
    StateNotifierProvider.family<
      PayoutOrderController,
      PayoutOrderState,
      String
    >((ref, groupId) {
      final cyclesRepository = ref.watch(cyclesRepositoryProvider);
      final groupsRepository = ref.watch(groupsRepositoryProvider);
      return PayoutOrderController(
        ref: ref,
        groupId: groupId,
        cyclesRepository: cyclesRepository,
        groupsRepository: groupsRepository,
      );
    });

class PayoutOrderController extends StateNotifier<PayoutOrderState> {
  PayoutOrderController({
    required Ref ref,
    required this.groupId,
    required CyclesRepository cyclesRepository,
    required GroupsRepository groupsRepository,
  }) : _ref = ref,
       _cyclesRepository = cyclesRepository,
       _groupsRepository = groupsRepository,
       super(const PayoutOrderState.initial()) {
    Future<void>.microtask(loadMembers);
  }

  final Ref _ref;
  final String groupId;
  final CyclesRepository _cyclesRepository;
  final GroupsRepository _groupsRepository;

  Future<void> loadMembers() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final members = await _ref.read(groupMembersProvider(groupId).future);
      final activeMembers = members
          .where((member) => member.status == MemberStatusModel.active)
          .toList(growable: false);

      final ordered = [...activeMembers]..sort(_compareMembers);

      state = state.copyWith(
        members: ordered,
        isLoading: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: mapApiErrorToMessage(error),
      );
    }
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= state.members.length) {
      return;
    }

    var adjustedNewIndex = newIndex;
    if (adjustedNewIndex > oldIndex) {
      adjustedNewIndex -= 1;
    }

    if (adjustedNewIndex < 0 || adjustedNewIndex >= state.members.length) {
      return;
    }

    final updated = [...state.members];
    final item = updated.removeAt(oldIndex);
    updated.insert(adjustedNewIndex, item);

    state = state.copyWith(members: updated, clearError: true);
  }

  Future<bool> save() async {
    if (state.members.isEmpty) {
      state = state.copyWith(errorMessage: 'No active members to order.');
      return false;
    }

    final requestItems = buildPayoutOrderItems(state.members);
    state = state.copyWith(isSaving: true, clearError: true);

    try {
      await _cyclesRepository.setPayoutOrder(groupId, requestItems);

      _groupsRepository.invalidateMembers(groupId);
      _cyclesRepository.invalidateGroupCache(groupId);

      _ref.invalidate(groupMembersProvider(groupId));
      _ref.invalidate(currentCycleProvider(groupId));
      _ref.invalidate(cyclesListProvider(groupId));

      state = state.copyWith(isSaving: false, clearError: true);
      return true;
    } catch (error) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: mapApiErrorToMessage(error),
      );
      return false;
    }
  }
}

int _compareMembers(MemberModel a, MemberModel b) {
  final posA = a.payoutPosition ?? 1 << 20;
  final posB = b.payoutPosition ?? 1 << 20;
  final byPosition = posA.compareTo(posB);
  if (byPosition != 0) {
    return byPosition;
  }

  final nameA = a.displayName.toLowerCase();
  final nameB = b.displayName.toLowerCase();
  return nameA.compareTo(nameB);
}

List<PayoutOrderItem> buildPayoutOrderItems(List<MemberModel> orderedMembers) {
  return orderedMembers
      .asMap()
      .entries
      .map(
        (entry) => PayoutOrderItem(
          userId: entry.value.userId,
          payoutPosition: entry.key + 1,
        ),
      )
      .toList(growable: false);
}
