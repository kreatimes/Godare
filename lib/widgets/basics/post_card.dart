import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:godare/common/my_routers.dart';
import 'package:godare/models/post.dart';
import 'package:godare/services/post_service.dart';
import 'package:godare/values/colors_app.dart';
import 'package:godare/widgets/basics/report_modal.dart';
import 'package:godare/widgets/basics/video_player_screen.dart';
import 'package:godare/services/report_service.dart';

// Tarjeta de post que aparece en el feed.
// Muestra el video del reto completado junto con likes, dislikes y comentarios.
class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late int _likesCount;
  late int _dislikesCount;
  late String _currentReaction;

  @override
  void initState() {
    super.initState();
    // Inicializamos los contadores locales para poder actualizar la UI
    // sin esperar a recargar el post completo del servidor
    _likesCount = widget.post.likesCount;
    _dislikesCount = widget.post.dislikesCount;
    _currentReaction = widget.post.currentReaction ?? 'NONE';
  }

  Future<void> _handleLike() async {
    try {
      final reaction = await PostService.likePost(widget.post.id);
      if (!mounted) return;
      setState(() {
        _likesCount = reaction.likesCount;
        _dislikesCount = reaction.dislikesCount;
        _currentReaction = reaction.currentReaction;
      });
    } catch (_) {}
  }

  Future<void> _handleDislike() async {
    try {
      final reaction = await PostService.dislikePost(widget.post.id);
      if (!mounted) return;
      setState(() {
        _likesCount = reaction.likesCount;
        _dislikesCount = reaction.dislikesCount;
        _currentReaction = reaction.currentReaction;
      });
    } catch (_) {}
  }

  // Comparte el post con otras apps usando el paquete share_plus
  void _handleShare() {
    final text = 'Mira este reto que he completado en GoDare!\n'
        '${widget.post.mediaUrl ?? ''}';
    Share.share(text, subject: 'GoDare');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildMedia(),
          _buildActions(),
          _buildFooter(),
        ],
      ),
    );
  }

  // Cabecera con avatar y nick — al pulsar navega al perfil del usuario
  Widget _buildHeader(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        ROUTE_USER_PROFILE,
        arguments: widget.post.userId,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: widget.post.userImageUrl != null
                  ? NetworkImage(widget.post.userImageUrl!)
                  : const AssetImage('assets/images/default_profile.png')
                      as ImageProvider,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.post.userNick,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            _buildTypeBadge(),
          ],
        ),
      ),
    );
  }

  // Badge que identifica el post como un reto fitness
  Widget _buildTypeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: ColorsApp.basePink,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'RETO',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Muestra el texto del reto y el video grabado por el usuario
  Widget _buildMedia() {
    final hasMedia = widget.post.mediaUrl != null &&
        widget.post.mediaUrl!.isNotEmpty;

    final isVideo = hasMedia &&
        (widget.post.mediaUrl!.contains('.mp4') ||
            widget.post.mediaUrl!.contains('.mov') ||
            widget.post.mediaUrl!.contains('.avi'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Texto del reto que completo el usuario — siempre visible
        if (widget.post.textResponse != null &&
            widget.post.textResponse!.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            color: ColorsApp.basePink.withOpacity(0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.textResponse!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorsApp.basePink.withOpacity(0.9),
                  ),
                ),
                if (hasMedia) ...[
                  const SizedBox(height: 10),
                  const Divider(
                      height: 1, thickness: 0.5, color: ColorsApp.basePink),
                ],
              ],
            ),
          ),

        // Video o imagen adjunta al post
        if (hasMedia)
          isVideo
              ? SizedBox(
                  height: 400,
                  width: double.infinity,
                  child: VideoPlayerScreen(videoUrl: widget.post.mediaUrl!),
                )
              : SizedBox(
                  height: 400,
                  width: double.infinity,
                  child: Image.network(
                    widget.post.mediaUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.broken_image,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
      ],
    );
  }

  // Barra de acciones: like, dislike, comentarios, reportar y compartir
  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // Like
          IconButton(
            onPressed: _handleLike,
            icon: Icon(
              _currentReaction == 'LIKE'
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: _currentReaction == 'LIKE' ? Colors.red : Colors.black,
            ),
          ),
          Text('$_likesCount', style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 4),

          // Dislike
          IconButton(
            onPressed: _handleDislike,
            icon: Icon(
              _currentReaction == 'DISLIKE'
                  ? Icons.thumb_down
                  : Icons.thumb_down_outlined,
              color:
                  _currentReaction == 'DISLIKE' ? Colors.blue : Colors.black,
            ),
          ),
          Text('$_dislikesCount', style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 4),

          // Comentarios — abre el detalle del post
          GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              ROUTE_POST_DETAIL,
              arguments: widget.post.id,
            ),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_outline, color: Colors.black),
                const SizedBox(width: 4),
                Text(
                  '${widget.post.commentsCount}',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Reportar contenido inapropiado
          IconButton(
            onPressed: () => _showReportModal(context),
            icon: Icon(Icons.flag_outlined,
                color: Colors.grey.shade400, size: 20),
          ),

          // Compartir en otras apps
          IconButton(
            onPressed: _handleShare,
            icon: const Icon(Icons.share_outlined, color: Colors.black),
          ),
        ],
      ),
    );
  }

  void _showReportModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ReportModal(
        reportedId: widget.post.id,
        type: 'POST',
      ),
    );
  }

  // Muestra la fecha del post en formato relativo (hace X min/h/d)
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Text(
        _formatDate(widget.post.createdAt),
        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
      ),
    );
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
