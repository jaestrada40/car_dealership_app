// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/api_config.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String apiBaseUrl;

  // 1) Intentamos cargar .env
  try {
    await dotenv.load(fileName: ".env");
    // Si llega aquí, .env se cargó correctamente
    apiBaseUrl = dotenv.env['API_BASE_URL'] ?? "";
    if (apiBaseUrl.isEmpty) {
      // Aunque cargó .env, no existe la clave API_BASE_URL: usamos URL por defecto
      apiBaseUrl = "http://10.0.2.2/car_dealership/backend";
      print(
          '⚠️ .env cargado, pero no está API_BASE_URL. Usando por defecto: $apiBaseUrl');
    } else {
      print('✅ .env cargado, API_BASE_URL="$apiBaseUrl"');
    }
  } catch (e) {
    // 2) En caso de error (p. ej. no existe el archivo .env), asignamos URL por defecto
    apiBaseUrl = "http://10.0.2.2/car_dealership/backend";
    print(
        '⚠️ No se encontró .env o hubo error al leerlo. Usando URL por defecto: $apiBaseUrl');
  }

  // 3) Inicializamos ApiConfig con la URL resultante
  ApiConfig.init(url: apiBaseUrl);

  // 4) Opcional: mantenemos el splash un par de segundos
  FlutterNativeSplash.preserve(
      widgetsBinding: WidgetsFlutterBinding.ensureInitialized());
  Future.delayed(const Duration(seconds: 3), () {
    FlutterNativeSplash.remove();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoMontgomery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
