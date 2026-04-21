import 'package:dio/dio.dart';
import 'package:godare/core/api_client.dart';
import 'package:godare/models/daily_item.dart';

/// Servicio para el reto diario
class DailyService {

  static Future<DailyItem> getMyDaily() async {
    try {
      final response = await ApiClient.instance.get('/api/daily/me');
      return DailyItem.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static DailyException _handleError(DioException e) {
    final statusCode = e.response?.statusCode;
    final message = e.response?.data?['message'] as String?;

    switch (statusCode) {
      case 404:
        return DailyException(message ?? 'No hay daily disponible');
      default:
        return DailyException('Error de conexión. Inténtalo más tarde.');
    }
  }
}

/// Excepción específica para errores del daily
class DailyException implements Exception {
  final String message;
  const DailyException(this.message);

  @override
  String toString() => message;
}