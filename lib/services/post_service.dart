import 'package:dio/dio.dart';
import 'package:godare/core/api_client.dart';
import 'package:godare/models/post.dart';

/// Servicio para el feed de posts, reacciones y comentarios
class PostService {

  /// Feed global con paginación por cursor
  static Future<FeedResponse> getGlobalFeed({
    int limit = 10,
    String? cursorId,
    String? cursorCreatedAt,
  }) async {
    try {
      final response = await ApiClient.instance.get(
        '/api/posts/feed/global',
        queryParameters: {
          'limit': limit,
          if (cursorId != null) 'cursorId': cursorId,
          if (cursorCreatedAt != null) 'cursorCreatedAt': cursorCreatedAt,
        },
      );
      return FeedResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Feed de usuarios seguidos con paginación por cursor
  static Future<FeedResponse> getFollowingFeed({
    int limit = 10,
    String? cursorId,
    String? cursorCreatedAt,
  }) async {
    try {
      final response = await ApiClient.instance.get(
        '/api/posts/feed/following',
        queryParameters: {
          'limit': limit,
          if (cursorId != null) 'cursorId': cursorId,
          if (cursorCreatedAt != null) 'cursorCreatedAt': cursorCreatedAt,
        },
      );
      return FeedResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Posts de un usuario concreto con paginación por cursor
  static Future<FeedResponse> getUserPosts(
      String userId, {
        int limit = 10,
        String? cursorId,
        String? cursorCreatedAt,
      }) async {
    try {
      final response = await ApiClient.instance.get(
        '/api/users/$userId/posts',
        queryParameters: {
          'limit': limit,
          if (cursorId != null) 'cursorId': cursorId,
          if (cursorCreatedAt != null) 'cursorCreatedAt': cursorCreatedAt,
        },
      );
      return FeedResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Posts del usuario autenticado con paginación por cursor
  static Future<FeedResponse> getMyPosts({
    int limit = 10,
    String? cursorId,
    String? cursorCreatedAt,
  }) async {
    try {
      final response = await ApiClient.instance.get(
        '/api/users/me/posts',
        queryParameters: {
          'limit': limit,
          if (cursorId != null) 'cursorId': cursorId,
          if (cursorCreatedAt != null) 'cursorCreatedAt': cursorCreatedAt,
        },
      );
      return FeedResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Detalle completo de un post
  static Future<Post> getPostDetail(String postId) async {
    try {
      final response = await ApiClient.instance.get('/api/posts/$postId');
      return Post.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Da like a un post — si ya tenía like lo elimina (toggle)
  static Future<PostReaction> likePost(String postId) async {
    try {
      final response =
      await ApiClient.instance.post('/api/posts/$postId/like');
      return PostReaction.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Da dislike a un post — si ya tenía dislike lo elimina (toggle)
  static Future<PostReaction> dislikePost(String postId) async {
    try {
      final response =
      await ApiClient.instance.post('/api/posts/$postId/dislike');
      return PostReaction.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Devuelve los comentarios de un post
  static Future<List<PostComment>> getComments(String postId) async {
    try {
      final response =
      await ApiClient.instance.get('/api/posts/$postId/comments');
      return (response.data as List<dynamic>)
          .map((c) => PostComment.fromJson(c))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Añade un comentario a un post
  static Future<PostComment> addComment(
      String postId, String commentText) async {
    try {
      final response = await ApiClient.instance.post(
        '/api/posts/$postId/comments',
        data: {'commentText': commentText},
      );
      return PostComment.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Edita un comentario propio
  static Future<PostComment> updateComment(
      String commentId, String commentText) async {
    try {
      final response = await ApiClient.instance.put(
        '/api/posts/comments/$commentId',
        data: {'commentText': commentText},
      );
      return PostComment.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Elimina un comentario propio
  static Future<void> deleteComment(String commentId) async {
    try {
      await ApiClient.instance.delete('/api/posts/comments/$commentId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static PostException _handleError(DioException e) {
    final statusCode = e.response?.statusCode;
    final message = e.response?.data?['message'] as String?;

    switch (statusCode) {
      case 400:
        return PostException(message ?? 'Solicitud incorrecta');
      case 404:
        return PostException(message ?? 'Post no encontrado');
      default:
        return PostException('Error de conexión. Inténtalo más tarde.');
    }
  }
}

/// Excepción específica para errores de posts
class PostException implements Exception {
  final String message;
  const PostException(this.message);

  @override
  String toString() => message;
}