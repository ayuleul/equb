import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../data/auctions/auction_repository.dart';
import '../../shared/utils/api_error_mapper.dart';
import '../groups/group_detail_controller.dart';
import 'cycle_bids_provider.dart';
import 'cycle_detail_provider.dart';
import 'current_cycle_provider.dart';
import 'cycles_list_provider.dart';

typedef CycleAuctionArgs = ({String groupId, String cycleId});

enum CycleAuctionActionType { none, opening, closing, bidding }

class CycleAuctionActionState {
  const CycleAuctionActionState({
    required this.isLoading,
    required this.actionType,
    this.errorMessage,
  });

  const CycleAuctionActionState.initial()
    : this(isLoading: false, actionType: CycleAuctionActionType.none);

  final bool isLoading;
  final CycleAuctionActionType actionType;
  final String? errorMessage;

  CycleAuctionActionState copyWith({
    bool? isLoading,
    CycleAuctionActionType? actionType,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CycleAuctionActionState(
      isLoading: isLoading ?? this.isLoading,
      actionType: actionType ?? this.actionType,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final cycleAuctionActionControllerProvider =
    StateNotifierProvider.family<
      CycleAuctionActionController,
      CycleAuctionActionState,
      CycleAuctionArgs
    >((ref, args) {
      final repository = ref.watch(auctionRepositoryProvider);
      return CycleAuctionActionController(
        ref: ref,
        args: args,
        repository: repository,
      );
    });

class CycleAuctionActionController
    extends StateNotifier<CycleAuctionActionState> {
  CycleAuctionActionController({
    required Ref ref,
    required CycleAuctionArgs args,
    required this.repository,
  }) : _ref = ref,
       _args = args,
       super(const CycleAuctionActionState.initial());

  final Ref _ref;
  final CycleAuctionArgs _args;
  final AuctionRepository repository;

  Future<bool> openAuction() async {
    state = state.copyWith(
      isLoading: true,
      actionType: CycleAuctionActionType.opening,
      clearError: true,
    );

    try {
      await repository.openAuction(_args.cycleId);
      await _refreshCycleData();
      state = state.copyWith(
        isLoading: false,
        actionType: CycleAuctionActionType.none,
        clearError: true,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        actionType: CycleAuctionActionType.none,
        errorMessage: mapApiErrorToMessage(error),
      );
      return false;
    }
  }

  Future<bool> closeAuction() async {
    state = state.copyWith(
      isLoading: true,
      actionType: CycleAuctionActionType.closing,
      clearError: true,
    );

    try {
      await repository.closeAuction(_args.cycleId);
      await _refreshCycleData();
      state = state.copyWith(
        isLoading: false,
        actionType: CycleAuctionActionType.none,
        clearError: true,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        actionType: CycleAuctionActionType.none,
        errorMessage: mapApiErrorToMessage(error),
      );
      return false;
    }
  }

  Future<bool> submitBid(int amount) async {
    state = state.copyWith(
      isLoading: true,
      actionType: CycleAuctionActionType.bidding,
      clearError: true,
    );

    try {
      await repository.submitBid(_args.cycleId, amount);
      _ref.invalidate(cycleBidsProvider(_args.cycleId));
      state = state.copyWith(
        isLoading: false,
        actionType: CycleAuctionActionType.none,
        clearError: true,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        actionType: CycleAuctionActionType.none,
        errorMessage: mapApiErrorToMessage(error),
      );
      return false;
    }
  }

  Future<void> _refreshCycleData() async {
    _ref
        .read(cyclesRepositoryProvider)
        .invalidateCycleDetail(_args.groupId, _args.cycleId);
    _ref.read(cyclesRepositoryProvider).invalidateGroupCache(_args.groupId);
    _ref.read(groupsRepositoryProvider).invalidateGroup(_args.groupId);
    _ref.invalidate(
      cycleDetailProvider((groupId: _args.groupId, cycleId: _args.cycleId)),
    );
    _ref.invalidate(currentCycleProvider(_args.groupId));
    _ref.invalidate(cyclesListProvider(_args.groupId));
    _ref.invalidate(groupDetailProvider(_args.groupId));
    _ref.invalidate(cycleBidsProvider(_args.cycleId));
  }
}
