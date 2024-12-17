import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty_app/database/user_database_services.dart';
import 'package:hedieaty_app/firebase_services/firebase_user_services.dart';
import 'package:hedieaty_app/models/user.dart';

class FirebaseAuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Signup with Email and Password
  Future<Userdb?> signupUser({
    required String name,
    required String email,
    required String password,
    required String phone,
    required List<String> preferences,
    required String profileImagePath,
    required bool isNotificationEnabled,
  }) async {
    try {
      // Create Firebase user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get Firebase user ID
      String firebaseUserId = userCredential.user!.uid;
      int userid = DateTime.now().millisecondsSinceEpoch;

      // Insert user into local database
      Userdb user = Userdb(
        id: userid,
        name: name,
        email: email,
        password: password,
        phoneNumber: phone,
        isNotificationEnabled: isNotificationEnabled,
        preferences: preferences,
        profileImagePath: profileImagePath,
      );

      int localUserId = await UserDatabaseServices.insertUser(user);

      if (localUserId < 0) {
        throw Exception("User already exists in the local database. Try changing email or phone number");
      }
      List<int> friends = [];

      //Get the device token for the user
      //String? deviceToken = await FirebaseCM2.getDeviceToken();

      // Update Firebase Firestore with user data
      await _firestore.collection("users").doc(firebaseUserId).set({
        "id": localUserId, // Use the local DB ID as the user ID
        "name": name,
        "email": email,
        "friendIDs": friends,
        "phoneNumber": phone,
        "preferences": preferences,
        "profileImagePath": profileImagePath,
        "isNotificationEnabled": isNotificationEnabled,
      });

      return user;
    } catch (e) {
      throw Exception("Failed to register user: $e");
    }
  }

  /// Login with Email and Password
  Future<Userdb?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // Authenticate Firebase user
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String firebaseUserId = userCredential.user!.uid;

      // Fetch user data from local database
      Userdb? user = await UserDatabaseServices.getUserByEmail(email, password);

      user ??= await FirebaseUserServices.fetchUserById(await FirebaseUserServices.findUserByEmail(email));

      if(user == null){
        throw Exception("User not found in database");
      }

      await UserDatabaseServices.insertUser(user);

      // Ensure Firebase and local DB IDs match
      DocumentSnapshot firestoreDoc =
      await _firestore.collection("users").doc(firebaseUserId).get();
      if (firestoreDoc.exists) {
        final firestoreData = firestoreDoc.data() as Map<String, dynamic>;
        if (firestoreData["id"] != user.id) {
          throw Exception("User ID mismatch between Firebase and local database.");
        }
      }

      return user;
    } catch (e) {
      throw Exception("Failed to log in user: $e");
    }
  }
}
