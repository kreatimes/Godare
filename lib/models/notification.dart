/// Notificación recibida por el usuario
class AppNotification {
  final String id;
  final String type; // FOLLOW, LIKE_RECEIVED, COMMENT_RECEIVED, RANGE_UP, etc.
  final String title;
  final String message;
  final bool read;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.read,
    required this.createdAt,
    this.data,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      message: json['message'],
      read: json['read'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      data: json['data'] != null
          ? Map<String, dynamic>.from(json['data'])
          : null,
    );
  }
}