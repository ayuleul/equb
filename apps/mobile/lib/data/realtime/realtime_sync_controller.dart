import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../features/groups/group_detail_controller.dart';
import '../../features/turns/turn_detail_controller.dart';
import 'realtime_event.dart';

final realtimeSyncControllerProvider = Provider<RealtimeSyncController>((ref) {
  final controller = RealtimeSyncController(ref);
  ref.onDispose(controller.dispose);
  return controller;
});

class RealtimeSyncController {
  RealtimeSyncController(this._ref) {
    _subscription = _ref
        .read(realtimeClientProvider)
        .events
        .listen(_handleEvent);
  }

  static const Duration _debounce = Duration(milliseconds: 300);

  final Ref _ref;
  final Map<String, Timer> _timers = <String, Timer>{};
  late final StreamSubscription<RealtimeEvent> _subscription;

  void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _subscription.cancel();
  }

  void _handleEvent(RealtimeEvent event) {
    if (event.isReconnect) {
      _refreshJoinedRooms();
      return;
    }

    final groupId = event.groupId;
    final turnId = event.turnId;
    final hasActiveTurnSubscription =
        turnId != null &&
        turnId.isNotEmpty &&
        _ref.read(realtimeClientProvider).activeTurnIds.contains(turnId);
    if (groupId == null || groupId.isEmpty) {
      return;
    }

    if (_shouldRefreshGroupPage(event.eventType)) {
      _schedule(
        'group:$groupId',
        () =>
            _ref.read(groupDetailControllerProvider).refreshGroupPage(groupId),
      );
    }

    if (!hasActiveTurnSubscription &&
        _shouldRefreshGroupTurnState(event.eventType)) {
      _schedule(
        'group:$groupId',
        () => _ref
            .read(groupDetailControllerProvider)
            .refreshCurrentTurnState(groupId, cycleId: turnId),
      );
    }

    if (turnId != null &&
        turnId.isNotEmpty &&
        _shouldRefreshTurn(event.eventType)) {
      _schedule(
        'turn:$turnId',
        () => _refreshTurnForEvent(groupId, turnId, event.eventType),
      );
    }
  }

  void _schedule(String key, Future<void> Function() action) {
    _timers[key]?.cancel();
    _timers[key] = Timer(_debounce, () async {
      _timers.remove(key);
      await action();
    });
  }

  void _refreshJoinedRooms() {
    final realtimeClient = _ref.read(realtimeClientProvider);

    for (final groupId in realtimeClient.activeGroupIds) {
      _schedule(
        'group:$groupId',
        () =>
            _ref.read(groupDetailControllerProvider).refreshGroupPage(groupId),
      );
    }

    for (final turnId in realtimeClient.activeTurnIds) {
      final groupId = realtimeClient.groupIdForTurn(turnId);
      if (groupId == null) {
        continue;
      }
      _schedule(
        'turn:$turnId',
        () => _ref
            .read(turnDetailControllerProvider)
            .refreshTurn(groupId, turnId),
      );
    }
  }

  bool _shouldRefreshGroupPage(String eventType) {
    return eventType == 'member.updated';
  }

  bool _shouldRefreshGroupTurnState(String eventType) {
    return switch (eventType) {
      'turn.started' ||
      'turn.updated' ||
      'winner.selected' ||
      'contribution.updated' ||
      'payout.updated' ||
      'turn.completed' => true,
      _ => false,
    };
  }

  bool _shouldRefreshTurn(String eventType) {
    return switch (eventType) {
      'turn.started' ||
      'turn.updated' ||
      'winner.selected' ||
      'contribution.updated' ||
      'payout.updated' ||
      'dispute.updated' ||
      'turn.completed' => true,
      _ => false,
    };
  }

  Future<void> _refreshTurnForEvent(
    String groupId,
    String turnId,
    String eventType,
  ) {
    final controller = _ref.read(turnDetailControllerProvider);
    return switch (eventType) {
      'dispute.updated' => controller.refreshDisputes(groupId, turnId),
      _ => controller.refreshTurnState(groupId, turnId),
    };
  }
}
