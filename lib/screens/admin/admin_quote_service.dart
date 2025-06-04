// lib/services/quotes/admin_quote_service.dart

import 'dart:convert';
import 'package:car_dealership_app/services/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminQuoteService {
  /// 1) Obtener **todas** las cotizaciones (requiere rol=admin)
  Future<List<Map<String, dynamic>>> getAllQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url =
        Uri.parse('${ApiConfig.baseUrl}/quotes/get_all_quotes_admin.php');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final resp = await http.get(url, headers: headers);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body) as Map<String, dynamic>;
      if (data['success'] == true) {
        final List<dynamic> raw = data['quotes'] as List<dynamic>;
        // Usamos Map<String,dynamic> directamente porque manejará imagen, status, etc.
        return raw.cast<Map<String, dynamic>>();
      }
      throw Exception('API falló: success=false');
    }
    throw Exception('HTTP error ${resp.statusCode}');
  }

  /// 2) Actualizar la cotización (cambiar status, quantity, comment)
  Future<bool> updateQuote({
    required int id,
    String? status,
    int? quantity,
    String? comment,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('${ApiConfig.baseUrl}/quotes/update_quote.php');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final body = <String, dynamic>{
      'id': id,
      if (status != null) 'status': status,
      if (quantity != null) 'quantity': quantity,
      if (comment != null) 'comment': comment,
    };

    final resp = await http.post(
      url,
      headers: headers,
      body: json.encode(body),
    );
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body) as Map<String, dynamic>;
      return data['success'] == true;
    }
    return false;
  }

  /// 3) Eliminar cotización
  Future<bool> deleteQuote(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Pasamos el ID por query string
    final url =
        Uri.parse('${ApiConfig.baseUrl}/quotes/delete_quote.php?id=$id');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final resp = await http.get(url, headers: headers);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body) as Map<String, dynamic>;
      return data['success'] == true;
    }
    return false;
  }
}
