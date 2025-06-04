// lib/models/spare_part_model.dart

class SparePart {
  final int id;
  final String name;
  final String description;
  final String price;
  final int stock;
  final String? createdAt; // Nullable porque puede venir null
  final String? category;
  final String imageUrl;

  SparePart({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.createdAt,
    this.category,
    required this.imageUrl,
  });

  factory SparePart.fromJson(Map<String, dynamic> json) {
    return SparePart(
      // Convertimos cada string numérico a int
      id: int.parse(json['id'].toString()),
      name: json['name'] as String,
      description: json['description'] as String,
      price: json['price'] as String,
      stock: int.parse(json['stock'].toString()),
      createdAt: json['created_at'] as String?,
      category: json['category'] as String?,
      imageUrl: json['image_url'] as String,
    );
  }
}
