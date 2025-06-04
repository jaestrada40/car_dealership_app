// lib/models/quote_model.dart

class Quote {
  final int id;
  final int sparePartId;
  final String? sparePartName;
  final String? sparePartImageUrl; // <-- nuevo
  final String fullName;
  final String phone;
  final String email;
  final int quantity;
  final String comment;
  final String status;
  final String createdAt;

  Quote({
    required this.id,
    required this.sparePartId,
    this.sparePartName,
    this.sparePartImageUrl,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.quantity,
    required this.comment,
    required this.status,
    required this.createdAt,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] as int,
      sparePartId: json['spare_part_id'] as int,
      sparePartName: json['spare_part_name'] as String?,
      sparePartImageUrl: json['spare_part_image_url'] as String?, // <-- asignar
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      quantity: json['quantity'] as int,
      comment: json['comment'] as String? ?? '',
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'spare_part_id': sparePartId,
      if (sparePartName != null) 'spare_part_name': sparePartName,
      if (sparePartImageUrl != null)
        'spare_part_image_url': sparePartImageUrl, // <-- incluir en JSON
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'quantity': quantity,
      'comment': comment,
      'status': status,
      'created_at': createdAt,
    };
  }
}
