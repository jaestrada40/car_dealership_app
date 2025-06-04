// lib/services/users/user_service.dart

import 'dart:convert';
import 'dart:io';

import 'package:car_dealership_app/models/user_model.dart';
import 'package:car_dealership_app/services/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  /// 1) Login: obtiene token + datos de usuario y los guarda
  Future<bool> login(String identifier, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/login_user.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'identifier': identifier,
        'password': password,
      }),
    );

    // DEBUG: imprimimos en consola lo que devuelve el servidor
    print('➤ [DEBUG] UserService.login() → statusCode: ${response.statusCode}');
    print('➤ [DEBUG] UserService.login() → response.body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final token = data['token'] as String;
        final user = User.fromJson(data['user']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        // Verificamos que realmente quedó guardado:
        final tokenguardado = prefs.getString('token');
        print('➤ [DEBUG] UserService.login() → tokenGuardado: $tokenguardado');

        await prefs.setString('user', json.encode(user.toJson()));
        return true;
      }
    }

    return false;
  }

  /// 2) Recuperar usuario local (o null si no hay)
  Future<User?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      final map = json.decode(userJson);
      return User.fromJson(map);
    }
    return null;
  }

  /// 3) Logout: elimina token + usuario local
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  /// 4) Subir avatar (multipart/form-data)
  Future<String?> uploadAvatar(File imageFile) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/users/upload_avatar.php');
    final request = http.MultipartRequest('POST', uri);

    final mimeTypeData =
        lookupMimeType(imageFile.path)?.split('/') ?? ['image', 'jpeg'];
    final multipartFile = await http.MultipartFile.fromPath(
      'avatar',
      imageFile.path,
      contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
    );
    request.files.add(multipartFile);

    // Agregar encabezado Authorization si existe token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('➤ [DEBUG] UserService.uploadAvatar() → token="$token"');
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final streamedResponse = await request.send();
    final respStr = await streamedResponse.stream.bytesToString();
    print(
        '➤ [DEBUG] UserService.uploadAvatar() → status=${streamedResponse.statusCode}');
    print('➤ [DEBUG] UserService.uploadAvatar() → body=$respStr');

    if (streamedResponse.statusCode == 200) {
      try {
        final data = json.decode(respStr) as Map<String, dynamic>;
        if (data['success'] == true) {
          return data['image_path']
              as String; // p.ej. "/uploads/avatars/xyz.png"
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

  /// 5) Actualizar perfil de usuario
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

    // DEBUG
    print('➤ [DEBUG] UserService.updateUserProfile() → token: $token');

    final url = Uri.parse('${ApiConfig.baseUrl}/users/update_user.php');
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

    print('➤ [DEBUG] UserService.updateUserProfile() → headers: $headers');
    print(
        '➤ [DEBUG] UserService.updateUserProfile() → body: ${json.encode(body)}');

    final resp = await http.post(
      url,
      headers: headers,
      body: json.encode(body),
    );
    print(
        '➤ [DEBUG] UserService.updateUserProfile() → statusCode: ${resp.statusCode}');
    print(
        '➤ [DEBUG] UserService.updateUserProfile() → bodyResponse: ${resp.body}');

    try {
      final data = json.decode(resp.body);
      return data['success'] == true;
    } catch (e) {
      print(
          '➤ [DEBUG] UserService.updateUserProfile(): Error al parsear JSON: $e');
      return false;
    }
  }

  /// 6) Actualizar contraseña
  Future<bool> updateUserPassword(String id, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('${ApiConfig.baseUrl}/users/update_password.php');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final body = {
      'id': id,
      'new_password': newPassword,
    };

    print('➤ [DEBUG] UserService.updateUserPassword() → token=$token');
    print(
        '➤ [DEBUG] UserService.updateUserPassword() → body: ${json.encode(body)}');

    final resp =
        await http.post(url, headers: headers, body: json.encode(body));
    print(
        '➤ [DEBUG] UserService.updateUserPassword() → statusCode: ${resp.statusCode}');
    print(
        '➤ [DEBUG] UserService.updateUserPassword() → bodyResponse: ${resp.body}');

    try {
      final data = json.decode(resp.body);
      return data['success'] == true;
    } catch (e) {
      print(
          '➤ [DEBUG] UserService.updateUserPassword(): Error parseando JSON: $e');
      return false;
    }
  }
}
