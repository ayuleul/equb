class RealtimeEvent {
  const RealtimeEvent({
    required this.eventType,
    required this.timestamp,
    this.groupId,
    this.turnId,
    this.entityId,
    this.summary,
  });

  static const reconnectEventType = 'realtime.reconnected';

  final String eventType;
  final DateTime timestamp;
  final String? groupId;
  final String? turnId;
  final String? entityId;
  final Map<String, dynamic>? summary;

  bool get isReconnect => eventType == reconnectEventType;

  factory RealtimeEvent.fromPayload(String eventType, Object? payload) {
    final map = payload is Map
        ? Map<String, dynamic>.from(payload)
        : const <String, dynamic>{};

    final rawTimestamp = map['timestamp'];
    final parsedTimestamp = rawTimestamp is String
        ? DateTime.tryParse(rawTimestamp)
        : null;

    return RealtimeEvent(
      eventType: eventType,
      timestamp: parsedTimestamp ?? DateTime.now().toUtc(),
      groupId: map['groupId'] as String?,
      turnId: map['turnId'] as String?,
      entityId: map['entityId'] as String?,
      summary: map['summary'] is Map
          ? Map<String, dynamic>.from(map['summary'] as Map)
          : null,
    );
  }

  factory RealtimeEvent.reconnected() {
    return RealtimeEvent(
      eventType: reconnectEventType,
      timestamp: DateTime.now().toUtc(),
    );
  }
}
