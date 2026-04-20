import 'package:dio/dio.dart';
import 'package:godare/core/api_client.dart';

class ReportService {

  static Future<void> createReport({
    required String reportedId,
    required String type,
    required String reason,
    String? description,
  }) async {
    try {
      await ApiClient.instance.post(
        '/api/reports',
        data: {
          'reportedId': reportedId,
          'type': type,
          'reason': reason,
          'description': description,
        },
      );
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String?;
      throw ReportException(message ?? 'Error al enviar el reporte');
    }
  }
}

class ReportException implements Exception {
  final String message;
  const ReportException(this.message);

  @override
  String toString() => message;
}