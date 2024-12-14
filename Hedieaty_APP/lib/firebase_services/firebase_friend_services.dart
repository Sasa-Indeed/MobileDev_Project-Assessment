import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseFriendServices {
  static final CollectionReference userCollection =
  FirebaseFirestore.instance.collection('users');

  /// Ensure the `friendIDs` field exists for a user.
  static Future<void> initializeFriendIDsField(int userID) async {
    try {
      // Query to find the user document where the id field matches userID
      QuerySnapshot querySnapshot = await userCollection
          .where('id', isEqualTo: userID)
          .limit(1)
          .get();

      // Check if a matching user document exists
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;

        // Check if the friendIDs field exists, if not, add it
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        if (!data.containsKey('friendIDs')) {
          await userDoc.reference.set({'friendIDs': []}, SetOptions(merge: true));
        }
      }
    } catch (e) {
      print("Error initializing friendIDs field in Firebase: $e");
    }
  }

  /// Add a friend ID to a user's `friendIDs` array in Firestore.
  static Future<void> addFriendToFirestore(int userID, int friendID) async {
    try {
      // Query to find the user document where the id field matches userID
      QuerySnapshot querySnapshot = await userCollection
          .where('id', isEqualTo: userID)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Get the first matching document
        DocumentSnapshot docSnap = querySnapshot.docs.first;
        DocumentReference docRef = docSnap.reference;

        // Extract existing friendIDs or use an empty list
        List<int> friendIDs = List<int>.from(docSnap['friendIDs'] ?? []);

        // Add friend ID if not already in the list
        if (!friendIDs.contains(friendID)) {
          friendIDs.add(friendID);
          await docRef.update({'friendIDs': friendIDs});
        }
      } else {
        // If no document found, you might want to handle this case
        throw Exception("No user found with ID: $userID");
      }
    } catch (e) {
      throw Exception("Failed to add friend to Firestore: $e");
    }
  }

  /// Retrieve the `friendIDs` array from Firestore.
  static Future<List<int>> getFriendsFromFirestore(int userID) async {
    try {
      // Query to find the user document where the id field matches userID
      QuerySnapshot querySnapshot = await userCollection
          .where('id', isEqualTo: userID)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot docSnap = querySnapshot.docs.first;
        return List<int>.from(docSnap['friendIDs'] ?? []);
      } else {
        return [];
      }
    } catch (e) {
      throw Exception("Failed to retrieve friends from Firestore: $e");
    }
  }

  /// Update the `friendIDs` array in Firestore for a user.
  static Future<void> updateFriendsInFirestore(int userID, List<int> friendIDs) async {
    try {
      // Query to find the user document where the id field matches userID
      QuerySnapshot querySnapshot = await userCollection
          .where('id', isEqualTo: userID)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference userDoc = querySnapshot.docs.first.reference;
        await userDoc.update({'friendIDs': friendIDs});
      } else {
        throw Exception("No user found with ID: $userID");
      }
    } catch (e) {
      print("Error updating friendIDs in Firebase: $e");
    }
  }

  /// Real-time listener for `friendIDs` array changes.
  static Stream<List<int>> friendsStream(int userID) {
    return userCollection
        .where('id', isEqualTo: userID)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return List<int>.from(snapshot.docs.first['friendIDs'] ?? []);
      } else {
        return [];
      }
    });
  }


}
