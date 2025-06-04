// lib/services/appointments/appointment_service.dart

import 'dart:convert';
import 'package:car_dealership_app/models/appointment_model.dart';
import 'package:car_dealership_app/services/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppointmentService {
  /// Envía los datos de la cita al backend, incluyendo el header Authorization.
  Future<bool> createAppointment(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url =
        Uri.parse('${ApiConfig.baseUrl}/appointments/create_appointment.php');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final resp = await http.post(
        url,
        headers: headers,
        body: json.encode(payload),
      );

      print('➤ [AppointmentService] statusCode: ${resp.statusCode}');
      print('➤ [AppointmentService] resp.body: ${resp.body}');

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as Map<String, dynamic>;
        return data['success'] == true;
      } else {
        print(
            '➤ [AppointmentService] HTTP error: ${resp.statusCode} → ${resp.body}');
        return false;
      }
    } catch (e) {
      print('➤ [AppointmentService] Exception: $e');
      return false;
    }
  }

  /// Obtiene la lista de citas del usuario autenticado
  Future<List<Appointment>> getMyAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url =
        Uri.parse('${ApiConfig.baseUrl}/appointments/get_my_appointments.php');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final resp = await http.get(url, headers: headers);
      print(
          '➤ [AppointmentService.getMyAppointments] statusCode: ${resp.statusCode}');
      print('➤ [AppointmentService.getMyAppointments] resp.body: ${resp.body}');

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          final rawList = data['appointments'] as List<dynamic>;
          return rawList
              .map((j) => Appointment.fromJson(j as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('API devolvió success=false');
        }
      } else {
        throw Exception('HTTP error ${resp.statusCode}');
      }
    } catch (e) {
      print('➤ [AppointmentService.getMyAppointments] Exception: $e');
      rethrow;
    }
  }
}
