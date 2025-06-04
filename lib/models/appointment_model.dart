// lib/models/appointment_model.dart

class Appointment {
  final int id;
  final int carId;
  final int? userId;
  final String brandName; // Nombre de la marca del carro
  final String model; // Modelo del carro
  final String year; // Año del carro (se parsea como String)
  final String?
      carImageUrl; // Ruta relativa (p. ej. "/car_dealership/uploads/cars/xyz.png")
  final String fullName;
  final String phone;
  final String email;
  final DateTime date;
  final String time;
  final String? comment;
  final String status;
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.carId,
    this.userId,
    required this.brandName,
    required this.model,
    required this.year,
    this.carImageUrl,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.date,
    required this.time,
    this.comment,
    required this.status,
    required this.createdAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as int,
      carId: json['car_id'] as int,
      userId: json['user_id'] != null
          ? int.parse(json['user_id'].toString())
          : null,
      brandName: json['brand_name'] as String,
      model: json['model'] as String,
      year: json['year'].toString(),
      carImageUrl: json['image_url'] as String?,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      comment: json['comment'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'car_id': carId,
      if (userId != null) 'user_id': userId,
      'brand_name': brandName,
      'model': model,
      'year': year,
      'image_url': carImageUrl,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'date': date.toIso8601String().split('T').first,
      'time': time,
      'comment': comment,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
