import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../data/auctions/auction_repository.dart';
import '../../data/realtime/socket_sync_policy.dart';
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

  Future<bool> openAuction({bool preferSocketSync = false}) async {
    state = state.copyWith(
      isLoading: true,
      actionType: CycleAuctionActionType.opening,
      clearError: true,
    );

    try {
      await repository.openAuction(_args.cycleId);
      if (preferSocketSync) {
        unawaited(
          _ref
              .read(socketSyncPolicyProvider)
              .waitForSocketOrFallback(
                eventTypes: const {'turn.updated'},
                groupId: _args.groupId,
                turnId: _args.cycleId,
                fallback: _refreshCycleData,
              ),
        );
      } else {
        await _refreshCycleData();
      }
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

  Future<bool> closeAuction({bool preferSocketSync = false}) async {
    state = state.copyWith(
      isLoading: true,
      actionType: CycleAuctionActionType.closing,
      clearError: true,
    );

    try {
      await repository.closeAuction(_args.cycleId);
      if (preferSocketSync) {
        unawaited(
          _ref
              .read(socketSyncPolicyProvider)
              .waitForSocketOrFallback(
                eventTypes: const {'turn.updated', 'winner.selected'},
                groupId: _args.groupId,
                turnId: _args.cycleId,
                fallback: _refreshCycleData,
              ),
        );
      } else {
        await _refreshCycleData();
      }
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

  Future<bool> submitBid(int amount, {bool preferSocketSync = false}) async {
    state = state.copyWith(
      isLoading: true,
      actionType: CycleAuctionActionType.bidding,
      clearError: true,
    );

    try {
      await repository.submitBid(_args.cycleId, amount);
      if (preferSocketSync) {
        unawaited(
          _ref
              .read(socketSyncPolicyProvider)
              .waitForSocketOrFallback(
                eventTypes: const {'turn.updated'},
                groupId: _args.groupId,
                turnId: _args.cycleId,
                fallback: () async {
                  _ref.invalidate(cycleBidsProvider(_args.cycleId));
                  await _ref.read(cycleBidsProvider(_args.cycleId).future);
                },
              ),
        );
      } else {
        _ref.invalidate(cycleBidsProvider(_args.cycleId));
      }
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
    _ref.invalidate(
      cycleDetailProvider((groupId: _args.groupId, cycleId: _args.cycleId)),
    );
    _ref.invalidate(currentCycleProvider(_args.groupId));
    _ref.invalidate(cyclesListProvider(_args.groupId));
    _ref.invalidate(cycleBidsProvider(_args.cycleId));
    await Future.wait([
      _ref.read(
        cycleDetailProvider((
          groupId: _args.groupId,
          cycleId: _args.cycleId,
        )).future,
      ),
      _ref.read(currentCycleProvider(_args.groupId).future),
      _ref.read(cyclesListProvider(_args.groupId).future),
      _ref.read(cycleBidsProvider(_args.cycleId).future),
      _ref
          .read(groupDetailControllerProvider)
          .refreshCurrentTurnState(_args.groupId, cycleId: _args.cycleId),
    ]);
  }
}
