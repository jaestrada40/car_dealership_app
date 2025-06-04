// lib/screens/admin/admin_screen.dart

import 'package:car_dealership_app/screens/admin/appointments_admin_screen.dart';
import 'package:car_dealership_app/screens/admin/quotes_screen.dart';
import 'package:flutter/material.dart';
import 'users_screen.dart';
// import 'quotes_screen.dart';       // (próximamente)
// import 'appointments_screen.dart'; // (próximamente)

class AdminScreen extends StatelessWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administrador',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1F1147),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        children: [
          ListTile(
            leading: const Icon(Icons.supervised_user_circle,
                color: Color(0xFF1F1147)),
            title: const Text('Gestionar Usuarios'),
            subtitle: const Text('Editar, eliminar o cambiar rol'),
            trailing:
                const Icon(Icons.arrow_forward_ios, color: Color(0xFF1F1147)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UsersScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.request_quote, color: Color(0xFF1F1147)),
            title: const Text('Gestionar Cotizaciones'),
            subtitle: const Text('Cambiar estado o eliminar'),
            trailing:
                const Icon(Icons.arrow_forward_ios, color: Color(0xFF1F1147)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminQuotesScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.calendar_today, color: Color(0xFF1F1147)),
            title: const Text('Gestionar Citas'),
            subtitle: const Text('Cambiar estado o eliminar'),
            trailing:
                const Icon(Icons.arrow_forward_ios, color: Color(0xFF1F1147)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AppointmentsAdminScreen()),
              );
            },
          ),
          const Divider(),
          const SizedBox(height: 24),
          const Text(
            'Selecciona una sección para administrar la aplicación.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
