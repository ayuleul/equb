import '../api/api_client.dart';
import '../models/notification_model.dart';

abstract class NotificationsApi {
  Future<Map<String, dynamic>> listNotifications({
    NotificationStatusModel? status,
    int offset,
    int limit,
  });

  Future<Map<String, dynamic>> markRead(String notificationId);
}

class DioNotificationsApi implements NotificationsApi {
  DioNotificationsApi(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Map<String, dynamic>> listNotifications({
    NotificationStatusModel? status,
    int offset = 0,
    int limit = 20,
  }) {
    final query = <String, dynamic>{
      'offset': offset,
      'limit': limit,
      if (status != null) 'status': notificationStatusWireValue(status),
    };

    return _apiClient.getMap('/notifications', queryParameters: query);
  }

  @override
  Future<Map<String, dynamic>> markRead(String notificationId) {
    return _apiClient.patchMap('/notifications/$notificationId/read');
  }
}
