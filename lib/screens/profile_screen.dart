// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import 'login_screen.dart';
import 'profile_details_screen.dart';
import 'client/quotations_screen.dart';
import 'client/appointments_screen.dart';
import 'admin/admin_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _api = ApiService();
  bool _loading = true;
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final u = await _api.getStoredUser();
    setState(() {
      _user = u;
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await _api.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF1F1147)),
        ),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1F1147),
          title: const Text('Mi Perfil', style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: Center(
          child: Text(
            'No hay información de usuario.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ),
      );
    }

    final isAdmin = _user!.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1147),
        title:
            const Text('Menú de Perfil', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        children: [
          // ========= Datos básicos =========
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[300],
              backgroundImage: _user!.image != null
                  ? NetworkImage('http://10.0.2.2${_user!.image}')
                  : null,
              child: _user!.image == null
                  ? const Icon(Icons.person, size: 40, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              '${_user!.firstName} ${_user!.lastName}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F1147),
              ),
            ),
          ),
          if (_user!.email != null) ...[
            const SizedBox(height: 4),
            Center(
              child: Text(
                _user!.email!,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
          ],
          const SizedBox(height: 24),

          const Divider(),

          // ========= Opción: Ver detalles de perfil =========
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF1F1147)),
            title: const Text('Mi Información'),
            onTap: () async {
              // Esperamos el resultado de ProfileDetailsScreen
              final didUpdate = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const ProfileDetailsScreen()),
              );

              // Si hubo actualización, recargamos el usuario
              if (didUpdate == true) {
                final u = await _api.getStoredUser();
                setState(() {
                  _user = u;
                });
              }
            },
          ),
          const Divider(),

          // Si NO es administrador, mostrar estas opciones:
          if (!isAdmin) ...[
            // ========= Opción: Solicitud de Cotizaciones =========
            ListTile(
              leading:
                  const Icon(Icons.request_quote, color: Color(0xFF1F1147)),
              title: const Text('Solicitud de Cotizaciones'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QuotationsScreen()),
                );
              },
            ),
            const Divider(),

            // ========= Opción: Citas Agendadas =========
            ListTile(
              leading:
                  const Icon(Icons.calendar_today, color: Color(0xFF1F1147)),
              title: const Text('Citas Agendadas'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AppointmentsScreen()),
                );
              },
            ),
            const Divider(),
          ],

          // ========= Si es Admin, mostrar opción adicional =========
          if (isAdmin) ...[
            ListTile(
              leading: const Icon(Icons.admin_panel_settings,
                  color: Color(0xFF1F1147)),
              title: const Text('Panel de Administrador'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminScreen()),
                );
              },
            ),
            const Divider(),
          ],

          const SizedBox(height: 24),

          // ========= Botón Cerrar Sesión =========
          ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Cerrar Sesión',
                style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
