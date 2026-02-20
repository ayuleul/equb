import '../models/notification_model.dart';
import 'notifications_api.dart';

class NotificationsRepository {
  NotificationsRepository(this._api);

  final NotificationsApi _api;

  Future<NotificationListModel> listNotifications({
    NotificationStatusModel? status,
    int offset = 0,
    int limit = 20,
  }) async {
    final payload = await _api.listNotifications(
      status: status,
      offset: offset,
      limit: limit,
    );
    return NotificationListModel.fromJson(payload);
  }

  Future<NotificationModel> markRead(String notificationId) async {
    final payload = await _api.markRead(notificationId);
    return NotificationModel.fromJson(payload);
  }
}
