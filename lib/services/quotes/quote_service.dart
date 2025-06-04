// lib/services/quotes/quote_service.dart

import 'dart:convert';
import 'package:car_dealership_app/services/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:car_dealership_app/models/quote_model.dart';

class QuoteService {
  /// Crear cotización (envía header Authorization con token)
  Future<bool> createQuote(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('${ApiConfig.baseUrl}/quotes/create_quote.php');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final resp = await http.post(
      url,
      headers: headers,
      body: json.encode(payload),
    );

    if (resp.statusCode == 200) {
      final data = json.decode(resp.body) as Map<String, dynamic>;
      return data['success'] == true;
    } else {
      return false;
    }
  }

  /// Obtener **detalle** de una cotización
  Future<Quote> getQuote(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('${ApiConfig.baseUrl}/quotes/get_quote.php?id=$id');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final resp = await http.get(url, headers: headers);
    if (resp.statusCode == 200) {
      final raw = resp.body.trim();
      final data = json.decode(raw) as Map<String, dynamic>;
      if (data['success'] == true && data['quote'] != null) {
        return Quote.fromJson(data['quote']);
      }
      throw Exception('Cotización no encontrada o no autorizada');
    }
    throw Exception('HTTP error ${resp.statusCode}');
  }

  /// Listar todas las cotizaciones del usuario autenticado
  Future<List<Quote>> getAllQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('${ApiConfig.baseUrl}/quotes/get_all_quotes.php');
    final resp = await http.get(url, headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    if (resp.statusCode == 200) {
      final data = json.decode(resp.body) as Map<String, dynamic>;
      if (data['success'] == true) {
        final List<dynamic> raw = data['quotes'] as List<dynamic>;
        return raw
            .map((j) => Quote.fromJson(j as Map<String, dynamic>))
            .toList();
      }
      throw Exception('API falló (getAllQuotes): success=false');
    }
    throw Exception('HTTP error ${resp.statusCode}');
  }
}
