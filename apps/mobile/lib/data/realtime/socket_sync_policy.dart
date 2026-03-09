import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../shared/utils/app_logger.dart';
import 'realtime_client.dart';
import 'realtime_event.dart';

final socketSyncPolicyProvider = Provider<SocketSyncPolicy>((ref) {
  final realtimeClient = ref.watch(realtimeClientProvider);
  final logger = ref.watch(appLoggerProvider);
  return SocketSyncPolicy(realtimeClient: realtimeClient, logger: logger);
});

class SocketSyncPolicy {
  const SocketSyncPolicy({
    required RealtimeClient realtimeClient,
    required AppLogger logger,
  }) : _realtimeClient = realtimeClient,
       _logger = logger;

  final RealtimeClient _realtimeClient;
  final AppLogger _logger;

  Future<void> waitForSocketOrFallback({
    required Set<String> eventTypes,
    required Future<void> Function() fallback,
    String? groupId,
    String? turnId,
    String? entityId,
    Duration timeout = const Duration(seconds: 3),
  }) async {
    if (eventTypes.isEmpty) {
      await fallback();
      return;
    }

    final completer = Completer<void>();
    Timer? timer;
    StreamSubscription<RealtimeEvent>? subscription;

    Future<void> finish() async {
      await subscription?.cancel();
      timer?.cancel();
      if (!completer.isCompleted) {
        completer.complete();
      }
    }

    subscription = _realtimeClient.events.listen((event) {
      if (_matchesEvent(
        event,
        eventTypes: eventTypes,
        groupId: groupId,
        turnId: turnId,
        entityId: entityId,
      )) {
        unawaited(finish());
      }
    });

    timer = Timer(timeout, () async {
      try {
        await fallback();
      } catch (error, stackTrace) {
        _logger.error(
          'Socket sync fallback refresh failed.',
          error: error,
          stackTrace: stackTrace,
        );
      } finally {
        await finish();
      }
    });

    await completer.future;
  }

  bool _matchesEvent(
    RealtimeEvent event, {
    required Set<String> eventTypes,
    String? groupId,
    String? turnId,
    String? entityId,
  }) {
    if (!eventTypes.contains(event.eventType)) {
      return false;
    }

    if (groupId != null && event.groupId != groupId) {
      return false;
    }

    if (turnId != null && event.turnId != turnId) {
      return false;
    }

    if (entityId != null && event.entityId != entityId) {
      if (event.entityId != null && event.entityId != entityId) {
        return false;
      }
    }

    return true;
  }
}
