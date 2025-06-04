// lib/services/appointments/admin_appointment_service.dart

import 'dart:convert';
import 'package:car_dealership_app/services/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminAppointmentService {
  /// 1) Obtener **todas** las citas (requiere rol=admin)
  Future<List<Map<String, dynamic>>> getAllAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url =
        Uri.parse('${ApiConfig.baseUrl}/appointments/get_appointments.php');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final resp = await http.get(url, headers: headers);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body) as Map<String, dynamic>;
      if (data['success'] == true) {
        final List<dynamic> raw = data['appointments'] as List<dynamic>;
        return raw.cast<Map<String, dynamic>>();
      }
      throw Exception('API falló: success=false');
    }
    throw Exception('HTTP error ${resp.statusCode}');
  }

  /// 2) Actualizar el estado de una cita (pendiente/confirmada/cancelada)
  Future<bool> updateAppointmentStatus({
    required int id,
    required String status,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse(
        '${ApiConfig.baseUrl}/appointments/update_appointment_status.php');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final body = {
      'id': id,
      'status': status,
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

  /// 3) Eliminar una cita
  Future<bool> deleteAppointment(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url =
        Uri.parse('${ApiConfig.baseUrl}/appointments/delete_appointment.php');
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
    }
    return false;
  }
}
