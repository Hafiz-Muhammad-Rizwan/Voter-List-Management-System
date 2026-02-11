// lib/providers/election_provider.dart
import 'package:flutter/material.dart';
import '../models/voter.dart';

class ElectionProvider extends ChangeNotifier {
  // Mock data — in real app replace with your Firebase API
  List<Voter> _voters = [];
  String stationName = "Govt High School - Hall A";
  String stationId = "station_001";

  List<Voter> get voters => _voters;

  int get verifiedCount => _voters.where((v) => v.hasVoted).length;
  int get pendingCount =>
      _voters.where((v) => !v.hasVoted && v.isEligible).length;

  // For filtering
  String _filter = 'All'; // All, Voted, Not Voted
  String get filter => _filter;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<Voter> get filteredVoters {
    return _voters.where((voter) {
      final matchesSearch =
          voter.cnic.contains(_searchQuery) ||
          voter.name.toLowerCase().contains(_searchQuery.toLowerCase());

      if (_filter == 'Voted') return voter.hasVoted && matchesSearch;
      if (_filter == 'Not Voted') return !voter.hasVoted && matchesSearch;
      return matchesSearch; // All
    }).toList();
  }

  void setFilter(String value) {
    _filter = value;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void markAsVoted(String voterId) {
    final index = _voters.indexWhere((v) => v.id == voterId);
    if (index != -1) {
      _voters[index] = _voters[index].copyWith(
        hasVoted: true,
        votedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // Load mock data with all Firebase schema fields
  void loadMockData() {
    final names = [
      'Ahmed Raza',
      'Fatima Khan',
      'Muhammad Ali',
      'Aisha Malik',
      'Hassan Ahmed',
      'Zainab Shah',
      'Ali Hassan',
      'Mariam Qureshi',
      'Omar Farooq',
      'Sara Ahmed',
      'Bilal Khan',
      'Nadia Ali',
      'Tariq Mahmood',
      'Rafia Siddique',
      'Imran Shah',
      'Sana Malik',
      'Usman Ahmed',
      'Hina Khan',
      'Fahad Ali',
      'Ayesha Raza',
      'Kamran Malik',
      'Bushra Khan',
      'Shahid Ahmed',
      'Farah Ali',
      'Arslan Shah',
    ];

    final fatherNames = [
      'Raza Ali',
      'Khan Sahib',
      'Muhammad Din',
      'Abdul Malik',
      'Ahmed Saeed',
      'Shah Nawaz',
      'Hassan Raza',
      'Qureshi Sahib',
      'Farooq Ahmed',
      'Ahmed Khan',
      'Khan Muhammad',
      'Ali Hassan',
      'Mahmood Shah',
      'Siddique Ahmad',
      'Shah Alam',
      'Malik Saeed',
      'Ahmed Raza',
      'Khan Ali',
      'Ali Ahmad',
      'Raza Khan',
    ];

    final addresses = [
      'House 10, Street 5, Gulberg, Lahore',
      'Flat 2A, Block C, DHA Phase 5, Lahore',
      'Village Chak 123, Tehsil Kasur, Lahore',
      'House 45, Garden Town, Lahore',
      'Apartment 301, Johar Town, Lahore',
      'House 67, Model Town, Lahore',
      'Street 15, Cavalry Ground, Lahore',
      'House 89, Faisal Town, Lahore',
      'Building 12, Wapda Town, Lahore',
      'House 234, Shadman, Lahore',
    ];

    _voters = List.generate(500, (i) {
      final cnic = (3520212345600 + i).toString();
      final hasVoted = i % 7 == 0; // ~14% already voted
      final isEligible = i % 20 != 0; // ~95% eligible

      return Voter(
        id: cnic,
        name: names[i % names.length],
        fatherName: fatherNames[i % fatherNames.length],
        cnic: cnic,
        address: addresses[i % addresses.length],
        stationId: stationId,
        isEligible: isEligible,
        hasVoted: hasVoted,
        votedAt: hasVoted
            ? DateTime.now().subtract(Duration(hours: i % 24))
            : null,
        photoUrl: i % 5 == 0 ? "https://i.pravatar.cc/150?img=${i % 70}" : null,
      );
    });
    notifyListeners();
  }

  // Methods for Firebase integration (to be implemented later)
  Future<void> fetchVotersFromFirebase() async {
    // TODO: Implement Firebase fetch
  }

  Future<void> updateVoterInFirebase(Voter voter) async {
    // TODO: Implement Firebase update
  }
}
