// lib/screens/quotations_screen.dart

import 'package:car_dealership_app/models/quote_model.dart';
import 'package:car_dealership_app/screens/client/quote_detail_screen.dart';
import 'package:car_dealership_app/services/quotes/quote_service.dart';
import 'package:flutter/material.dart';

class QuotationsScreen extends StatefulWidget {
  const QuotationsScreen({Key? key}) : super(key: key);

  @override
  State<QuotationsScreen> createState() => _QuotationsScreenState();
}

class _QuotationsScreenState extends State<QuotationsScreen> {
  final QuoteService _quoteService = QuoteService();
  late Future<List<Quote>> _quotesFuture;

  @override
  void initState() {
    super.initState();
    // Asumimos que getAllQuotes() devuelve solo las cotizaciones del usuario actual.
    _quotesFuture = _quoteService.getAllQuotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis Cotizaciones',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1F1147),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<Quote>>(
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
            return const Center(
              child: Text(
                'No tienes cotizaciones aún',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            itemCount: quotes.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final q = quotes[index];
              return _buildQuoteTile(q);
            },
          );
        },
      ),
    );
  }

  Widget _buildQuoteTile(Quote q) {
    // Si sparePartName es null, mostramos "Repuesto desconocido"
    final spareName = q.sparePartName ?? 'Repuesto';
    // Formateamos la fecha (solo YYYY-MM-DD) para mostrarla más limpia
    final fecha = q.createdAt.split(' ')[0]; // asumiendo "2025-06-02 14:30:00"
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      leading: CircleAvatar(
        backgroundColor: Colors.grey[200],
        child: Text(
          q.quantity.toString(),
          style: const TextStyle(
            color: Color(0xFF1F1147),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        spareName,
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
            'Pedido por: ${q.fullName}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 2),
          if (q.comment.isNotEmpty)
            Text(
              'Comentario: ${q.comment}',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          const SizedBox(height: 4),
          Text(
            'Fecha: $fecha',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Color(0xFF1F1147),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuoteDetailScreen(quoteId: q.id),
          ),
        );
      },
    );
  }
}
