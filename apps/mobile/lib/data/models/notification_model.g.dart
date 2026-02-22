// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    _NotificationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      groupId: json['groupId'] as String?,
      type: $enumDecode(
        _$NotificationTypeModelEnumMap,
        json['type'],
        unknownValue: NotificationTypeModel.unknown,
      ),
      title: json['title'] as String,
      body: json['body'] as String,
      dataJson: _mapFromJson(json['dataJson']),
      status: $enumDecode(
        _$NotificationStatusModelEnumMap,
        json['status'],
        unknownValue: NotificationStatusModel.unknown,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
    );

Map<String, dynamic> _$NotificationModelToJson(_NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'groupId': instance.groupId,
      'type': _$NotificationTypeModelEnumMap[instance.type]!,
      'title': instance.title,
      'body': instance.body,
      'dataJson': _mapToJson(instance.dataJson),
      'status': _$NotificationStatusModelEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'readAt': instance.readAt?.toIso8601String(),
    };

const _$NotificationTypeModelEnumMap = {
  NotificationTypeModel.memberJoined: 'MEMBER_JOINED',
  NotificationTypeModel.contributionSubmitted: 'CONTRIBUTION_SUBMITTED',
  NotificationTypeModel.contributionConfirmed: 'CONTRIBUTION_CONFIRMED',
  NotificationTypeModel.contributionRejected: 'CONTRIBUTION_REJECTED',
  NotificationTypeModel.payoutConfirmed: 'PAYOUT_CONFIRMED',
  NotificationTypeModel.dueReminder: 'DUE_REMINDER',
  NotificationTypeModel.lotteryWinner: 'LOTTERY_WINNER',
  NotificationTypeModel.lotteryAnnouncement: 'LOTTERY_ANNOUNCEMENT',
  NotificationTypeModel.unknown: 'unknown',
};

const _$NotificationStatusModelEnumMap = {
  NotificationStatusModel.unread: 'UNREAD',
  NotificationStatusModel.read: 'READ',
  NotificationStatusModel.unknown: 'unknown',
};

_NotificationListModel _$NotificationListModelFromJson(
  Map<String, dynamic> json,
) => _NotificationListModel(
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <NotificationModel>[],
  total: json['total'] == null ? 0 : _toInt(json['total']),
  offset: json['offset'] == null ? 0 : _toInt(json['offset']),
  limit: json['limit'] == null ? 20 : _toInt(json['limit']),
);

Map<String, dynamic> _$NotificationListModelToJson(
  _NotificationListModel instance,
) => <String, dynamic>{
  'items': instance.items,
  'total': instance.total,
  'offset': instance.offset,
  'limit': instance.limit,
};
