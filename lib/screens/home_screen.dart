// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:car_dealership_app/screens/brands/brands_screen.dart';
import 'package:car_dealership_app/screens/cars/cars_screen.dart';
import 'package:car_dealership_app/screens/spare_part/spare_parts_screen.dart';
import 'package:car_dealership_app/screens/profile_screen.dart';
import 'package:car_dealership_app/screens/cars/cars_by_brand_screen.dart';
import 'package:car_dealership_app/screens/cars/car_detail_screen.dart';
import 'package:car_dealership_app/screens/spare_part/spare_part_detail_screen.dart';

import 'package:car_dealership_app/models/user_model.dart';
import 'package:car_dealership_app/models/brand_model.dart';
import 'package:car_dealership_app/models/car_model.dart';
import 'package:car_dealership_app/models/spare_part_model.dart';

import 'package:car_dealership_app/services/users/user_service.dart';
import 'package:car_dealership_app/services/brands/brand_service.dart';
import 'package:car_dealership_app/services/cars/car_service.dart';
import 'package:car_dealership_app/services/spare_parts/spare_part_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _userService = UserService();
  final _brandService = BrandService();
  final _carService = CarService();
  final _partService = SparePartService();

  User? _user;
  late Future<List<Brand>> _brandsFuture;
  late Future<List<Car>> _carsFuture;
  late Future<List<SparePart>> _partsFuture;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _brandsFuture = _brandService.getBrands();
    _carsFuture = _carService.getCars();
    _partsFuture = _partService.getSpareParts();
  }

  Future<void> _loadUser() async {
    final u = await _userService.getStoredUser();
    setState(() => _user = u);
  }

  void _onNavBarTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    // Si entramos en “Perfil” (3) o volvemos a “Inicio” (0), recargar usuario
    if (index == 3 || index == 0) {
      await _loadUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _user != null ? 'Hola,' : 'Hola,';
    final name = _user != null ? _user!.firstName : 'User';
    final avatarUrl =
        _user?.image != null ? 'http://10.0.2.2${_user!.image}' : null;

    final List<Widget> _pages = [
      _buildHomeContent(greeting, name, avatarUrl),
      const BrandsScreen(),
      const CarsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1F1147),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavBarTapped,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1F1147),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Marcas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Ordenes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent(String greeting, String name, String? avatarUrl) {
    return Column(
      children: [
        // ===== HEADER OSCURO =====
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[300],
                backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null
                    ? const Icon(Icons.person, color: Colors.white, size: 28)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(color: Colors.grey[300], fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Carrito con badge "0"
              Stack(
                alignment: Alignment.topRight,
                children: [
                  InkWell(
                    onTap: () {
                      // TODO: acción de carrito
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shopping_cart,
                          color: Colors.white, size: 24),
                    ),
                  ),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '0',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ===== CONTENIDO BLANCO =====
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 16),

                // ===== BARRA DE BÚSQUEDA =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Buscar vehículo..',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            // TODO: acción de búsqueda
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF1F1147),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.arrow_forward,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ===== BANNER =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(248, 24, 18, 61),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          flex: 2,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AutosMontgomery',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 253, 251, 251),
                                      fontSize: 12),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Encuentra el auto de tus\nsueños',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 248, 247, 251),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Spacer(),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            child: Image.asset('assets/images/banner_car.png',
                                fit: BoxFit.cover),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ===== SECCIÓN: Marcas Destacadas =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Marcas Destacadas',
                        style: TextStyle(
                            color: Color(0xFF1F1147),
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedIndex = 1; // Muestra BrandsScreen
                          });
                        },
                        child: Text(
                          'Ver todas',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Lista horizontal de marcas
                SizedBox(
                  height: 130,
                  child: FutureBuilder<List<Brand>>(
                    future: _brandsFuture,
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF1F1147)));
                      }
                      if (snap.hasError) {
                        return Center(
                          child: Text(
                            'No se pudieron cargar las marcas',
                            style: TextStyle(color: Colors.red.shade300),
                          ),
                        );
                      }
                      final brands = snap.data!;
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: brands.length,
                        itemBuilder: (ctx, i) {
                          final b = brands[i];
                          final imgUrl = 'http://10.0.2.2${b.image}';
                          final countText = '+${i * 3 + 5}';

                          return Padding(
                            padding: EdgeInsets.only(
                              right: i == brands.length - 1 ? 16 : 12,
                            ),
                            child: InkWell(
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
                                width: 130,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: Colors.grey.shade300, width: 1.2),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        offset: Offset(0, 2)),
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
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.broken_image),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      b.name,
                                      style: const TextStyle(
                                        color: Color(0xFF1F1147),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    // Text(
                                    //   countText,
                                    //   style: TextStyle(
                                    //       color: Colors.grey[600],
                                    //       fontSize: 11),
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // ===== SECCIÓN: Identificar vehículo más cercano =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1F1147),
                            borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(16)),
                          ),
                          child: const Center(
                              child: Icon(Icons.map,
                                  color: Colors.white, size: 32)),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'Identificar el vehículo más cercano',
                              style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF1F1147),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.arrow_forward,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ===== SECCIÓN: Autos =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Autos Disponibles',
                        style: TextStyle(
                            color: Color(0xFF1F1147),
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navega directamente a CarsScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CarsScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Ver todos',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Lista horizontal de autos (mismo diseño que en CarsScreen)
                SizedBox(
                  height: 280,
                  child: FutureBuilder<List<Car>>(
                    future: _carsFuture,
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF1F1147)));
                      }
                      if (snap.hasError) {
                        return const Center(
                          child: Text(
                            'No se pudieron cargar los autos',
                            style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255)),
                          ),
                        );
                      }
                      final cars = snap.data!;
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: cars.length,
                        itemBuilder: (ctx, i) {
                          return Padding(
                            padding: EdgeInsets.only(
                                right: i == cars.length - 1 ? 16 : 12),
                            child: _buildCarCard(cars[i]),
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // ===== SECCIÓN: Repuestos =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Repuestos',
                        style: TextStyle(
                            color: Color(0xFF1F1147),
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navega directamente a SparePartsScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SparePartsScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Ver todos',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Lista horizontal de repuestos (mismo diseño que en SparePartsScreen)
                SizedBox(
                  height: 270,
                  child: FutureBuilder<List<SparePart>>(
                    future: _partsFuture,
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF1F1147)));
                      }
                      if (snap.hasError) {
                        print(
                            'Error al cargar repuestos en HomeScreen: ${snap.error}');
                        return Center(
                          child: Text(
                            'No se pudieron cargar los repuestos',
                            style: TextStyle(color: Colors.red.shade300),
                          ),
                        );
                      }
                      final parts = snap.data!;
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: parts.length,
                        itemBuilder: (ctx, i) {
                          return Padding(
                            padding: EdgeInsets.only(
                                right: i == parts.length - 1 ? 16 : 12),
                            child: _buildPartCard(parts[i]),
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCarCard(Car c) {
    final imageUrl = 'http://10.0.2.2${c.imageUrl}';
    return SizedBox(
      width: 200,
      height: 280,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300, width: 1.2),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                height: 95,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 95,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image,
                      size: 40, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '${c.brandName} ${c.model}',
                style: const TextStyle(
                    color: Color(0xFF1F1147),
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '\$${c.price}',
                style: const TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),
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
                      Text(c.fuelType,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[700])),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.speed, size: 14, color: Colors.grey[700]),
                      const SizedBox(width: 4),
                      Text('${c.mileage} km',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[700])),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 14, color: Colors.grey[700]),
                      const SizedBox(width: 4),
                      Text('${c.year}',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[700])),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ElevatedButton(
                onPressed: () {
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
      ),
    );
  }

  Widget _buildPartCard(SparePart p) {
    final imgUrl =
        p.imageUrl.replaceFirst('http://localhost', 'http://10.0.2.2');

    return SizedBox(
      width: 200,
      height: 270,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300, width: 1.2),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imgUrl,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 100,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image,
                      size: 40, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                p.name,
                style: const TextStyle(
                    color: Color(0xFF1F1147),
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '\$${p.price}',
                style: const TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Stock: ${p.stock}',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ElevatedButton(
                onPressed: () {
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
      ),
    );
  }
}
