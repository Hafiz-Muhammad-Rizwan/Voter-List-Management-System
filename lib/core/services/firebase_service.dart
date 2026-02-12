import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/station.dart';
import '../../models/user.dart';
import '../../models/voter.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Station Operations
  Future<List<Station>> getStations() async {
    try {
      final snapshot = await _firestore.collection('stations').get();
      return snapshot.docs.map((doc) => Station.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to load stations: $e');
    }
  }

  Future<void> addStation(Station station) async {
    try {
      await _firestore
          .collection('stations')
          .doc(station.id)
          .set(station.toJson());
    } catch (e) {
      throw Exception('Failed to add station: $e');
    }
  }

  Future<void> updateStation(Station station) async {
    try {
      await _firestore
          .collection('stations')
          .doc(station.id)
          .update(station.toJson());
    } catch (e) {
      throw Exception('Failed to update station: $e');
    }
  }

  Future<void> deleteStation(String stationId) async {
    try {
      // Also remove any officer assignments to this station
      final users = await _firestore
          .collection('users')
          .where('station_id', isEqualTo: stationId)
          .get();

      final batch = _firestore.batch();

      // Update users to remove station assignment
      for (var doc in users.docs) {
        batch.update(doc.reference, {'station_id': FieldValue.delete()});
      }

      // Delete the station
      batch.delete(_firestore.collection('stations').doc(stationId));

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete station: $e');
    }
  }

  // User Operations
  Future<List<User>> getUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) => User.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  Future<void> addUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toJson());
    } catch (e) {
      throw Exception('Failed to add user: $e');
    }
  }

  Future<void> updateUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toJson());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  Future<void> assignOfficerToStation(
    String officerId,
    String stationId,
  ) async {
    try {
      // Remove officer from any previous station
      await _firestore.collection('users').doc(officerId).update({
        'station_id': stationId,
      });

      // Update station with officer assignment
      await _firestore.collection('stations').doc(stationId).update({
        'assigned_officer_id': officerId,
      });
    } catch (e) {
      throw Exception('Failed to assign officer: $e');
    }
  }

  // Voter Operations
  Future<List<Voter>> getVoters({String? stationId}) async {
    try {
      Query query = _firestore.collection('voters');
      if (stationId != null) {
        query = query.where('station_id', isEqualTo: stationId);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => Voter.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load voters: $e');
    }
  }

  Future<void> addVoter(Voter voter) async {
    try {
      await _firestore.collection('voters').doc(voter.id).set(voter.toJson());
    } catch (e) {
      throw Exception('Failed to add voter: $e');
    }
  }

  Future<void> addVotersBatch(List<Voter> voters) async {
    try {
      final batch = _firestore.batch();

      for (var voter in voters) {
        final docRef = _firestore.collection('voters').doc(voter.id);
        batch.set(docRef, voter.toJson());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to import voters: $e');
    }
  }

  Future<void> updateVoter(Voter voter) async {
    try {
      await _firestore
          .collection('voters')
          .doc(voter.id)
          .update(voter.toJson());
    } catch (e) {
      throw Exception('Failed to update voter: $e');
    }
  }

  Future<void> markVoterAsVoted(String voterId) async {
    try {
      await _firestore.collection('voters').doc(voterId).update({
        'has_voted': true,
        'voted_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to mark voter as voted: $e');
    }
  }

  Future<void> deleteVoter(String voterId) async {
    try {
      await _firestore.collection('voters').doc(voterId).delete();
    } catch (e) {
      throw Exception('Failed to delete voter: $e');
    }
  }

  // Search Operations
  Future<List<User>> searchOfficers(String query) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'officer')
          .get();

      final officers = snapshot.docs
          .map((doc) => User.fromJson(doc.data()))
          .toList();

      // Filter by name or email containing query (case insensitive)
      return officers
          .where(
            (officer) =>
                officer.name.toLowerCase().contains(query.toLowerCase()) ||
                officer.email.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to search officers: $e');
    }
  }
}
