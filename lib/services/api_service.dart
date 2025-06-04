// lib/services/api_service.dart

import 'dart:convert';
import 'dart:io';

import 'package:car_dealership_app/models/quote_model.dart';
import 'package:car_dealership_app/models/spare_part_model.dart';
import 'package:car_dealership_app/models/user_model.dart';
import 'package:car_dealership_app/models/brand_model.dart';
import 'package:car_dealership_app/models/car_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Base URL apuntando a la carpeta backend (en emulador Android se usa 10.0.2.2)
  final String _baseUrl = 'http://10.0.2.2/car_dealership/backend';

  /// 1) Hacer login y guardar token + usuario
  Future<bool> login(String identifier, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login_user.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'identifier': identifier,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final token = data['token'] as String;
        final user = User.fromJson(data['user']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user', json.encode(user.toJson()));
        print(
            '➤ [DEBUG] login() devolvió success=true, token guardado="$token"');
        return true;
      }
    }
    print('➤ [DEBUG] login() devolvió success=false');
    return false;
  }

  /// 2) Recuperar usuario almacenado localmente
  Future<User?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      final map = json.decode(userJson);
      return User.fromJson(map);
    }
    return null;
  }

  /// 3) Eliminar token y usuario de SharedPreferences
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  /// 4) Subir avatar (multipart). Devuelve la ruta (por ejemplo "/uploads/avatars/abc123.png")
  Future<String?> uploadAvatar(File imageFile) async {
    final uri = Uri.parse('$_baseUrl/users/upload_avatar.php');
    final request = http.MultipartRequest('POST', uri);

    // Construir MultipartFile con mimeType
    final mimeTypeData =
        lookupMimeType(imageFile.path)?.split('/') ?? ['image', 'jpeg'];
    final multipartFile = await http.MultipartFile.fromPath(
      'avatar',
      imageFile.path,
      contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
    );
    request.files.add(multipartFile);

    // Adjuntar header Authorization si existe token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('➤ [DEBUG] uploadAvatar() token leído="$token"');
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final streamedResponse = await request.send();
    final respStr = await streamedResponse.stream.bytesToString();
    print('➤ [DEBUG] uploadAvatar() status=${streamedResponse.statusCode}');
    print('➤ [DEBUG] uploadAvatar() body=$respStr');

    if (streamedResponse.statusCode == 200) {
      try {
        final data = json.decode(respStr) as Map<String, dynamic>;
        if (data['success'] == true) {
          return data['image_path'] as String; // ej. "/uploads/avatars/xyz.png"
        }
      } catch (e) {
        print('Error al parsear JSON en uploadAvatar: $e\n$respStr');
      }
    } else {
      print(
          'Error HTTP en uploadAvatar: ${streamedResponse.statusCode}\n$respStr');
    }
    return null;
  }

  /// 5) Actualizar perfil (nombre, apellidos, email, username, role y opcional imagePath)
  Future<bool> updateUserProfile(
    String id, {
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String role,
    String? imagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('$_baseUrl/users/update_user.php');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final body = {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'username': username,
      'role': role,
      if (imagePath != null) 'image': imagePath,
    };

    final resp = await http.post(
      url,
      headers: headers,
      body: json.encode(body),
    );
    print('updateUserProfile status: ${resp.statusCode}');
    print('updateUserProfile body: ${resp.body}');
    try {
      final data = json.decode(resp.body);
      return data['success'] == true;
    } catch (e) {
      print('Error al parsear JSON en updateUserProfile: $e');
      return false;
    }
  }

  /// 6) Actualizar contraseña
  Future<bool> updateUserPassword(String id, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('$_baseUrl/users/update_password.php');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final body = {
      'id': id,
      'new_password': newPassword,
    };

    final resp = await http.post(
      url,
      headers: headers,
      body: json.encode(body),
    );
    print('updateUserPassword status: ${resp.statusCode}');
    print('updateUserPassword body: ${resp.body}');
    try {
      final data = json.decode(resp.body);
      return data['success'] == true;
    } catch (e) {
      print('Error al parsear JSON en updateUserPassword: $e');
      return false;
    }
  }

  /// 7) Obtener lista de marcas
  Future<List<Brand>> getBrands() async {
    final url = Uri.parse('$_baseUrl/brands/get_brands.php');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      if (data['success'] == true) {
        return (data['brands'] as List).map((b) => Brand.fromJson(b)).toList();
      }
      throw Exception('API fallo: success=false (Marcas)');
    }
    throw Exception('HTTP error ${resp.statusCode} (Marcas)');
  }

  /// 8) Obtener lista de autos
  Future<List<Car>> getCars() async {
    final url = Uri.parse('$_baseUrl/cars/get_cars.php');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      if (data['success'] == true) {
        return (data['cars'] as List).map((c) => Car.fromJson(c)).toList();
      }
      throw Exception('API fallo: success=false (Autos)');
    }
    throw Exception('HTTP error ${resp.statusCode} (Autos)');
  }

  /// 9) Obtener lista de repuestos
  Future<List<SparePart>> getSpareParts() async {
    final url = Uri.parse('$_baseUrl/spare_parts/get_spare_parts.php');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      if (data['success'] == true) {
        return (data['spare_parts'] as List)
            .map((p) => SparePart.fromJson(p))
            .toList();
      }
      throw Exception('API fallo: success=false (Repuestos)');
    }
    throw Exception('HTTP error ${resp.statusCode} (Repuestos)');
  }

  /// 10) Registrar usuario nuevo
  Future<Map<String, dynamic>> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
    String role = 'client',
  }) async {
    final url = Uri.parse('$_baseUrl/users/create_user.php');
    final bodyJson = json.encode({
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'username': username,
      'password': password,
      'role': role,
    });
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: bodyJson,
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      return {
        'success': false,
        'message':
            'Error del servidor (Status ${response.statusCode}). Intenta más tarde.',
      };
    }
  }

  /// 11) Obtener autos por marca
  Future<List<Car>> getCarsByBrand(int brandId) async {
    final url = Uri.parse('$_baseUrl/cars/get_cars_by_brand.php?id=$brandId');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      if (data['success'] == true) {
        return (data['cars'] as List).map((c) => Car.fromJson(c)).toList();
      }
      throw Exception('API fallo: success=false (Autos por Marca)');
    }
    throw Exception('HTTP error ${resp.statusCode} (Autos por Marca)');
  }

  /// 12) Obtener detalle de un auto
  Future<Car> getCar(int carId) async {
    final url = Uri.parse('$_baseUrl/cars/get_car.php?id=$carId');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      if (data['success'] == true) {
        return Car.fromJson(data['car']);
      }
      throw Exception('API fallo: success=false (Detalle Auto)');
    }
    throw Exception('HTTP error ${resp.statusCode} (Detalle Auto)');
  }

  /// 13) Obtener detalle de un repuesto
  Future<SparePart> getSparePart(int id) async {
    final resp = await http.get(
      Uri.parse('$_baseUrl/spare_parts/get_spare_part.php?id=$id'),
    );
    final data = json.decode(resp.body);
    if (data['success'] == true) {
      return SparePart.fromJson(data['spare_part']);
    } else {
      throw Exception('Error al obtener repuesto');
    }
  }

  /// 14) Crear cotización
  Future<bool> createQuote(Map<String, dynamic> payload) async {
    final resp = await http.post(
      Uri.parse('$_baseUrl/quotes/create_quote.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );
    final data = json.decode(resp.body);
    return data['success'] == true;
  }

  /// 15) Obtener cotización por ID
  Future<Quote> getQuote(int id) async {
    final resp = await http.get(
      Uri.parse('$_baseUrl/quotes/get_quote.php?id=$id'),
    );
    final data = json.decode(resp.body);
    if (data['success'] == true) {
      return Quote.fromJson(data['quote']);
    } else {
      throw Exception('Cotización no encontrada');
    }
  }

  /// 16) Actualizar cotización
  Future<bool> updateQuote(int id, Map<String, dynamic> updates) async {
    final body = <String, dynamic>{'id': id, ...updates};
    final resp = await http.post(
      Uri.parse('$_baseUrl/quotes/update_quote.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    final data = json.decode(resp.body);
    return data['success'] == true;
  }

  /// 17) Eliminar cotización
  Future<bool> deleteQuote(int id) async {
    final resp = await http.get(
      Uri.parse('$_baseUrl/quotes/delete_quote.php?id=$id'),
    );
    final data = json.decode(resp.body);
    return data['success'] == true;
  }

  /// 18) Listar todas las cotizaciones
  Future<List<Quote>> getAllQuotes() async {
    final resp = await http.get(
      Uri.parse('$_baseUrl/quotes/get_all_quotes.php'),
    );
    final data = json.decode(resp.body);
    if (data['success'] == true) {
      List<dynamic> list = data['quotes'];
      return list.map((json) => Quote.fromJson(json)).toList();
    } else {
      throw Exception('Error al listar cotizaciones');
    }
  }
}
