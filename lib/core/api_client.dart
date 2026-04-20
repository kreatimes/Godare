import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:godare/core/constants.dart';
import 'package:godare/core/secure_storage.dart';

/// Cliente HTTP centralizado basado en Dio.
/// Añade automáticamente el JWT en cada petición autenticada
/// y gestiona los errores comunes de red.
class ApiClient {
  static final Logger _log = Logger();

  static Dio? _instance;

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Constants.apiBaseUrl,
        connectTimeout: Duration(milliseconds: Constants.connectTimeoutMs),
        receiveTimeout: Duration(milliseconds: Constants.receiveTimeoutMs),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Interceptor: añade el JWT en el header Authorization de forma automática
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          _log.d('[${options.method}] ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _log.d('[${response.statusCode}] ${response.requestOptions.path}');
          handler.next(response);
        },
        onError: (DioException error, handler) {
          _log.e(
            '[ERROR] ${error.requestOptions.path}',
            error: error.message,
          );
          handler.next(error);
        },
      ),
    );

    return dio;
  }

  /// Resetea la instancia — útil tras logout para limpiar estado
  static void reset() {
    _instance = null;
  }
}