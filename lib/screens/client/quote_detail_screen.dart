// lib/screens/quotes/quote_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/quote_model.dart';
import '../../services/quotes/quote_service.dart';

class QuoteDetailScreen extends StatefulWidget {
  final int quoteId;
  const QuoteDetailScreen({Key? key, required this.quoteId}) : super(key: key);

  @override
  State<QuoteDetailScreen> createState() => _QuoteDetailScreenState();
}

class _QuoteDetailScreenState extends State<QuoteDetailScreen> {
  final QuoteService _quoteService = QuoteService();
  late Future<Quote> _quoteFuture;

  @override
  void initState() {
    super.initState();
    _quoteFuture = _quoteService.getQuote(widget.quoteId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalle de Cotización',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1F1147),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<Quote>(
        future: _quoteFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1F1147)),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar la cotización',
                style: TextStyle(color: Colors.red.shade300),
              ),
            );
          }

          final q = snapshot.data!;
          //----- IMPRIMIR EN CONSOLA LA RUTA QUE LLEGA -----
          print('→ sparePartImageUrl raw: "${q.sparePartImageUrl}"');
          final fullUrl = q.sparePartImageUrl == null
              ? null
              : 'http://10.0.2.2${q.sparePartImageUrl}';
          print('→ URL completa a cargar: $fullUrl');

          // Formatear fecha en español (Guatemala)
          String formattedDate;
          try {
            final dt = DateTime.parse(q.createdAt);
            formattedDate = DateFormat('d MMMM y', 'es_GT').format(dt);
          } catch (_) {
            formattedDate = q.createdAt;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Mostrar la URL en pantalla para depuración
                if (fullUrl != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      fullUrl,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 180,
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
                ],
                _buildRow('Repuesto:', q.sparePartName ?? '—'),
                const SizedBox(height: 12),
                _buildRow('Solicitado por:', q.fullName),
                const SizedBox(height: 12),
                _buildRow('Teléfono:', q.phone),
                const SizedBox(height: 12),
                _buildRow('Email:', q.email),
                const SizedBox(height: 12),
                _buildRow('Cantidad:', q.quantity.toString()),
                const SizedBox(height: 12),
                _buildRow('Estado:', q.status),
                const SizedBox(height: 12),
                if (q.comment.isNotEmpty) ...[
                  _buildRow('Comentario:', q.comment),
                  const SizedBox(height: 12),
                ],
                _buildRow('Fecha:', formattedDate),
              ],
            ),
          );
        },
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
