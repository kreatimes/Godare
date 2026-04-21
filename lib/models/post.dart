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

  // Veredicto de la comunidad: ¿el reto fue realmente superado?
  final int approvedCount;
  final int notApprovedCount;
  final String? currentVerdict; // APPROVED, NOT_APPROVED o null

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
    this.approvedCount = 0,
    this.notApprovedCount = 0,
    this.currentVerdict,
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
      approvedCount: json['approvedCount'] ?? 0,
      notApprovedCount: json['notApprovedCount'] ?? 0,
      currentVerdict: json['currentVerdict'],
    );
  }

  // true si es un dare
  bool get isDare => postType == 'DARE';
}

// Respuesta del feed paginada por cursor
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

// Respuesta de reaccion a un post
class PostReaction {
  final String message;
  final int likesCount;
  final int dislikesCount;
  final String currentReaction;
  final int approvedCount;
  final int notApprovedCount;
  final String currentVerdict;

  const PostReaction({
    required this.message,
    required this.likesCount,
    required this.dislikesCount,
    required this.currentReaction,
    this.approvedCount = 0,
    this.notApprovedCount = 0,
    this.currentVerdict = 'NONE',
  });

  factory PostReaction.fromJson(Map<String, dynamic> json) {
    return PostReaction(
      message: json['message'],
      likesCount: json['likesCount'] ?? 0,
      dislikesCount: json['dislikesCount'] ?? 0,
      currentReaction: json['currentReaction'] ?? 'NONE',
      approvedCount: json['approvedCount'] ?? 0,
      notApprovedCount: json['notApprovedCount'] ?? 0,
      currentVerdict: json['currentVerdict'] ?? 'NONE',
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
  final int likesCount;
  final int dislikesCount;
  final String? currentReaction;

  const PostComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userNick,
    this.userImageUrl,
    required this.commentText,
    required this.createdAt,
    this.likesCount = 0,
    this.dislikesCount = 0,
    this.currentReaction,
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
      likesCount: json['likesCount'] ?? 0,
      dislikesCount: json['dislikesCount'] ?? 0,
      currentReaction: json['currentReaction'],
    );
  }
}