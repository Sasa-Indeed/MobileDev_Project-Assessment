import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty_app/models/gift.dart';

class FirestoreGiftService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _giftCollection = _firestore.collection('gift');

  /// Get all gifts for a specific user from Firestore
  static Future<List<Gift>> getGiftsByUserID(int userID) async {
    try {
      QuerySnapshot snapshot = await _giftCollection.where('userID', isEqualTo: userID).get();
      return snapshot.docs.map((doc) => Gift.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch gifts for user $userID: $e');
    }
  }

  /// Add a new gift to Firestore using its local ID as the Firestore document ID
  static Future<void> addGiftToFirestore(Gift gift) async {
    try {
      await _giftCollection.doc(gift.id.toString()).set(gift.toFirestore());
    } catch (e) {
      throw Exception('Failed to add gift for user ${gift.userID}: $e');
    }
  }

  /// Update an existing gift in Firestore
  static Future<void> updateGiftInFirestore(Gift gift) async {
    try {
      await _giftCollection.doc(gift.id.toString()).update(gift.toFirestore());
    } catch (e) {
      throw Exception('Failed to update gift for user ${gift.userID}: $e');
    }
  }
}

