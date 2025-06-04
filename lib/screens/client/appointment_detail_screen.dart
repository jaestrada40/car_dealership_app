// lib/screens/client/appointment_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_model.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final Appointment appointment;

  const AppointmentDetailScreen({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dado que ya llamamos a initializeDateFormatting('es_GT') en main.dart,
    // ahora podemos usar DateFormat sin excepción.
    // Formatear la fecha en español
    String formattedDate;
    try {
      formattedDate = DateFormat.yMMMMd('es_GT').format(appointment.date);
    } catch (_) {
      formattedDate = appointment.date.toIso8601String().split('T').first;
    }

    // Formatear fecha de creación con hora
    String createdAtFormatted;
    try {
      createdAtFormatted =
          DateFormat.yMMMMd('es_GT').add_Hm().format(appointment.createdAt);
    } catch (_) {
      createdAtFormatted =
          appointment.createdAt.toIso8601String().replaceFirst('T', ' ');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalle de Cita',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1F1147),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen del carro (si existe)
            if (appointment.carImageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'http://10.0.2.2${appointment.carImageUrl!}',
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.broken_image,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),

            _buildRow(
              'Carro:',
              '${appointment.brandName} ${appointment.model} (${appointment.year})',
            ),
            const SizedBox(height: 12),

            _buildRow('Solicitado por:', appointment.fullName),
            const SizedBox(height: 12),

            _buildRow('Teléfono:', appointment.phone),
            const SizedBox(height: 12),

            _buildRow('Email:', appointment.email),
            const SizedBox(height: 12),

            _buildRow('Fecha:', formattedDate),
            const SizedBox(height: 12),

            _buildRow('Hora:', appointment.time),
            const SizedBox(height: 12),

            if (appointment.comment != null &&
                appointment.comment!.isNotEmpty) ...[
              _buildRow('Comentario:', appointment.comment!),
              const SizedBox(height: 12),
            ],

            _buildRow('Estado:', appointment.status),
            const SizedBox(height: 12),

            // Fecha de creación
            Text(
              'Creada el: $createdAtFormatted',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F1147),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
