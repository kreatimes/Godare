import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:godare/common/my_routers.dart';
import 'package:godare/models/user.dart';
import 'package:godare/providers/user_provider.dart';
import 'package:godare/services/user_service.dart';
import 'package:godare/values/colors_app.dart';

/// Tarjeta de usuario en listas de seguidores/seguidos.
/// Muestra avatar, nick y botón de seguir/dejar de seguir.
/// Al pulsar navega al perfil del usuario.
class UserElement extends StatefulWidget {
  final FollowUser user;

  const UserElement({super.key, required this.user});

  @override
  State<UserElement> createState() => _UserElementState();
}

class _UserElementState extends State<UserElement> {
  bool _isLoading = false;

  Future<void> _toggleFollow(bool isFollowing) async {
    setState(() => _isLoading = true);
    try {
      if (isFollowing) {
        await UserService.unfollowUser(widget.user.id);
      } else {
        await UserService.followUser(widget.user.id);
      }
      if (!context.mounted) return;
      await context.read<UserProvider>().loadProfile();
    } on UserException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final myProfile = context.watch<UserProvider>().profile;
    final isMe = myProfile?.id == widget.user.id;
    final isFollowing = myProfile?.isFollowing(widget.user.id) ?? false;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        ROUTE_USER_PROFILE,
        arguments: widget.user.id,
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.black, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundImage: widget.user.userImageUrl != null
                    ? NetworkImage(widget.user.userImageUrl!)
                    : const NetworkImage(
                  'https://res.cloudinary.com/dfeqlfptc/image/upload/v1774389485/default_profile_k6ojop.png',
                ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.nick,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    if (widget.user.name != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${widget.user.name}'
                            '${widget.user.surnames != null ? ' ${widget.user.surnames}' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Botón seguir — oculto si es el propio usuario
              if (!isMe)
                _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : TextButton(
                  onPressed: () => _toggleFollow(isFollowing),
                  style: TextButton.styleFrom(
                    foregroundColor:
                    isFollowing ? Colors.grey : ColorsApp.basePink,
                  ),
                  child: Text(isFollowing ? 'Siguiendo' : 'Seguir'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}