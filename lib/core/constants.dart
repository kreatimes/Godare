// Constantes globales de la aplicación GoDare.
// Aquí centralizamos las URLs y configuraciones básicas para no tener
// que cambiarlas en varios sitios cuando hay que actualizar algo.
class Constants {
  // URL base de la API. Cambiar esto cuando se despliegue en producción.
  // static const String apiBaseUrl = 'http://10.0.2.2:8080'; // Emulador Android Studio
  // static const String apiBaseUrl = 'http://localhost:8080'; // iOS simulator
  // static const String apiBaseUrl = 'http://192.168.1.X:8080'; // Dispositivo fisico en local
  static const String apiBaseUrl = 'https://godare-backend-production.up.railway.app'; // Produccion

  // Logo de la app
  static const String logoLocal = 'assets/images/logo.png';
  static const String logoNetwork = 'https://godare.app/assets/images/logo.png';

  // Timeouts de red en milisegundos
  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 15000;
}
