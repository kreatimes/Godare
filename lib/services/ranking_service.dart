import 'package:dio/dio.dart';
import 'package:godare/core/api_client.dart';
import 'package:godare/models/ranking.dart';

/// Servicio para los rankings global y de seguidos
class RankingService {

  static Future<List<RankingEntry>> getGlobalRanking() async {
    try {
      final response = await ApiClient.instance.get('/api/ranking/global');
      return (response.data as List<dynamic>)
          .map((e) => RankingEntry.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<RankingEntry>> getFollowingRanking() async {
    try {
      final response = await ApiClient.instance.get('/api/ranking/following');
      return (response.data as List<dynamic>)
          .map((e) => RankingEntry.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static RankingException _handleError(DioException e) {
    final message = e.response?.data?['message'] as String?;
    return RankingException(
        message ?? 'Error de conexión. Inténtalo más tarde.');
  }
}

/// Excepción específica para errores de ranking
class RankingException implements Exception {
  final String message;
  const RankingException(this.message);

  @override
  String toString() => message;
}