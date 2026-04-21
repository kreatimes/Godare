import 'package:dio/dio.dart';
import 'package:godare/core/api_client.dart';
import 'package:godare/models/pack_store.dart';

/// Servicio para la tienda de packs
class PackService {

  static Future<List<PackStore>> getAvailablePacks() async {
    try {
      final response = await ApiClient.instance.get('/api/packs');
      return (response.data as List<dynamic>)
          .map((p) => PackStore.fromJson(p))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<PackPurchaseResponse> buyPack(int packId) async {
    try {
      final response = await ApiClient.instance.post('/api/packs/$packId/buy');
      return PackPurchaseResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static PackException _handleError(DioException e) {
    final message = e.response?.data?['message'] as String?;
    switch (e.response?.statusCode) {
      case 400:
        return PackException(message ?? 'No tienes suficientes coins');
      case 404:
        return PackException(message ?? 'Pack no encontrado');
      default:
        return PackException('Error de conexión. Inténtalo más tarde.');
    }
  }
}

/// Excepción específica para errores de la tienda
class PackException implements Exception {
  final String message;
  const PackException(this.message);

  @override
  String toString() => message;
}