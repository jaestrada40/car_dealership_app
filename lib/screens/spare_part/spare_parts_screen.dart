// lib/screens/spare_parts_screen.dart

import 'package:flutter/material.dart';
import 'package:car_dealership_app/services/api_service.dart';
import 'package:car_dealership_app/models/spare_part_model.dart';
import 'package:car_dealership_app/screens/spare_part/spare_part_detail_screen.dart';

class SparePartsScreen extends StatefulWidget {
  const SparePartsScreen({Key? key}) : super(key: key);

  @override
  State<SparePartsScreen> createState() => _SparePartsScreenState();
}

class _SparePartsScreenState extends State<SparePartsScreen> {
  final _api = ApiService();
  late Future<List<SparePart>> _partsFuture;

  @override
  void initState() {
    super.initState();
    _partsFuture = _api.getSpareParts();
    // Asegúrate de que getSpareParts() en ApiService apunta a:
    // http://10.0.2.2/car_dealership/backend/spare_parts/get_spare_parts.php
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1147),
        title: const Text(
          'Todos los Repuestos',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<SparePart>>(
        future: _partsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1F1147)),
            );
          }

          if (snapshot.hasError) {
            // Si hay error al cargar, lo mostramos aquí
            return Center(
              child: Text(
                'Error al cargar repuestos',
                style: TextStyle(color: Colors.red.shade300),
              ),
            );
          }

          final parts = snapshot.data!;
          if (parts.isEmpty) {
            return const Center(
              child: Text(
                'No hay repuestos disponibles',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: parts.length,
              itemBuilder: (context, index) {
                final p = parts[index];
                // Ajuste de URL para Android Emulator:
                final imgUrl = p.imageUrl.startsWith('http')
                    ? p.imageUrl
                        .replaceFirst('http://localhost', 'http://10.0.2.2')
                    : 'http://10.0.2.2${p.imageUrl}';

                return _buildPartCard(imgUrl, p);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPartCard(String imageUrl, SparePart p) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Imagen del repuesto
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              imageUrl,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 100,
                color: Colors.grey[200],
                child: const Icon(
                  Icons.broken_image,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Nombre
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              p.name,
              style: const TextStyle(
                color: Color(0xFF1F1147),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 4),

          // Precio
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '\Q${p.price}',
              style: const TextStyle(
                color: Colors.green,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Stock
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Stock: ${p.stock}',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ),

          const Spacer(),

          // Botón "Ver Detalle"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ElevatedButton(
              onPressed: () {
                // Pasamos directamente p.id (ya es int)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SparePartDetailScreen(
                      sparePartId: p.id,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F1147),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text(
                'Ver Detalle',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
