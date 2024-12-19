import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty_app/models/user.dart';

class FirebaseUserServices {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _userCollection = _firestore.collection('users');

  static Future<Userdb?> fetchUserById(int userId) async {
    try {
      // Query the collection to find the document where id matches
      QuerySnapshot querySnapshot = await _userCollection
          .where('id', isEqualTo: userId)
          .limit(1)
          .get();

      // Check if a matching document exists
      if (querySnapshot.docs.isNotEmpty) {
        // Convert the first matching document to a Userdb object
        return Userdb.fromFirestore(querySnapshot.docs.first);
      }

      // Return null if no user is found
      return null;
    } catch (e) {
      // Log the error and return null
      print("Error fetching user by ID: $e");
      return null;
    }
  }

  /// Finds a user by email in Firestore.
  /// Returns the user ID if found, or -1 if not found.
  static Future<int> findUserByEmail(String email) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return (querySnapshot.docs.first.data() as Map<String, dynamic>)['id'] as int;
      }

      return -1; // User not found
    } catch (e) {
      print("Error finding user by email: $e");
      return -1; // Handle errors gracefully
    }
  }

  /// Finds a user by phone number in Firestore.
  /// Returns the user ID if found, or -1 if not found.
  static Future<int> findUserByPhoneNumber(String phoneNumber) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return (querySnapshot.docs.first.data() as Map<String, dynamic>)['id'] as int? ?? -1;
      }
      return -1; // User not found
    } catch (e) {
      print("Error finding user by phone number: $e");
      return -1; // Handle errors gracefully
    }
  }


  /// Checks if a phone number exits in the firebase or not
  /// Returns true if exits and false if does not exit
  static Future<bool> checkPhoneNumberExits(String phoneNumber) async {
    try {
      final QuerySnapshot querySnapshot = await _userCollection
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return true;
      }

      return false;
    } catch (e) {
      print("Error finding phone number: $e");
      return true; // Handle errors gracefully
    }
  }

}
