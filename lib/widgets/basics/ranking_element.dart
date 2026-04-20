import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:godare/models/ranking.dart';
import 'package:godare/providers/user_provider.dart';
import 'package:godare/services/user_service.dart';
import 'package:godare/values/colors_app.dart';
import 'package:godare/common/my_routers.dart';

/// Tarjeta de un usuario en el ranking.
/// Muestra posición, avatar, nick, rango, puntos y botón de seguir/dejar de seguir.
/// Al pulsar la tarjeta navega al perfil del usuario.
class RankingElement extends StatefulWidget {
  final RankingEntry entry;

  const RankingElement({super.key, required this.entry});

  @override
  State<RankingElement> createState() => _RankingElementState();
}

class _RankingElementState extends State<RankingElement> {
  bool _isLoading = false;

  Future<void> _toggleFollow(BuildContext context, bool isFollowing) async {
    setState(() => _isLoading = true);
    try {
      if (isFollowing) {
        await UserService.unfollowUser(widget.entry.userId);
      } else {
        await UserService.followUser(widget.entry.userId);
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
    final isMe = myProfile?.id == widget.entry.userId;
    final isFollowing = myProfile?.isFollowing(widget.entry.userId) ?? false;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        ROUTE_USER_PROFILE,
        arguments: widget.entry.userId,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: isMe ? Border.all(color: ColorsApp.basePink, width: 1.6) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Posición
              _buildPosition(widget.entry.position),
              const SizedBox(width: 14),

              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundImage: widget.entry.userImageUrl != null
                    ? NetworkImage(widget.entry.userImageUrl!)
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
                      widget.entry.nick,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.entry.rangeName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.entry.points} pts',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ColorsApp.basePink,
                      ),
                    ),
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
                  onPressed: () => _toggleFollow(context, isFollowing),
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

  /// Medalla para top 3, número para el resto
  Widget _buildPosition(int position) {
    if (position <= 3) {
      final medals = {
        1: 'assets/images/icon_rankingFirst.png',
        2: 'assets/images/icon_rankingSecond.png',
        3: 'assets/images/icon_rankingThird.png',
      };
      return SizedBox(
        width: 43,
        height: 43,
        child: Image.asset(medals[position]!),
      );
    }
    return SizedBox(
      width: 43,
      child: Text(
        '$position.',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}