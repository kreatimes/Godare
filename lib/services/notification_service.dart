import 'package:dio/dio.dart';
import 'package:godare/core/api_client.dart';
import 'package:godare/models/notification.dart';

/// Servicio para las notificaciones del usuario autenticado
class NotificationService {

  static Future<List<AppNotification>> getMyNotifications() async {
    try {
      final response =
      await ApiClient.instance.get('/api/notifications/me');
      return (response.data as List<dynamic>)
          .map((n) => AppNotification.fromJson(n))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<int> getUnreadCount() async {
    try {
      final response =
      await ApiClient.instance.get('/api/notifications/me/unread-count');
      return response.data['unreadCount'] as int? ?? 0;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<AppNotification> markAsRead(String notificationId) async {
    try {
      final response = await ApiClient.instance
          .patch('/api/notifications/$notificationId/read');
      return AppNotification.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<void> markAllAsRead() async {
    try {
      await ApiClient.instance.patch('/api/notifications/me/read-all');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static NotificationException _handleError(DioException e) {
    final message = e.response?.data?['message'] as String?;
    return NotificationException(
        message ?? 'Error de conexión. Inténtalo más tarde.');
  }
}

/// Excepción específica para errores de notificaciones
class NotificationException implements Exception {
  final String message;
  const NotificationException(this.message);

  @override
  String toString() => message;
}