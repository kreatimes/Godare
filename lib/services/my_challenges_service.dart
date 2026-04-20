import 'package:dio/dio.dart';
import 'package:godare/core/api_client.dart';
import 'package:godare/models/user_challenge.dart';

// Servicio que gestiona los retos del usuario autenticado.
// Se encarga de obtener, abrir, completar y transferir retos.
class MyChallengesService {

  // Devuelve la lista de retos del usuario.
  // El parametro state filtra por estado: OPEN, PASSED, EXPIRED, TRANSFERRED, CLOSED
  static Future<List<UserChallenge>> getMyChallenges({String? state}) async {
    try {
      final response = await ApiClient.instance.get(
        '/api/challenges/me',
        queryParameters: {
          if (state != null) 'state': state,
        },
      );
      return (response.data as List<dynamic>)
          .map((c) => UserChallenge.fromJson(c))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Convierte un DioException en una excepcion propia con mensaje legible
  static MyChallengesException _handleError(DioException e) {
    final message = e.response?.data?['message'] as String?;
    switch (e.response?.statusCode) {
      case 400:
        return MyChallengesException(message ?? 'Estado invalido');
      case 401:
        return MyChallengesException('Sesion expirada');
      default:
        return MyChallengesException('Error de conexion. Intentalo mas tarde.');
    }
  }

  // Completa un reto subiendo la URL del video grabado
  static Future<void> completeChallenge({
    required String id,
    required String fileUrl,
  }) async {
    try {
      await ApiClient.instance.post(
        '/api/complete/challenge/$id',
        data: {'fileUrl': fileUrl},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Abre un reto que estaba cerrado (CLOSED -> OPEN).
  // El reto pasa a CLOSED cuando llega pero el usuario no lo ha visto todavia.
  static Future<void> openChallenge({required String id}) async {
    try {
      await ApiClient.instance.patch('/api/challenges/$id/open');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Transfiere un reto a otro usuario.
  // Solo se puede transferir a usuarios a los que el usuario sigue.
  static Future<void> transferChallenge({
    required String challengeId,
    required String targetUserId,
  }) async {
    try {
      await ApiClient.instance.post(
        '/api/challenges/$challengeId/transfer/$targetUserId',
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}

// Excepcion que lanzamos cuando algo falla en las operaciones de retos.
// Usamos una clase propia para poder mostrar mensajes de error controlados en la UI.
class MyChallengesException implements Exception {
  final String message;
  const MyChallengesException(this.message);

  @override
  String toString() => message;
}
