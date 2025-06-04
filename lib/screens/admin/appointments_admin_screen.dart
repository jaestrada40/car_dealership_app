// lib/screens/admin/appointments_admin_screen.dart

import 'package:car_dealership_app/services/admin/admin_appointment_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentsAdminScreen extends StatefulWidget {
  const AppointmentsAdminScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentsAdminScreen> createState() =>
      _AppointmentsAdminScreenState();
}

class _AppointmentsAdminScreenState extends State<AppointmentsAdminScreen> {
  final AdminAppointmentService _service = AdminAppointmentService();
  late Future<List<Map<String, dynamic>>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  void _loadAppointments() {
    _appointmentsFuture = _service.getAllAppointments();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadAppointments();
    });
    await _appointmentsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Citas',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1F1147),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _appointmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1F1147)),
            );
          }

          if (snapshot.hasError) {
            debugPrint('➤ [AppointmentsAdminScreen] ERROR: ${snapshot.error}');
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Error al cargar citas:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade300),
                ),
              ),
            );
          }

          final appointments = snapshot.data!;
          if (appointments.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: [
                  const SizedBox(height: 100),
                  Icon(Icons.calendar_today,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'No hay citas registradas.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: appointments.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final a = appointments[index];
                return _buildAppointmentTile(a);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentTile(Map<String, dynamic> a) {
    final int id = a['id'] as int;
    final String brand = a['brand_name'] as String;
    final String model = a['model'] as String;
    final String year = a['year'].toString();
    final String? imgUrl = a['image_url'] as String?;
    final String fullName = a['full_name'] as String;
    final String dateStr = a['date'] as String;
    final String timeStr = a['time'] as String;
    final String status = a['status'] as String;

    // Formatear fecha
    String formattedDate = dateStr;
    try {
      final dt = DateTime.parse(dateStr);
      formattedDate = DateFormat.yMMMMd('es_GT').format(dt);
    } catch (_) {}

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[200],
        backgroundImage:
            imgUrl != null ? NetworkImage('http://10.0.2.2$imgUrl') : null,
        child: imgUrl == null
            ? const Icon(Icons.directions_car, color: Color(0xFF1F1147))
            : null,
      ),
      title: Text(
        '$brand $model ($year)',
        style: const TextStyle(
          color: Color(0xFF1F1147),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text('Cliente: $fullName',
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 2),
          Text('Fecha: $formattedDate  •  Hora: ${timeStr.substring(0, 5)}',
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 2),
          Row(
            children: [
              const Text('Estado: ',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              _statusDropdown(id, status),
            ],
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.redAccent),
        onPressed: () => _confirmDelete(id),
      ),
    );
  }

  Widget _statusDropdown(int id, String currentStatus) {
    const List<String> allStatuses = ['pendiente', 'confirmada', 'cancelada'];

    return DropdownButton<String>(
      value: currentStatus,
      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF1F1147)),
      underline: const SizedBox(),
      items: allStatuses.map((String s) {
        return DropdownMenuItem<String>(
          value: s,
          child: Text(
            s[0].toUpperCase() + s.substring(1),
            style: const TextStyle(fontSize: 13, color: Color(0xFF1F1147)),
          ),
        );
      }).toList(),
      onChanged: (newStatus) {
        if (newStatus != null && newStatus != currentStatus) {
          _changeStatus(id, newStatus);
        }
      },
    );
  }

  Future<void> _changeStatus(int id, String newStatus) async {
    final ok =
        await _service.updateAppointmentStatus(id: id, status: newStatus);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Estado actualizado a "$newStatus".'),
          backgroundColor: Colors.green.shade600,
        ),
      );
      setState(() => _loadAppointments());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error al actualizar estado'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar cita?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteAppointment(id);
            },
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAppointment(int id) async {
    final ok = await _service.deleteAppointment(id);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cita eliminada'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() => _loadAppointments());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al eliminar cita'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
