import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Almacenamiento seguro del JWT
class SecureStorage {
  static const _storage = FlutterSecureStorage();
  static const _keyToken = 'jwt_token';

  /// Guarda el token JWT
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  /// Recupera el token JWT, null si no existe
  static Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  /// Elimina el token (logout)
  static Future<void> clearToken() async {
    await _storage.delete(key: _keyToken);
  }

  /// Comprueba si hay sesión activa
  static Future<bool> hasToken() async {
    final token = await _storage.read(key: _keyToken);
    return token != null && token.isNotEmpty;
  }
}