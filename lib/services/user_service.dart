import 'package:dio/dio.dart';
import 'package:godare/core/api_client.dart';
import 'package:godare/models/user.dart';

/// Servicio para gestión de usuarios, perfil y sistema social (follows)
class UserService {

  /// Devuelve el perfil completo del usuario autenticado
  static Future<MyProfile> getMyProfile() async {
    try {
      final response = await ApiClient.instance.get('/api/users/me');
      return MyProfile.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Devuelve el perfil público de cualquier usuario por su ID
  static Future<UserProfile> getUserProfile(String userId) async {
    try {
      final response = await ApiClient.instance.get('/api/users/$userId');
      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Actualiza los datos del perfil del usuario autenticado.
  /// Solo envía los campos que vienen informados.
  static Future<MyProfile> updateMyProfile({
    String? nick,
    String? name,
    String? surnames,
    String? userImageUrl,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (nick != null) data['nick'] = nick;
      if (name != null) data['name'] = name;
      if (surnames != null) data['surnames'] = surnames;
      if (userImageUrl != null) data['userImageUrl'] = userImageUrl;

      final response = await ApiClient.instance.patch(
        '/api/users/me',
        data: data,
      );
      return MyProfile.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Devuelve la lista de seguidores de un usuario
  static Future<List<FollowUser>> getFollowers(String userId) async {
    try {
      final response =
      await ApiClient.instance.get('/api/users/$userId/followers');
      return (response.data as List<dynamic>)
          .map((u) => FollowUser.fromJson(u))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Devuelve la lista de usuarios a los que sigue un usuario
  static Future<List<FollowUser>> getFollowing(String userId) async {
    try {
      final response =
      await ApiClient.instance.get('/api/users/$userId/following');
      return (response.data as List<dynamic>)
          .map((u) => FollowUser.fromJson(u))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Sigue a un usuario por su ID
  static Future<void> followUser(String userId) async {
    try {
      await ApiClient.instance.post('/api/users/$userId/follow');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Deja de seguir a un usuario por su ID
  static Future<void> unfollowUser(String userId) async {
    try {
      await ApiClient.instance.delete('/api/users/$userId/follow');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Busca usuarios por nick — mínimo 2 caracteres
  static Future<List<FollowUser>> searchUsers(String query) async {
    try {
      final response = await ApiClient.instance.get(
        '/api/users/search',
        queryParameters: {'q': query},
      );
      return (response.data as List<dynamic>)
          .map((u) => FollowUser.fromJson(u))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Elimina la cuenta del usuario autenticado y todos sus datos
  static Future<void> deleteAccount() async {
    try {
      await ApiClient.instance.delete('/api/users/me');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static UserException _handleError(DioException e) {
    final statusCode = e.response?.statusCode;
    final message = e.response?.data?['message'] as String?;

    switch (statusCode) {
      case 400:
        return UserException(message ?? 'Solicitud incorrecta');
      case 404:
        return UserException(message ?? 'Usuario no encontrado');
      default:
        return UserException('Error de conexión. Inténtalo más tarde.');
    }
  }
}

/// Excepción específica para errores de usuario
class UserException implements Exception {
  final String message;
  const UserException(this.message);

  @override
  String toString() => message;
}