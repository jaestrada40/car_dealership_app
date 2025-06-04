// lib/screens/profile_details_screen.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../models/user_model.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({Key? key}) : super(key: key);

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  final _api = ApiService();
  bool _loading = true;
  User? _user;

  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _passwordCtrl;

  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isSaving = false;

  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController();
    _lastNameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
    _loadUser();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final u = await _api.getStoredUser();
    if (u != null) {
      _firstNameCtrl.text = u.firstName;
      _lastNameCtrl.text = u.lastName;
      _emailCtrl.text = u.email ?? '';
      _passwordCtrl.text = '';
    }
    setState(() {
      _user = u;
      _loading = false;
    });
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  Future<void> _saveAll() async {
    if (!_formKey.currentState!.validate()) return;
    if (_user == null) return;

    setState(() => _isSaving = true);

    // 1) Subir avatar si se seleccionó uno nuevo
    String? imagePathFromServer;
    if (_pickedImage != null) {
      final uploadedPath = await _api.uploadAvatar(_pickedImage!);
      if (uploadedPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al subir avatar'),
            backgroundColor: Colors.redAccent,
          ),
        );
        setState(() => _isSaving = false);
        return;
      }
      imagePathFromServer = uploadedPath;
    }

    // 2) Leer campos del formulario
    final id = _user!.id; // id como String
    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final newPassword = _passwordCtrl.text.trim();

    // 3) Actualizar perfil
    final profileOk = await _api.updateUserProfile(
      id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      username: _user!.username,
      role: _user!.role,
      imagePath: imagePathFromServer,
    );

    // 4) Si ingresó nueva contraseña, actualizarla también
    bool passwordOk = true;
    if (newPassword.isNotEmpty) {
      passwordOk = await _api.updateUserPassword(id, newPassword);
    }

    setState(() => _isSaving = false);

    if (profileOk && passwordOk) {
      // 5) Construir el nuevo User y guardar en SharedPreferences
      final updatedUser = User(
        id: _user!.id,
        firstName: firstName,
        lastName: lastName,
        email: email,
        username: _user!.username,
        role: _user!.role,
        image: imagePathFromServer ?? _user!.image,
        createdAt: _user!.createdAt,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', json.encode(updatedUser.toJson()));

      setState(() {
        _user = updatedUser;
        _pickedImage = null;
        _passwordCtrl.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos actualizados correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Devolver true para notificar a ProfileScreen que hubo cambio
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al actualizar. Intenta nuevamente'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1F1147),
          title: const Text('Mi Información',
              style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF1F1147)),
        ),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1F1147),
          title: const Text('Mi Información',
              style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: Center(
          child: Text(
            'No hay información disponible',
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1147),
        title: const Text('Editar Mi Información',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar
              GestureDetector(
                onTap: _pickAvatar,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _pickedImage != null
                      ? FileImage(_pickedImage!) as ImageProvider
                      : (_user!.image != null
                          ? NetworkImage('http://10.0.2.2${_user!.image}')
                          : null),
                  child: _pickedImage == null && _user!.image == null
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tocar para cambiar avatar',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Nombre
              TextFormField(
                controller: _firstNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Apellidos
              TextFormField(
                controller: _lastNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Apellidos',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Los apellidos son obligatorios';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'El correo es obligatorio';
                  }
                  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                  if (!emailRegex.hasMatch(val.trim())) {
                    return 'Ingresa un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Nueva Contraseña
              TextFormField(
                controller: _passwordCtrl,
                decoration: InputDecoration(
                  labelText: 'Nueva contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (val) {
                  if (val != null && val.isNotEmpty && val.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Botón Guardar cambios
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveAll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F1147),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Guardar cambios',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Mostrar rol (solo lectura)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Rol de usuario:', style: TextStyle(fontSize: 16)),
                  Text(
                    _user!.role,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
