// lib/models/station.dart
class Station {
  final String id;
  final String name;
  final String city;
  final String constituency;
  final String? assignedOfficerId;

  Station({
    required this.id,
    required this.name,
    required this.city,
    required this.constituency,
    this.assignedOfficerId,
  });

  // From Firebase document
  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['doc_id'],
      name: json['name'],
      city: json['city'],
      constituency: json['constituency'],
      assignedOfficerId: json['assigned_officer_id'],
    );
  }

  // To Firebase document
  Map<String, dynamic> toJson() {
    return {
      'doc_id': id,
      'name': name,
      'city': city,
      'constituency': constituency,
      'assigned_officer_id': assignedOfficerId,
    };
  }

  Station copyWith({
    String? id,
    String? name,
    String? city,
    String? constituency,
    String? assignedOfficerId,
  }) {
    return Station(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      constituency: constituency ?? this.constituency,
      assignedOfficerId: assignedOfficerId ?? this.assignedOfficerId,
    );
  }
}
