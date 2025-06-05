// lib/screens/cars_screen.dart

import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/car_model.dart';
import 'car_detail_screen.dart'; // <-- Importamos la pantalla de detalle del auto

class CarsScreen extends StatefulWidget {
  const CarsScreen({Key? key}) : super(key: key);

  @override
  State<CarsScreen> createState() => _CarsScreenState();
}

class _CarsScreenState extends State<CarsScreen> {
  final _api = ApiService();
  late Future<List<Car>> _carsFuture;

  @override
  void initState() {
    super.initState();
    _carsFuture = _api.getCars();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1147),
        title: const Text(
          'Todos los Autos',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<Car>>(
        future: _carsFuture,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1F1147)),
            );
          }
          if (snap.hasError) {
            return Center(
              child: Text(
                'Error al cargar autos',
                style: TextStyle(color: Colors.red.shade300),
              ),
            );
          }
          final cars = snap.data!;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 300, // Cada card tendrá 300 px de alto
              ),
              itemCount: cars.length,
              itemBuilder: (context, index) {
                final c = cars[index];
                // Ajustamos la URL para emulador Android:
                final imgUrl = c.imageUrl.startsWith('http')
                    ? c.imageUrl
                        .replaceFirst('http://localhost', 'http://10.0.2.2')
                    : 'http://10.0.2.2${c.imageUrl}';

                return _buildCarCard(imgUrl, c);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCarCard(String imageUrl, Car c) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.2,
        ),
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
          // Imagen superior redondeada en la parte de arriba
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              imageUrl,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 120,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image,
                    size: 40, color: Colors.grey),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Marca + Modelo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${c.brandName} ${c.model}',
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
              '\Q${c.price}',
              style: const TextStyle(
                color: Colors.green,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Detalles: combustible · km · año
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_gas_station,
                        size: 14, color: Colors.grey[700]),
                    const SizedBox(width: 4),
                    Text(
                      c.fuelType,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.speed, size: 14, color: Colors.grey[700]),
                    const SizedBox(width: 4),
                    Text(
                      '${c.mileage} km',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey[700]),
                    const SizedBox(width: 4),
                    Text(
                      '${c.year}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          // ===== BOTÓN “Ver Detalle” =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ElevatedButton(
              onPressed: () {
                // Navegamos a CarDetailScreen con el ID de este auto
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CarDetailScreen(carId: c.id),
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
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
