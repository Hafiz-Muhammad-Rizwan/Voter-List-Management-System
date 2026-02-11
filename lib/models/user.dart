// lib/models/user.dart
class User {
  final String id;
  final String email;
  final String name;
  final String role; // 'admin' or 'officer'
  final String? stationId; // Optional, only for officers

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.stationId,
  });

  // From Firebase document
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['doc_id'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
      stationId: json['station_id'],
    );
  }

  // To Firebase document
  Map<String, dynamic> toJson() {
    return {
      'doc_id': id,
      'email': email,
      'name': name,
      'role': role,
      'station_id': stationId,
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isOfficer => role == 'officer';

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? stationId,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      stationId: stationId ?? this.stationId,
    );
  }
}
