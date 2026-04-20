import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:godare/models/post.dart';
import 'package:godare/providers/user_provider.dart';
import 'package:godare/services/post_service.dart';
import 'package:godare/values/colors_app.dart';
import 'package:godare/widgets/basics/post_card.dart';

/// Pantalla de detalle de un post con sus comentarios.
class PostDetailPage extends StatefulWidget {
  final String postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  Post? _post;
  List<PostComment> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _editingCommentId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        PostService.getPostDetail(widget.postId),
        PostService.getComments(widget.postId),
      ]);
      if (!mounted) return;
      setState(() {
        _post = results[0] as Post;
        _comments = results[1] as List<PostComment>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);

    try {
      if (_editingCommentId != null) {
        // Editar comentario existente
        final updated = await PostService.updateComment(
          _editingCommentId!,
          text,
        );
        setState(() {
          final index =
          _comments.indexWhere((c) => c.id == _editingCommentId);
          if (index != -1) _comments[index] = updated;
          _editingCommentId = null;
        });
      } else {
        // Nuevo comentario
        final newComment = await PostService.addComment(
          widget.postId,
          text,
        );
        setState(() => _comments.add(newComment));

        // Scroll al final para ver el nuevo comentario
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }

      _commentController.clear();
      _focusNode.unfocus();
    } on PostException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar comentario'),
        content: const Text('¿Seguro que quieres eliminar este comentario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await PostService.deleteComment(commentId);
      setState(() => _comments.removeWhere((c) => c.id == commentId));
    } on PostException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  void _startEdit(PostComment comment) {
    setState(() {
      _editingCommentId = comment.id;
      _commentController.text = comment.commentText;
    });
    _focusNode.requestFocus();
  }

  void _cancelEdit() {
    setState(() {
      _editingCommentId = null;
      _commentController.clear();
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorsApp.baseBlackLogo,
        iconTheme: const IconThemeData(color: ColorsApp.basePink),
        title: const Text(
          'Comentarios',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _post == null
          ? const Center(child: Text('No se pudo cargar el post'))
          : Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              children: [
                // Post completo arriba
                PostCard(post: _post!),

                // Separador
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      const Text(
                        'COMENTARIOS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${_comments.length})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // Lista de comentarios
                if (_comments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'Sé el primero en comentar',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ..._comments.map(
                        (comment) => _buildCommentTile(comment),
                  ),

                const SizedBox(height: 16),
              ],
            ),
          ),

          // Input de comentario
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildCommentTile(PostComment comment) {
    final myId = context.read<UserProvider>().profile?.id;
    final isOwn = comment.userId == myId;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 16,
            backgroundImage: comment.userImageUrl != null
                ? NetworkImage(comment.userImageUrl!)
                : const AssetImage('assets/images/default_profile.png')
            as ImageProvider,
          ),
          const SizedBox(width: 10),

          // Contenido
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nick y fecha
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        comment.userNick,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        _formatDate(comment.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Texto del comentario
                  Text(
                    comment.commentText,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          // Opciones editar/borrar — solo en comentarios propios
          if (isOwn) ...[
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
              onSelected: (value) {
                if (value == 'edit') _startEdit(comment);
                if (value == 'delete') _deleteComment(comment.id);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Banner de edición
          if (_editingCommentId != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.edit, size: 14, color: Colors.orange),
                  const SizedBox(width: 6),
                  const Text(
                    'Editando comentario',
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _cancelEdit,
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  focusNode: _focusNode,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Escribe un comentario...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _isSending
                  ? const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : IconButton(
                onPressed: _sendComment,
                icon: const Icon(
                  Icons.send_rounded,
                  color: ColorsApp.basePink,
                ),
              ),
            ],
          ),
        ],
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