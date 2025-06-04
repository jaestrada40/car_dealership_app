// lib/screens/admin/quotes_screen.dart

import 'package:car_dealership_app/screens/admin/admin_quote_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminQuotesScreen extends StatefulWidget {
  const AdminQuotesScreen({Key? key}) : super(key: key);

  @override
  State<AdminQuotesScreen> createState() => _AdminQuotesScreenState();
}

class _AdminQuotesScreenState extends State<AdminQuotesScreen> {
  final AdminQuoteService _service = AdminQuoteService();
  late Future<List<Map<String, dynamic>>> _quotesFuture;

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  void _loadQuotes() {
    _quotesFuture = _service.getAllQuotes();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadQuotes();
    });
    await _quotesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Cotizaciones',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1F1147),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _quotesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1F1147)),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar cotizaciones',
                style: TextStyle(color: Colors.red.shade300),
              ),
            );
          }

          final quotes = snapshot.data!;
          if (quotes.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: [
                  const SizedBox(height: 100),
                  Icon(Icons.request_quote,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'No hay cotizaciones registradas.',
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
              itemCount: quotes.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final q = quotes[index];
                return _buildQuoteTile(q);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuoteTile(Map<String, dynamic> q) {
    // Campos devueltos desde el backend:
    // q['id'], q['user_id'], q['spare_part_name'], q['spare_part_image_url'],
    // q['full_name'], q['phone'], q['email'], q['quantity'], q['comment'],
    // q['status'], q['created_at']
    final int id = q['id'] as int;
    final String partName = q['spare_part_name'] as String;
    final String? partImgUrl = q['spare_part_image_url'] as String?;
    final String fullName = q['full_name'] as String;
    final int quantity = q['quantity'] as int;
    final String status = q['status'] as String;
    final String createdAt = q['created_at'] as String;

    // Fecha formateada (solo día mes año en español Guatemala):
    String formattedDate = createdAt.split(' ')[0];
    try {
      final dt = DateTime.parse(createdAt);
      formattedDate = DateFormat('d MMMM y', 'es_GT').format(dt);
    } catch (_) {}

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[200],
        backgroundImage: partImgUrl != null
            ? NetworkImage('http://10.0.2.2$partImgUrl')
            : null,
        child: partImgUrl == null
            ? const Icon(Icons.request_quote, color: Color(0xFF1F1147))
            : null,
      ),
      title: Text(
        partName,
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
          Text('Cantidad: $quantity',
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 2),
          Text('Fecha: $formattedDate',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
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

  /// Widget que muestra un DropdownButton para cambiar el status de una cotización.
  Widget _statusDropdown(int quoteId, String currentStatus) {
    const List<String> allStatuses = ['pendiente', 'aprobada', 'rechazada'];

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
          _changeStatus(quoteId, newStatus);
        }
      },
    );
  }

  /// Llama al endpoint update_quote.php para cambiar el estado
  Future<void> _changeStatus(int quoteId, String newStatus) async {
    final ok = await _service.updateQuote(id: quoteId, status: newStatus);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Estado actualizado a "$newStatus".'),
          backgroundColor: Colors.green.shade600,
        ),
      );
      _loadQuotes();
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error al actualizar estado'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  /// Muestra un diálogo de confirmación antes de eliminar
  void _confirmDelete(int quoteId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar cotización?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteQuote(quoteId);
            },
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  /// Llama al endpoint delete_quote.php
  Future<void> _deleteQuote(int quoteId) async {
    final ok = await _service.deleteQuote(quoteId);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cotización eliminada'),
          backgroundColor: Colors.green,
        ),
      );
      _loadQuotes();
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al eliminar cotización'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
