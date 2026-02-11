// lib/models/voter.dart
class Voter {
  final String id; // CNIC as ID
  final String name;
  final String fatherName;
  final String cnic;
  final String address;
  final String stationId;
  final bool isEligible;
  final bool hasVoted;
  final DateTime? votedAt;
  final String? photoUrl; // optional - can be network or asset

  Voter({
    required this.id,
    required this.name,
    required this.fatherName,
    required this.cnic,
    required this.address,
    required this.stationId,
    this.isEligible = true,
    this.hasVoted = false,
    this.votedAt,
    this.photoUrl,
  });

  // From Firebase document
  factory Voter.fromJson(Map<String, dynamic> json) {
    return Voter(
      id: json['doc_id'] ?? json['cnic'],
      name: json['name'],
      fatherName: json['father_name'],
      cnic: json['cnic'],
      address: json['address'],
      stationId: json['station_id'],
      isEligible: json['is_eligible'] ?? true,
      hasVoted: json['has_voted'] ?? false,
      votedAt: json['voted_at'] != null
          ? DateTime.parse(json['voted_at'])
          : null,
      photoUrl: json['photo_url'],
    );
  }

  // To Firebase document
  Map<String, dynamic> toJson() {
    return {
      'doc_id': id,
      'name': name,
      'father_name': fatherName,
      'cnic': cnic,
      'address': address,
      'station_id': stationId,
      'is_eligible': isEligible,
      'has_voted': hasVoted,
      'voted_at': votedAt?.toIso8601String(),
      'photo_url': photoUrl,
    };
  }

  // For mock data compatibility
  factory Voter.fromMock(Map<String, dynamic> json) {
    return Voter(
      id: json['id'],
      name: json['name'],
      fatherName: json['fatherName'],
      cnic: json['cnic'],
      address: json['address'] ?? 'Address not provided',
      stationId: json['stationId'] ?? 'station_001',
      isEligible: json['isEligible'] ?? true,
      hasVoted: json['hasVoted'] ?? false,
      votedAt: json['votedAt'] != null ? DateTime.parse(json['votedAt']) : null,
      photoUrl: json['photoUrl'],
    );
  }

  Voter copyWith({
    String? id,
    String? name,
    String? fatherName,
    String? cnic,
    String? address,
    String? stationId,
    bool? isEligible,
    bool? hasVoted,
    DateTime? votedAt,
    String? photoUrl,
  }) {
    return Voter(
      id: id ?? this.id,
      name: name ?? this.name,
      fatherName: fatherName ?? this.fatherName,
      cnic: cnic ?? this.cnic,
      address: address ?? this.address,
      stationId: stationId ?? this.stationId,
      isEligible: isEligible ?? this.isEligible,
      hasVoted: hasVoted ?? this.hasVoted,
      votedAt: votedAt ?? this.votedAt,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
