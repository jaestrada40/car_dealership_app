// lib/screens/cars/car_detail_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:car_dealership_app/services/api_service.dart';
import 'package:car_dealership_app/models/car_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CarDetailScreen extends StatefulWidget {
  final int carId;

  const CarDetailScreen({
    Key? key,
    required this.carId,
  }) : super(key: key);

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  final ApiService _api = ApiService();
  late Future<Car> _carFuture;

  @override
  void initState() {
    super.initState();
    _carFuture = _api.getCar(widget.carId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1147),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Detalle del Auto',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Car>(
        future: _carFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1F1147)),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error al cargar los datos del auto',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final car = snapshot.data!;
          String imagen = car.imageUrl;
          if (imagen.startsWith('/')) {
            imagen = 'http://10.0.2.2$imagen';
          } else {
            imagen = imagen.replaceFirst('http://localhost', 'http://10.0.2.2');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imagen,
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
                Text(
                  '${car.brandName} ${car.model} (${car.year})',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F1147),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  '\$${car.price}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Color:', car.color ?? '—'),
                const SizedBox(height: 4),
                _buildDetailRow('Estado:', car.status),
                const SizedBox(height: 4),
                _buildDetailRow('Transmisión:', car.transmission),
                const SizedBox(height: 4),
                _buildDetailRow('Combustible:', car.fuelType),
                const SizedBox(height: 4),
                _buildDetailRow('Kilometraje:', '${car.mileage} km'),
                const SizedBox(height: 12),
                const Text(
                  'Descripción:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F1147),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  car.description,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Creado:', car.createdAt ?? '—'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _mostrarBottomSheetCita(context, car.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F1147),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Agendar Cita',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
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

  void _mostrarBottomSheetCita(BuildContext context, int carId) {
    final _formKey = GlobalKey<FormState>();
    final _nombreController = TextEditingController();
    final _telefonoController = TextEditingController();
    final _emailController = TextEditingController();
    final _comentarioController = TextEditingController();
    DateTime? _fechaSeleccionada;
    TimeOfDay? _horaSeleccionada;
    bool _isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            /// -------------------------------
            /// Seleccionar Fecha con validación
            /// -------------------------------
            Future<void> _seleccionarFecha() async {
              final hoy = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: hoy,
                firstDate: hoy,
                lastDate: hoy.add(const Duration(days: 365)),
                // Aquí evitamos sábados (6) y domingos (7)
                selectableDayPredicate: (DateTime date) {
                  // No permitir fines de semana ni fechas anteriores a hoy
                  if (date.isBefore(DateTime(hoy.year, hoy.month, hoy.day))) {
                    return false;
                  }
                  if (date.weekday == DateTime.saturday ||
                      date.weekday == DateTime.sunday) {
                    return false;
                  }
                  return true;
                },
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF1F1147),
                        onPrimary: Colors.white,
                        onSurface: Colors.black87,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() {
                  _fechaSeleccionada = picked;
                });
              }
            }

            /// -------------------------------
            /// Seleccionar Hora con validación
            /// -------------------------------
            Future<void> _seleccionarHora() async {
              final now = TimeOfDay.now();
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(hour: 8, minute: 0),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF1F1147),
                        onPrimary: Colors.white,
                        onSurface: Colors.black87,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                // Validamos que esté entre 08:00 y 17:00
                if (picked.hour < 8 || picked.hour > 17) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Selecciona una hora entre 08:00 y 17:00'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }
                // Si es exactamente las 17:00, permitimos solo minuto cero
                if (picked.hour == 17 && picked.minute > 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('El último horario disponible es 17:00'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }
                setState(() {
                  _horaSeleccionada = picked;
                });
              }
            }

            /// -------------------------------
            /// Enviar Cita
            /// -------------------------------
            Future<void> _enviarCita() async {
              if (!_formKey.currentState!.validate() ||
                  _fechaSeleccionada == null ||
                  _horaSeleccionada == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor completa todos los campos.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              setState(() {
                _isSubmitting = true;
              });

              final body = {
                "car_id": carId,
                "full_name": _nombreController.text.trim(),
                "phone": _telefonoController.text.trim(),
                "email": _emailController.text.trim(),
                "date": "${_fechaSeleccionada!.year.toString().padLeft(4, '0')}-"
                    "${_fechaSeleccionada!.month.toString().padLeft(2, '0')}-"
                    "${_fechaSeleccionada!.day.toString().padLeft(2, '0')}",
                "time": _horaSeleccionada!.format(context),
                "comment": _comentarioController.text.trim(),
              };

              try {
                final url = Uri.parse(
                  'http://10.0.2.2/car_dealership/backend/appointments/create_appointment.php',
                );
                final prefs = await SharedPreferences
                    .getInstance(); // asegúrate de importar shared_preferences
                final token = prefs.getString('token');
                final response = await http.post(
                  url,
                  headers: {
                    'Content-Type': 'application/json',
                    if (token != null) 'Authorization': 'Bearer $token',
                  },
                  body: json.encode(body),
                );

                if (response.statusCode == 200) {
                  final data = json.decode(response.body);
                  if (data['success'] == true) {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cita solicitada correctamente.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    throw Exception('Error al crear cita');
                  }
                } else {
                  throw Exception('HTTP error ${response.statusCode}');
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              } finally {
                if (mounted) {
                  setState(() {
                    _isSubmitting = false;
                  });
                }
              }
            }

            // ------------------------------------------------------------------
            // Construcción del BottomSheet con el formulario (sin tocar diseño)
            // ------------------------------------------------------------------
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Agendar Cita',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F1147),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nombreController,
                          decoration: InputDecoration(
                            labelText: 'Nombre completo',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Requerido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _telefonoController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Teléfono',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Requerido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains('@')) {
                              return 'Correo inválido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: _seleccionarFecha,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Fecha',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(
                              _fechaSeleccionada == null
                                  ? 'Seleccione fecha'
                                  : '${_fechaSeleccionada!.day.toString().padLeft(2, '0')}/'
                                      '${_fechaSeleccionada!.month.toString().padLeft(2, '0')}/'
                                      '${_fechaSeleccionada!.year}',
                              style: TextStyle(
                                color: _fechaSeleccionada == null
                                    ? Colors.grey[600]
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: _seleccionarHora,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Hora',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(
                              _horaSeleccionada == null
                                  ? 'Seleccione hora'
                                  : _horaSeleccionada!.format(context),
                              style: TextStyle(
                                color: _horaSeleccionada == null
                                    ? Colors.grey[600]
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _comentarioController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: 'Comentario (opcional)',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _enviarCita,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1F1147),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Enviar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
