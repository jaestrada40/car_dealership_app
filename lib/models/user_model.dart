// lib/models/user_model.dart

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String username;
  final String role;
  final String? image;
  final String createdAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    required this.username,
    required this.role,
    this.image,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String?,
      username: json['username'] as String,
      role: json['role'] as String,
      image: json['image'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'username': username,
      'role': role,
      'image': image,
      'created_at': createdAt,
    };
  }
}
