// lib/screens/cars_by_brand_screen.dart

import 'package:flutter/material.dart';
import 'package:car_dealership_app/services/api_service.dart';
import 'package:car_dealership_app/models/car_model.dart';
import 'package:car_dealership_app/screens/cars/car_detail_screen.dart'; // IMPORTA la nueva pantalla

class CarsByBrandScreen extends StatefulWidget {
  final int brandId;
  final String brandName;

  const CarsByBrandScreen({
    Key? key,
    required this.brandId,
    required this.brandName,
  }) : super(key: key);

  @override
  State<CarsByBrandScreen> createState() => _CarsByBrandScreenState();
}

class _CarsByBrandScreenState extends State<CarsByBrandScreen> {
  final _api = ApiService();
  late Future<List<Car>> _carsByBrandFuture;

  @override
  void initState() {
    super.initState();
    _carsByBrandFuture = _api.getCarsByBrand(widget.brandId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1147),
        title: Text(
          'Autos: ${widget.brandName}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<Car>>(
        future: _carsByBrandFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1F1147)),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar autos de ${widget.brandName}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final cars = snapshot.data!;
          if (cars.isEmpty) {
            return Center(
              child: Text(
                'No hay autos registrados para ${widget.brandName}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
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
                mainAxisExtent: 300,
              ),
              itemCount: cars.length,
              itemBuilder: (context, index) {
                final car = cars[index];

                // Ajuste de la URL de la imagen para el emulador Android
                String imagen = car.imageUrl.startsWith('/')
                    ? 'http://10.0.2.2${car.imageUrl}'
                    : car.imageUrl
                        .replaceFirst('http://localhost', 'http://10.0.2.2');

                return _buildCarCard(imagen, car);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCarCard(String imageUrl, Car car) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1.2),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Imagen superior
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
              '${car.brandName} ${car.model}',
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
              '\Q${car.price}',
              style: const TextStyle(
                color: Colors.green,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 4),
          // Detalles (combustible · km · año)
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
                      car.fuelType,
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
                      '${car.mileage} km',
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
                      '${car.year}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          // Botón "Ver Detalle" → Navega a CarDetailScreen
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CarDetailScreen(carId: car.id),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F1147),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
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
