import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty_app/models/gift.dart';

class FirebaseGiftService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _giftCollection = _firestore.collection('gift');

  /// Get all gifts for a specific user from Firestore (once)
  static Future<List<Gift>> getGiftsByUserID(int userID) async {
    try {
      QuerySnapshot snapshot = await _giftCollection.where('userID', isEqualTo: userID).get();
      return snapshot.docs.map((doc) => Gift.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch gifts for user $userID: $e');
    }
  }

  /// Add a new gift to Firestore with auto-generated document ID
  static Future<void> addGiftToFirestore(Gift gift) async {
    try {
      await _giftCollection.add(gift.toFirestore());
    } catch (e) {
      throw Exception('Failed to add gift for user ${gift.userID}: $e');
    }
  }

  /// Get all gifts for a specific user from Firestore (once)
  static Future<bool> findGiftsByID(Gift gift) async {
    try {
      QuerySnapshot snapshot = await _giftCollection
          .where('id', isEqualTo: gift.id)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return false;
      }

      return true;
    } catch (e) {
      throw Exception('Failed to find gift: $e');
      return false;
    }
  }

  /// Update an existing gift in Firestore
  /// Finds the gift by its `id` field and updates it
  static Future<void> updateGiftInFirestore(Gift gift) async {
    try {
      QuerySnapshot snapshot = await _giftCollection.where('id', isEqualTo: gift.id).get();

      if (snapshot.docs.isEmpty) {
        throw Exception('Gift with id ${gift.id} not found in Firestore.');
      }

      // Update the first matching document
      await snapshot.docs.first.reference.update(gift.toFirestore());
    } catch (e) {
      throw Exception('Failed to update gift for user ${gift.userID}: $e');
    }
  }

  /// Delete a gift from Firestore by its `id` field
  static Future<void> deleteGiftByID(Gift gift) async {
    try {
      QuerySnapshot snapshot = await _giftCollection
          .where('id', isEqualTo: gift.id)
          .where('userID', isEqualTo: gift.userID)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('Gift not found in Firestore.');
      }

      // Delete the first matching document
      await snapshot.docs.first.reference.delete();
    } catch (e) {
      throw Exception('Failed to delete: $e');
    }
  }

  /// Get all gifts for a specific user from Firestore (real-time stream)
  static Stream<List<Gift>> getGiftsStreamByUserID(int userID) {
    return _giftCollection
        .where('userID', isEqualTo: userID)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Gift.fromFirestore(doc)).toList();
    });
  }
}
