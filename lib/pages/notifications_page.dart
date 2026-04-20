import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:godare/common/my_routers.dart';
import 'package:godare/models/notification.dart';
import 'package:godare/providers/user_provider.dart';
import 'package:godare/services/notification_service.dart';
import 'package:godare/values/colors_app.dart';

/// Pantalla de notificaciones del usuario autenticado.
/// Muestra todas las notificaciones ordenadas de más reciente a más antigua.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    try {
      final notifications = await NotificationService.getMyNotifications();
      if (!mounted) return;
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await NotificationService.markAllAsRead();
      context.read<UserProvider>().clearUnreadNotifications();
      await _fetchNotifications();
    } catch (_) {}
  }

  Future<void> _markAsRead(AppNotification notification) async {
    if (notification.read) return;
    try {
      await NotificationService.markAsRead(notification.id);
      context.read<UserProvider>().decrementUnreadNotifications();
      await _fetchNotifications();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorsApp.baseBlackLogo,
        iconTheme: const IconThemeData(color: ColorsApp.basePink),
        title: const Text(
          'Notificaciones',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          if (_notifications.any((n) => !n.read))
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Leer todas',
                style: TextStyle(color: ColorsApp.basePink),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? const Center(child: Text('No tienes notificaciones'))
          : RefreshIndicator(
        onRefresh: _fetchNotifications,
        child: ListView.builder(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          itemCount: _notifications.length,
          itemBuilder: (context, index) =>
              _NotificationTile(
                notification: _notifications[index],
                onTap: () => _markAsRead(_notifications[index]),
              ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
        _handleNavigation(context);
      },
      child: Container(
        color: notification.read ? null : ColorsApp.basePink.withOpacity(0.05),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono según tipo
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _iconColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, color: _iconColor, size: 22),
            ),
            const SizedBox(width: 12),

            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.read
                          ? FontWeight.normal
                          : FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(notification.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),

            // Punto de no leído
            if (!notification.read)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                  color: ColorsApp.basePink,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Navega a la pantalla relevante según el tipo de notificación
  void _handleNavigation(BuildContext context) {
    final data = notification.data;

    switch (notification.type) {
      case 'LIKE_RECEIVED':
      case 'COMMENT_RECEIVED':
      // Ambas llevan al post donde ocurrió la interacción
        final postId = data?['postId'] as String?;
        if (postId != null) {
          Navigator.pushNamed(context, ROUTE_POST_DETAIL, arguments: postId);
        }
        break;

      case 'FOLLOW':
      // Lleva al perfil del usuario que nos ha seguido
        final fromUserId = data?['fromUserId'] as String?;
        if (fromUserId != null) {
          Navigator.pushNamed(
              context, ROUTE_USER_PROFILE, arguments: fromUserId);
        }
        break;

      case 'CHALLENGE_TRANSFERRED':
      // Lleva a la pantalla principal donde están los retos pendientes
        Navigator.pushNamedAndRemoveUntil(
            context, ROUTE_HOME, (route) => false);
        break;

      case 'RANGE_UP':
      // Lleva al perfil propio para ver el nuevo rango
        Navigator.pushNamed(context, ROUTE_USER_PROFILE);
        break;
    }
  }

  IconData get _icon {
    switch (notification.type) {
      case 'FOLLOW':
        return Icons.person_add;
      case 'LIKE_RECEIVED':
        return Icons.favorite;
      case 'COMMENT_RECEIVED':
        return Icons.chat_bubble;
      case 'CHALLENGE_TRANSFERRED':
        return Icons.swap_horiz;
      case 'RANGE_UP':
        return Icons.star;
      default:
        return Icons.notifications;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case 'FOLLOW':
        return Colors.blue;
      case 'LIKE_RECEIVED':
        return Colors.red;
      case 'COMMENT_RECEIVED':
        return Colors.orange;
      case 'CHALLENGE_TRANSFERRED':
        return Colors.deepPurple;
      case 'RANGE_UP':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Ahora mismo';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} d';
    return '${date.day}/${date.month}/${date.year}';
  }
}