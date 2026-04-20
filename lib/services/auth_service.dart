import 'package:dio/dio.dart';
import 'package:godare/core/api_client.dart';
import 'package:godare/core/secure_storage.dart';
import 'package:godare/models/auth.dart';

/// Servicio de autenticación — registro, login, verificación y contraseña
class AuthService {

  /// Registra un nuevo usuario.
  static Future<void> register(RegisterRequest request) async {
    try {
      await ApiClient.instance.post(
        '/api/auth/register',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Inicia sesión con email o nick + contraseña.
  static Future<JwtResponse> login(LoginRequest request) async {
    try {
      final response = await ApiClient.instance.post(
        '/api/auth/login',
        data: request.toJson(),
      );

      final jwt = JwtResponse.fromJson(response.data);
      await SecureStorage.saveToken(jwt.token);
      return jwt;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Verifica la cuenta con el token recibido por email.
  static Future<void> verifyAccount(String token) async {
    try {
      await ApiClient.instance.get(
        '/api/auth/verify',
        queryParameters: {'token': token},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Solicita el envío del email de recuperación de contraseña.
  static Future<void> forgotPassword(ForgotPasswordRequest request) async {
    try {
      await ApiClient.instance.post(
        '/api/auth/forgot-password',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Resetea la contraseña usando el token del email.
  static Future<void> resetPassword(ResetPasswordRequest request) async {
    try {
      await ApiClient.instance.post(
        '/api/auth/reset-password',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Verifica la contraseña del usuario autenticado
  static Future<bool> verifyPassword(String password) async {
    try {
      final response = await ApiClient.instance.post(
        '/api/auth/verify-password',
        data: {'password': password},
      );
      return response.data == true;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Cambia la contraseña del usuario autenticado
  static Future<void> changePassword(ChangePasswordRequest request) async {
    try {
      await ApiClient.instance.patch(
        '/api/auth/change-password',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Cierra sesión
  static Future<void> logout() async {
    await SecureStorage.clearToken();
    ApiClient.reset();
  }

  static AuthException _handleError(DioException e) {
    final statusCode = e.response?.statusCode;
    final message = e.response?.data?['message'] as String?;

    // Error especial — email no verificado, back reenvió el email
    if (statusCode == 401 && message != null &&
        message.startsWith('EMAIL_NOT_VERIFIED:')) {
      final emailOfuscado = message.replaceFirst('EMAIL_NOT_VERIFIED:', '');
      return EmailNotVerifiedException(emailOfuscado);
    }

    switch (statusCode) {
      case 400:
        return AuthException(message ?? 'Datos incorrectos');
      case 401:
        return AuthException(message ?? 'Email o contraseña incorrectos');
      case 409:
        return AuthException(message ?? 'El email o nick ya está registrado');
      default:
        return AuthException('Error de conexión. Inténtalo más tarde.');
    }
  }
}

/// Excepción general de autenticación
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Excepción específica para email no verificado — incluye el email ofuscado
class EmailNotVerifiedException extends AuthException {
  final String emailOfuscado;
  const EmailNotVerifiedException(this.emailOfuscado)
      : super('Email no verificado');
}
