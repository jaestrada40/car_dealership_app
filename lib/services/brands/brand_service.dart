// lib/services/brands/brand_service.dart

import 'dart:convert';
import 'package:car_dealership_app/models/brand_model.dart';
import 'package:car_dealership_app/services/api_config.dart';
import 'package:http/http.dart' as http;

class BrandService {
  /// Obtener todas las marcas
  Future<List<Brand>> getBrands() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/brands/get_brands.php');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      if (data['success'] == true) {
        return (data['brands'] as List).map((b) => Brand.fromJson(b)).toList();
      } else {
        throw Exception('API Falló (getBrands): success=false');
      }
    } else {
      throw Exception('HTTP error ${resp.statusCode} (getBrands)');
    }
  }
}
