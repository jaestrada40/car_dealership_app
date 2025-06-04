// lib/screens/brands_screen.dart

import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/brand_model.dart';
import '../cars/cars_by_brand_screen.dart'; // <-- importar la nueva pantalla

class BrandsScreen extends StatefulWidget {
  const BrandsScreen({Key? key}) : super(key: key);

  @override
  State<BrandsScreen> createState() => _BrandsScreenState();
}

class _BrandsScreenState extends State<BrandsScreen> {
  final _api = ApiService();
  late Future<List<Brand>> _brandsFuture;

  @override
  void initState() {
    super.initState();
    _brandsFuture = _api.getBrands();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1147),
        title: const Text(
          'Todas las Marcas',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Brand>>(
        future: _brandsFuture,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF1F1147)));
          }
          if (snap.hasError) {
            return Center(
              child: Text(
                'Error al cargar marcas',
                style: TextStyle(color: Colors.red.shade300),
              ),
            );
          }
          final brands = snap.data!;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: brands.length,
              itemBuilder: (context, index) {
                final b = brands[index];
                final imgUrl = b.image.startsWith('http')
                    ? b.image
                        .replaceFirst('http://localhost', 'http://10.0.2.2')
                    : 'http://10.0.2.2${b.image}';

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CarsByBrandScreen(
                          brandId: int.parse(b.id),
                          brandName: b.name,
                        ),
                      ),
                    );
                  },
                  child: Container(
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imgUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          b.name,
                          style: const TextStyle(
                            color: Color(0xFF1F1147),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
