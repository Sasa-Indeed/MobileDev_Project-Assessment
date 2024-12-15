import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty_app/models/pledges.dart';

class FirebasePledgesService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _pledgeCollection = _firestore.collection('pledges');

  /// Get all pledges for a specific user from Firestore (once)
  static Future<List<Pledges>> getPledgesByUserID(int userID) async {
    try {
      QuerySnapshot snapshot = await _pledgeCollection.where('userID', isEqualTo: userID).get();
      return snapshot.docs.map((doc) => Pledges.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch pledges for user $userID: $e');
    }
  }

  /// Get all pledges for a specific gift ID (once)
  static Future<List<Pledges>> getPledgesByGiftID(int giftID) async {
    try {
      QuerySnapshot snapshot = await _pledgeCollection.where('giftID', isEqualTo: giftID).get();
      return snapshot.docs.map((doc) => Pledges.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch pledges for gift $giftID: $e');
    }
  }

  /// Add a new pledge to Firestore with auto-generated document ID
  static Future<void> addPledgeToFirestore(Pledges pledge) async {
    try {
      await _pledgeCollection.add(pledge.toFirestore());
    } catch (e) {
      throw Exception('Failed to add pledge: $e');
    }
  }

  /// Update an existing pledge in Firestore
  /// Finds the pledge by its `id` field and updates it
  static Future<void> updatePledgeInFirestore(Pledges pledge) async {
    try {
      QuerySnapshot snapshot = await _pledgeCollection.where('id', isEqualTo: pledge.id).get();

      if (snapshot.docs.isEmpty) {
        throw Exception('Pledge with id ${pledge.id} not found in Firestore.');
      }

      // Update the first matching document
      await snapshot.docs.first.reference.update(pledge.toFirestore());
    } catch (e) {
      throw Exception('Failed to update pledge with id ${pledge.id}: $e');
    }
  }

  /// Delete a pledge from Firestore by its `id` field
  static Future<void> deletePledgeByUserID(int userID) async {
    try {
      QuerySnapshot snapshot = await _pledgeCollection.where('userID', isEqualTo: userID).get();

      if (snapshot.docs.isEmpty) {
        throw Exception('Pledge not found in Firestore.');
      }

      // Delete the first matching document
      await snapshot.docs.first.reference.delete();
    } catch (e) {
      throw Exception('Failed to delete pledge: $e');
    }
  }

  /// Delete a pledge from Firestore by its `id` field
  static Future<void> deletePledgeByID(int pledgeID) async {
    try {
      QuerySnapshot snapshot = await _pledgeCollection.where('id', isEqualTo: pledgeID).get();

      if (snapshot.docs.isEmpty) {
        throw Exception('Pledge with id $pledgeID not found in Firestore.');
      }

      // Delete the first matching document
      await snapshot.docs.first.reference.delete();
    } catch (e) {
      throw Exception('Failed to delete pledge: $e');
    }
  }

  /// Get all pledges for a specific user from Firestore (real-time stream)
  static Stream<List<Pledges>> getPledgesStreamByUserID(int userID) {
    try {
      return _pledgeCollection
          .where('userID', isEqualTo: userID)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => Pledges.fromFirestore(doc)).toList());
    } catch (e) {
      throw Exception('Failed to fetch pledges stream for user $userID: $e');
    }
  }

  /// Get all pledges for a specific gift ID from Firestore (real-time stream)
  static Stream<List<Pledges>> getPledgesStreamByGiftID(int giftID) {
    try {
      return _pledgeCollection
          .where('giftID', isEqualTo: giftID)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => Pledges.fromFirestore(doc)).toList());
    } catch (e) {
      throw Exception('Failed to fetch pledges stream for gift $giftID: $e');
    }
  }
}
