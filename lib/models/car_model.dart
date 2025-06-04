// lib/models/car_model.dart

class Car {
  final int id;
  final int brandId;
  final String brandName;
  final String model;
  final int year;
  final String price;
  final int mileage;
  final String fuelType;
  final String transmission;
  final String imageUrl;
  final String description;
  final String status;
  // Opcionalmente podrías querer color y createdAt si los vas a mostrar:
  final String? color;
  final String? createdAt;

  Car({
    required this.id,
    required this.brandId,
    required this.brandName,
    required this.model,
    required this.year,
    required this.price,
    required this.mileage,
    required this.fuelType,
    required this.transmission,
    required this.imageUrl,
    required this.description,
    required this.status,
    this.color,
    this.createdAt,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'] as int,
      brandId: json['brand_id'] as int,
      brandName: json['brand_name'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      price: json['price'] as String,
      mileage: json['mileage'] as int,
      fuelType: json['fuel_type'] as String,
      transmission: json['transmission'] as String,
      imageUrl: json['image_url'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      color: json['color']?.toString(), // clave “color” viene en el JSON
      createdAt:
          json['created_at']?.toString(), // clave “created_at” viene en el JSON
    );
  }
}
