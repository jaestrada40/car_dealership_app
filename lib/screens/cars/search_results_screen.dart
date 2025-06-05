// lib/screens/cars/search_results_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:car_dealership_app/models/car_model.dart';
import 'package:car_dealership_app/services/cars/car_service.dart';
import 'package:car_dealership_app/screens/cars/car_detail_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;

  const SearchResultsScreen({
    Key? key,
    required this.query,
  }) : super(key: key);

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final CarService _carService = CarService();
  late Future<List<Car>> _allCarsFuture;

  @override
  void initState() {
    super.initState();
    // Cargar todos los autos desde el backend
    _allCarsFuture = _carService.getCars();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Resultados: "${widget.query}"',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1F1147),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Car>>(
        future: _allCarsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1F1147)),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al buscar autos:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade300),
              ),
            );
          }

          final allCars = snapshot.data!;

          // Filtrar localmente: marca o modelo contenga la query (case-insensitive)
          final lowerQuery = widget.query.toLowerCase();
          final filtered = allCars.where((car) {
            final marca = car.brandName.toLowerCase();
            final modelo = car.model.toLowerCase();
            return marca.contains(lowerQuery) || modelo.contains(lowerQuery);
          }).toList();

          if (filtered.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'No se encontraron autos para "${widget.query}".',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final car = filtered[index];
              return _buildCarTile(car);
            },
          );
        },
      ),
    );
  }

  Widget _buildCarTile(Car car) {
    // Cada tile muestra imagen (si existe), marca-modelo, precio y año
    final imgUrl = 'http://10.0.2.2${car.imageUrl}';
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imgUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 60,
            height: 60,
            color: Colors.grey[200],
            child: const Icon(Icons.directions_car, color: Colors.grey),
          ),
        ),
      ),
      title: Text(
        '${car.brandName} ${car.model}',
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
            'Año: ${car.year}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 2),
          Text(
            '\$${car.price}',
            style: const TextStyle(fontSize: 14, color: Colors.green),
          ),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 16, color: Color(0xFF1F1147)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CarDetailScreen(carId: car.id),
          ),
        );
      },
    );
  }
}
