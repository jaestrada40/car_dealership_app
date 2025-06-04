// lib/services/api_config.dart

class ApiConfig {
  /// Si no usas variables de entorno todavía, puedes tener algo como:
  /// static const String baseUrl = 'http://10.0.2.2/car_dealership/backend';

  /// Pero si vas a usar flutter_dotenv, dejaremos esta propiedad en blanco
  /// y la cargaremos desde `.env`. Por ejemplo:
  static late final String baseUrl;

  /// Llamar a este método al inicio de la app, justo después de cargar .env:
  static void init({required String url}) {
    baseUrl = url;
  }
}
