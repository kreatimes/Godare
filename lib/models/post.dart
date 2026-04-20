// Modelo que representa una publicacion en el feed de la app.
// Cuando un usuario completa un reto, se crea automaticamente un post
// visible para sus seguidores en el feed.
class Post {
  final String id;
  final String userId;
  final String userNick;
  final String? userImageUrl;
  final String postType;
  final String? textResponse; // Texto opcional que el usuario escribe al completar
  final String? mediaUrl;     // URL del video subido a Cloudinary
  final DateTime createdAt;
  final int likesCount;
  final int dislikesCount;
  final int commentsCount;
  final String? currentReaction; // Reaccion del usuario autenticado (LIKE, DISLIKE o null)

  const Post({
    required this.id,
    required this.userId,
    required this.userNick,
    this.userImageUrl,
    required this.postType,
    this.textResponse,
    this.mediaUrl,
    required this.createdAt,
    required this.likesCount,
    required this.dislikesCount,
    required this.commentsCount,
    this.currentReaction,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['userId'],
      userNick: json['userNick'] ?? '',
      userImageUrl: json['userImageUrl'],
      postType: json['postType'],
      textResponse: json['textResponse'],
      mediaUrl: json['mediaUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      likesCount: json['likesCount'] ?? 0,
      dislikesCount: json['dislikesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      currentReaction: json['currentReaction'],
    );
  }

  // Comprueba si el post corresponde a un reto completado
  bool get isDare => postType == 'DARE';
}

// Respuesta del feed con paginacion por cursor.
// Usamos cursor en lugar de pagina numerada para que el feed no salte
// si se publican nuevos posts mientras el usuario esta navegando.
class FeedResponse {
  final List<Post> posts;
  final String? nextCursorId;
  final String? nextCursorCreatedAt;
  final bool hasMore;

  const FeedResponse({
    required this.posts,
    this.nextCursorId,
    this.nextCursorCreatedAt,
    required this.hasMore,
  });

  factory FeedResponse.fromJson(Map<String, dynamic> json) {
    return FeedResponse(
      posts: (json['content'] as List<dynamic>? ?? [])
          .map((p) => Post.fromJson(p))
          .toList(),
      nextCursorId: json['nextCursorId'],
      nextCursorCreatedAt: json['nextCursorCreatedAt'],
      hasMore: json['hasMore'] ?? false,
    );
  }
}

// Respuesta que devuelve el servidor al reaccionar a un post (like/dislike).
// Devuelve los contadores actualizados para actualizar la UI sin recargar.
class PostReaction {
  final String message;
  final int likesCount;
  final int dislikesCount;
  final String currentReaction;

  const PostReaction({
    required this.message,
    required this.likesCount,
    required this.dislikesCount,
    required this.currentReaction,
  });

  factory PostReaction.fromJson(Map<String, dynamic> json) {
    return PostReaction(
      message: json['message'],
      likesCount: json['likesCount'] ?? 0,
      dislikesCount: json['dislikesCount'] ?? 0,
      currentReaction: json['currentReaction'] ?? 'NONE',
    );
  }
}

// Modelo de comentario en un post
class PostComment {
  final String id;
  final String postId;
  final String userId;
  final String userNick;
  final String? userImageUrl;
  final String commentText;
  final DateTime createdAt;

  const PostComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userNick,
    this.userImageUrl,
    required this.commentText,
    required this.createdAt,
  });

  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      id: json['id'],
      postId: json['postId'],
      userId: json['userId'],
      userNick: json['userNick'],
      userImageUrl: json['userImageUrl'],
      commentText: json['commentText'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
