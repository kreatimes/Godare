import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../core/api_client.dart';

/// Servicio para subir archivos a Cloudinary.
/// Usa upload sin firma (unsigned) con un preset público.
/// Configurar en Cloudinary: Settings → Upload → Upload presets → Unsigned
class CloudinaryService {

  // TODO: sustituir por tus credenciales de Cloudinary
  static String get _cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static String get _uploadPreset => dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

  static final Dio _dio = Dio();

  static Future<String> uploadFile(File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        'upload_preset': _uploadPreset,
        'resource_type': 'auto', // detecta automáticamente vídeo o imagen
      });

      final response = await _dio.post(
        'https://api.cloudinary.com/v1_1/$_cloudName/auto/upload',
        data: formData,
      );

      final url = response.data['secure_url'] as String?;
      if (url == null) throw Exception('No se recibió URL de Cloudinary');

      return url;
    } on DioException catch (e) {
      throw CloudinaryException(
        e.response?.data?['error']?['message'] ?? 'Error al subir el archivo',
      );
    }
  }

  static Future<String> uploadProfileImage(File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        'upload_preset': _uploadPreset,
        'resource_type': 'image',
        'folder': 'profile_images', // carpeta en Cloudinary
      });

      final response = await _dio.post(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
        data: formData,
      );

      final url = response.data['secure_url'] as String?;
      if (url == null) throw Exception('No se recibió URL de Cloudinary');

      return url;
    } on DioException catch (e) {
      throw CloudinaryException(
        e.response?.data?['error']?['message'] ?? 'Error al subir la imagen',
      );
    }
  }

  static Future<void> deleteProfileImage(String imageUrl) async {
    const defaultUrl =
        'https://res.cloudinary.com/dfeqlfptc/image/upload/v1774389485/default_profile_k6ojop.png';
    if (imageUrl == defaultUrl) return;

    try {
      await ApiClient.instance.delete(
        '/api/users/me/profile-image',
        queryParameters: {'imageUrl': imageUrl},
      );
    } catch (e) {
      // Error no crítico — la imagen queda huérfana pero no bloqueamos el flujo
      print('Error borrando imagen anterior: $e');
    }
  }
}

/// Excepción específica para errores de Cloudinary
class CloudinaryException implements Exception {
  final String message;
  const CloudinaryException(this.message);

  @override
  String toString() => message;
}