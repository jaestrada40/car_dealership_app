// lib/screens/spare_part/spare_part_detail_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:car_dealership_app/models/spare_part_model.dart';
import 'package:car_dealership_app/services/api_service.dart';
import 'package:car_dealership_app/services/quotes/quote_service.dart';
import 'package:intl/intl.dart';

class SparePartDetailScreen extends StatefulWidget {
  final int sparePartId;

  const SparePartDetailScreen({
    Key? key,
    required this.sparePartId,
  }) : super(key: key);

  @override
  State<SparePartDetailScreen> createState() => _SparePartDetailScreenState();
}

class _SparePartDetailScreenState extends State<SparePartDetailScreen> {
  final ApiService _apiService = ApiService();
  final QuoteService _quoteService = QuoteService();
  late Future<SparePart> _partFuture;

  @override
  void initState() {
    super.initState();
    _partFuture = _apiService.getSparePart(widget.sparePartId);
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
          'Detalle de Repuesto',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<SparePart>(
        future: _partFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1F1147)),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error al cargar datos del repuesto',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final part = snapshot.data!;

          // Ajuste de URL para emulador Android
          String imgUrl = part.imageUrl;
          if (imgUrl.startsWith('/')) {
            imgUrl = 'http://10.0.2.2$imgUrl';
          } else {
            imgUrl = imgUrl.replaceFirst('http://localhost', 'http://10.0.2.2');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Imagen grande
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imgUrl,
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

                // Nombre del repuesto
                Text(
                  part.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F1147),
                  ),
                ),

                const SizedBox(height: 12),

                // Precio
                Text(
                  '\$${part.price}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(height: 12),

                // Stock
                Text(
                  'Stock: ${part.stock}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),

                const SizedBox(height: 12),

                // Categoría
                Text(
                  'Categoría: ${part.category ?? '—'}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),

                const SizedBox(height: 12),

                // Descripción
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
                  part.description,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),

                const SizedBox(height: 16),

                // Fecha de creación (si existe)
                if (part.createdAt != null) ...[
                  Text(
                    'Creado el: ${DateFormat.yMMMMd().format(DateTime.parse(part.createdAt!))}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                ],

                // Botón "Cotizar este Repuesto"
                ElevatedButton(
                  onPressed: () {
                    _showQuoteForm(context, widget.sparePartId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F1147),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Cotizar este Repuesto',
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

  /// Abre un modal BottomSheet con el formulario de cotización
  void _showQuoteForm(BuildContext ctx, int sparePartId) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.6,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: QuoteForm(
              sparePartId: sparePartId,
              scrollController: scrollController,
              quoteService: _quoteService,
            ),
          );
        },
      ),
    );
  }
}

/// Widget que muestra el formulario de cotización dentro del BottomSheet
class QuoteForm extends StatefulWidget {
  final int sparePartId;
  final ScrollController scrollController;
  final QuoteService quoteService;

  const QuoteForm({
    Key? key,
    required this.sparePartId,
    required this.scrollController,
    required this.quoteService,
  }) : super(key: key);

  @override
  State<QuoteForm> createState() => _QuoteFormState();
}

class _QuoteFormState extends State<QuoteForm> {
  final _formKey = GlobalKey<FormState>();

  String _fullName = '';
  String _phone = '';
  String _email = '';
  int _quantity = 1;
  String _comment = '';
  bool _isSubmitting = false;

  Future<void> _submitQuote() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSubmitting = true);

    // Payload esperado por el endpoint PHP
    final payload = <String, dynamic>{
      'spare_part_id': widget.sparePartId,
      'full_name': _fullName,
      'phone': _phone,
      'email': _email,
      'quantity': _quantity,
      'comment': _comment,
    };

    final success = await widget.quoteService.createQuote(payload);

    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.of(context).pop(); // Cierra el BottomSheet
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cotización creada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al crear la cotización'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Formulario de Cotización',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F1147)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              children: [
                // Nombre Completo
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      (val == null || val.isEmpty) ? 'Obligatorio' : null,
                  onSaved: (val) => _fullName = val!.trim(),
                ),
                const SizedBox(height: 12),

                // Teléfono
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (val) =>
                      (val == null || val.isEmpty) ? 'Obligatorio' : null,
                  onSaved: (val) => _phone = val!.trim(),
                ),
                const SizedBox(height: 12),

                // Email
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Obligatorio';
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    return emailRegex.hasMatch(val) ? null : 'Email inválido';
                  },
                  onSaved: (val) => _email = val!.trim(),
                ),
                const SizedBox(height: 12),

                // Cantidad
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Cantidad',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: '1',
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Obligatorio';
                    final n = int.tryParse(val);
                    if (n == null || n <= 0) return 'Debe ser > 0';
                    return null;
                  },
                  onSaved: (val) => _quantity = int.parse(val!),
                ),
                const SizedBox(height: 12),

                // Comentario (opcional)
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Comentario (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onSaved: (val) => _comment = val?.trim() ?? '',
                ),
                const SizedBox(height: 24),

                // Botón enviar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitQuote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F1147),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
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
                            'Enviar Cotización',
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
