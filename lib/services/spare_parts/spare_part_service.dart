// lib/services/spare_parts/spare_part_service.dart

import 'dart:convert';
import 'package:car_dealership_app/models/spare_part_model.dart';
import 'package:car_dealership_app/services/api_config.dart';
import 'package:http/http.dart' as http;

class SparePartService {
  /// Obtener lista de repuestos
  Future<List<SparePart>> getSpareParts() async {
    final url =
        Uri.parse('${ApiConfig.baseUrl}/spare_parts/get_spare_parts.php');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      if (data['success'] == true) {
        return (data['spare_parts'] as List)
            .map((p) => SparePart.fromJson(p))
            .toList();
      }
      throw Exception('API Falló (getSpareParts): success=false');
    }
    throw Exception('HTTP error ${resp.statusCode} (getSpareParts)');
  }

  /// Obtener detalle de un repuesto
  Future<SparePart> getSparePart(int id) async {
    final url =
        Uri.parse('${ApiConfig.baseUrl}/spare_parts/get_spare_part.php?id=$id');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      if (data['success'] == true && data['spare_part'] != null) {
        return SparePart.fromJson(data['spare_part']);
      }
      throw Exception(
          'API Falló (getSparePart): success=false o spare_part nulo');
    }
    throw Exception('HTTP error ${resp.statusCode} (getSparePart)');
  }
}
