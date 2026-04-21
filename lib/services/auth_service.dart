import 'package:dio/dio.dart';
import 'package:godare/core/api_client.dart';
import 'package:godare/core/secure_storage.dart';
import 'package:godare/models/auth.dart';

/// Servicio de autenticación — registro, login, verificación y contraseña
class AuthService {

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

  static Future<String> resendVerification(String email) async {
    try {
      final response = await ApiClient.instance.post(
        '/api/auth/resend-verification',
        data: {'email': email.trim().toLowerCase()},
      );
      return response.data as String;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String?;
      if (message == 'EMAIL_NOT_FOUND') {
        throw EmailNotFoundForVerificationException();
      }
      if (message == 'EMAIL_ALREADY_VERIFIED') {
        throw EmailAlreadyVerifiedException();
      }
      throw _handleError(e);
    }
  }

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

/// El email introducido no existe en el sistema
class EmailNotFoundForVerificationException extends AuthException {
  const EmailNotFoundForVerificationException()
      : super('Este email no está registrado');
}

/// La cuenta ya está verificada
class EmailAlreadyVerifiedException extends AuthException {
  const EmailAlreadyVerifiedException()
      : super('Esta cuenta ya está verificada');
}