// lib/services/admin/user_admin_service.dart

import 'dart:convert';
import 'dart:io';

import 'package:car_dealership_app/models/user_model.dart';
import 'package:car_dealership_app/services/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserAdminService {
  /// Obtiene la lista completa de usuarios (solo 'admin' puede llamar)
  Future<List<User>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('${ApiConfig.baseUrl}/users/get_users.php');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final resp = await http.get(url, headers: headers);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body) as Map<String, dynamic>;
      if (data['success'] == true) {
        final rawList = data['users'] as List<dynamic>;
        return rawList
            .map((j) => User.fromJson(j as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('API devolvió success=false');
      }
    } else {
      throw Exception('HTTP error ${resp.statusCode}');
    }
  }

  /// Elimina un usuario dado su ID. El admin no puede borrarse a sí mismo.
  Future<bool> deleteUser(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('${ApiConfig.baseUrl}/users/delete_user.php');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final body = {'id': id};

    final resp = await http.post(
      url,
      headers: headers,
      body: json.encode(body),
    );

    if (resp.statusCode == 200) {
      final data = json.decode(resp.body) as Map<String, dynamic>;
      return data['success'] == true;
    } else {
      throw Exception('HTTP error ${resp.statusCode}');
    }
  }

  /// Actualiza cualquier usuario (únicamente 'admin' tiene permiso).
  /// Recibe todos los campos requeridos por update_user.php.
  Future<bool> updateUser({
    required int id,
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String role,
    String? imagePath,
    String? newPassword,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('${ApiConfig.baseUrl}/users/update_user.php');
    final headers = <String, String>{
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
      if (newPassword != null && newPassword.isNotEmpty)
        'password': newPassword,
    };

    final resp = await http.post(
      url,
      headers: headers,
      body: json.encode(body),
    );

    if (resp.statusCode == 200) {
      final data = json.decode(resp.body) as Map<String, dynamic>;
      return data['success'] == true;
    } else {
      throw Exception('HTTP error ${resp.statusCode}');
    }
  }

  /// Sube un nuevo avatar para el usuario indicado (admin).
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

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final streamedResponse = await request.send();
    final respStr = await streamedResponse.stream.bytesToString();
    if (streamedResponse.statusCode == 200) {
      final data = json.decode(respStr) as Map<String, dynamic>;
      if (data['success'] == true) {
        return data['image_path'] as String;
      }
    }
    return null;
  }
}
