// lib/screens/admin/users_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:car_dealership_app/models/user_model.dart';
import 'package:car_dealership_app/services/admin/user_admin_service.dart';
import 'edit_user_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final UserAdminService _adminService = UserAdminService();
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      _usersFuture = _adminService.getAllUsers();
    });
  }

  Future<void> _confirmAndDelete(User u) async {
    final resp = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text(
          '¿Estás seguro de eliminar a ${u.firstName} ${u.lastName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (resp == true) {
      try {
        final ok = await _adminService.deleteUser(int.parse(u.id));
        if (ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuario eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          _loadUsers();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo eliminar'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestión de Usuarios',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1F1147),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1F1147)),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar usuarios',
                style: TextStyle(color: Colors.red.shade300),
              ),
            );
          }

          final users = snapshot.data!;
          if (users.isEmpty) {
            return const Center(
              child: Text(
                'No hay usuarios registrados.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              final u = users[i];
              final avatarUrl =
                  u.image != null ? 'http://10.0.2.2${u.image!}' : null;

              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[200],
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null
                      ? const Icon(Icons.person, color: Color(0xFF1F1147))
                      : null,
                ),
                title: Text(
                  '${u.firstName} ${u.lastName}',
                  style: const TextStyle(
                    color: Color(0xFF1F1147),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${u.email ?? "sin correo"}  •  Rol: ${u.role}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF1F1147)),
                      onPressed: () async {
                        // Navegar a pantalla de edición
                        final didUpdate = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditUserScreen(user: u),
                          ),
                        );
                        if (didUpdate == true) {
                          // Si efectivamente se actualizó, recargamos
                          _loadUsers();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _confirmAndDelete(u),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
