// lib/services/cars/car_service.dart

import 'dart:convert';
import 'package:car_dealership_app/models/car_model.dart';
import 'package:car_dealership_app/services/api_config.dart';
import 'package:http/http.dart' as http;

class CarService {
  /// Obtener lista de autos
  Future<List<Car>> getCars() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/cars/get_cars.php');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      if (data['success'] == true) {
        return (data['cars'] as List).map((c) => Car.fromJson(c)).toList();
      }
      throw Exception('API Falló (getCars): success=false');
    }
    throw Exception('HTTP error ${resp.statusCode} (getCars)');
  }

  /// Obtener autos por marca
  Future<List<Car>> getCarsByBrand(int brandId) async {
    final url = Uri.parse(
        '${ApiConfig.baseUrl}/cars/get_cars_by_brand.php?id=$brandId');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      if (data['success'] == true) {
        return (data['cars'] as List).map((c) => Car.fromJson(c)).toList();
      }
      throw Exception('API Falló (getCarsByBrand): success=false');
    }
    throw Exception('HTTP error ${resp.statusCode} (getCarsByBrand)');
  }

  /// Obtener detalle de un auto por ID
  Future<Car> getCar(int carId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/cars/get_car.php?id=$carId');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      if (data['success'] == true && data['car'] != null) {
        return Car.fromJson(data['car']);
      }
      throw Exception('API Falló (getCar): success=false o car nulo');
    }
    throw Exception('HTTP error ${resp.statusCode} (getCar)');
  }
}
