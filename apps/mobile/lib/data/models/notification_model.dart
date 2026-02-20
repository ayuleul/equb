import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

enum NotificationTypeModel {
  @JsonValue('MEMBER_JOINED')
  memberJoined,
  @JsonValue('CONTRIBUTION_SUBMITTED')
  contributionSubmitted,
  @JsonValue('CONTRIBUTION_CONFIRMED')
  contributionConfirmed,
  @JsonValue('CONTRIBUTION_REJECTED')
  contributionRejected,
  @JsonValue('PAYOUT_CONFIRMED')
  payoutConfirmed,
  @JsonValue('DUE_REMINDER')
  dueReminder,
  unknown,
}

enum NotificationStatusModel {
  @JsonValue('UNREAD')
  unread,
  @JsonValue('READ')
  read,
  unknown,
}

@freezed
sealed class NotificationModel with _$NotificationModel {
  const NotificationModel._();

  const factory NotificationModel({
    required String id,
    required String userId,
    String? groupId,
    @JsonKey(unknownEnumValue: NotificationTypeModel.unknown)
    required NotificationTypeModel type,
    required String title,
    required String body,
    @JsonKey(fromJson: _mapFromJson, toJson: _mapToJson)
    Map<String, dynamic>? dataJson,
    @JsonKey(unknownEnumValue: NotificationStatusModel.unknown)
    required NotificationStatusModel status,
    required DateTime createdAt,
    DateTime? readAt,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  bool get isUnread => status == NotificationStatusModel.unread;

  Map<String, dynamic> get deepLinkPayload {
    final payload = <String, dynamic>{...?dataJson};

    final payloadGroupId = _asNonEmptyString(payload['groupId']);
    if (payloadGroupId == null) {
      final group = _asNonEmptyString(groupId);
      if (group != null) {
        payload['groupId'] = group;
      }
    }

    payload['type'] = notificationTypeWireValue(type);
    return payload;
  }
}

@freezed
sealed class NotificationListModel with _$NotificationListModel {
  const factory NotificationListModel({
    @Default(<NotificationModel>[]) List<NotificationModel> items,
    @JsonKey(fromJson: _toInt) @Default(0) int total,
    @JsonKey(fromJson: _toInt) @Default(0) int offset,
    @JsonKey(fromJson: _toInt) @Default(20) int limit,
  }) = _NotificationListModel;

  factory NotificationListModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationListModelFromJson(json);
}

String notificationTypeWireValue(NotificationTypeModel type) {
  return switch (type) {
    NotificationTypeModel.memberJoined => 'MEMBER_JOINED',
    NotificationTypeModel.contributionSubmitted => 'CONTRIBUTION_SUBMITTED',
    NotificationTypeModel.contributionConfirmed => 'CONTRIBUTION_CONFIRMED',
    NotificationTypeModel.contributionRejected => 'CONTRIBUTION_REJECTED',
    NotificationTypeModel.payoutConfirmed => 'PAYOUT_CONFIRMED',
    NotificationTypeModel.dueReminder => 'DUE_REMINDER',
    NotificationTypeModel.unknown => 'UNKNOWN',
  };
}

String notificationStatusWireValue(NotificationStatusModel status) {
  return switch (status) {
    NotificationStatusModel.unread => 'UNREAD',
    NotificationStatusModel.read => 'READ',
    NotificationStatusModel.unknown => 'UNKNOWN',
  };
}

Map<String, dynamic>? _mapFromJson(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  return null;
}

Map<String, dynamic>? _mapToJson(Map<String, dynamic>? value) => value;

int _toInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }

  return 0;
}

String? _asNonEmptyString(Object? value) {
  if (value is! String) {
    return null;
  }

  final normalized = value.trim();
  if (normalized.isEmpty) {
    return null;
  }

  return normalized;
}
