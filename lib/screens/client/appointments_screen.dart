// lib/screens/client/appointments_screen.dart

import 'package:car_dealership_app/services/appointment/appointment_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_model.dart';
import 'appointment_detail_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final AppointmentService _service = AppointmentService();
  late Future<List<Appointment>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = _service.getMyAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Citas Agendadas',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1F1147),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<Appointment>>(
        future: _appointmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1F1147)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar citas',
                style: TextStyle(color: Colors.red.shade300),
              ),
            );
          }

          final List<Appointment> appointments = snapshot.data!;

          if (appointments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'Aún no tienes citas agendadas.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Cuando tengas citas programadas,\nlas verás aquí.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            itemCount: appointments.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final a = appointments[index];

              // Formatear fecha en español Guatemala
              String formattedDate;
              try {
                formattedDate = DateFormat.yMMMMd('es_GT').format(a.date);
              } catch (_) {
                formattedDate = a.date.toIso8601String().split('T').first;
              }

              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: a.carImageUrl != null
                      ? NetworkImage(
                          'http://10.0.2.2${a.carImageUrl!}',
                        )
                      : null,
                  child: a.carImageUrl == null
                      ? const Icon(Icons.directions_car,
                          color: Color(0xFF1F1147))
                      : null,
                ),
                title: Text(
                  '${a.brandName} ${a.model} (${a.year})',
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
                    Text(
                      'Fecha: $formattedDate  •  Hora: ${a.time}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Estado: ${a.status}',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Color(0xFF1F1147)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AppointmentDetailScreen(appointment: a),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
