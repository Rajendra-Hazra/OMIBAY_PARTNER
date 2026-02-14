import '../core/network/api_client.dart';
import '../models/notification.dart';

class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository(this._apiClient);

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _apiClient.get('/notifications');
      final data = response.data as List;
      return data.map((e) => NotificationModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> markAsRead(String id) async {
    await _apiClient.put('/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _apiClient.put('/notifications/read-all');
  }

  Future<void> deleteNotification(String id) async {
    await _apiClient.delete('/notifications/$id');
  }
}
