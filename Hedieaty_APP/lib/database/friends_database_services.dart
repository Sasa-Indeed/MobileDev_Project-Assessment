import 'package:flutter/foundation.dart';
import 'package:hedieaty_app/database/databaseVersionControl.dart';
import 'package:hedieaty_app/database/user_database_services.dart';
import 'package:hedieaty_app/firebase_services/firebase_friend_services.dart';
import 'package:hedieaty_app/firebase_services/firebase_user_services.dart';
import 'package:hedieaty_app/models/friends.dart';
import 'package:hedieaty_app/models/user.dart';
import 'package:sqflite/sqflite.dart';

class FriendsDatabaseServices{

  static Future<int> insertFriend(Friend friend) async {
    final db = await DatabaseVersionControl.getDB();
    return await db.insert("Friends", friend.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> updateFriend(Friend friend) async{
    final db = await DatabaseVersionControl.getDB();
    return await db.update("Friends", friend.toJson(), where: "id = ?" ,whereArgs: [friend.userID],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> deleteFriend(Friend friend) async{
    final db = await DatabaseVersionControl.getDB();
    return await db.delete("Friends", where: "id = ?" ,whereArgs: [friend.userID]);
  }

  static Future<List<Friend>> getAllFriends() async{
    final db = await DatabaseVersionControl.getDB();

    final List<Map<String, dynamic>> maps = await db.query("Friends");

    if(maps.isEmpty){
      return [];
    }

    return List.generate(maps.length, (index) => Friend.fromJson(maps[index]));
  }

  static Future<List<int>> getFriendsIDs(int userID) async{
    final db = await DatabaseVersionControl.getDB();

    final List<Map<String, dynamic>> maps = await db.query(
        "Friends",
        where: "userID = ? OR friendID = ?",
        whereArgs: [userID, userID]);

    if(maps.isEmpty){
      return [];
    }

    List<Friend> friends = List.generate(maps.length, (index) => Friend.fromJson(maps[index]));
    List<int> friendsIDs = [];

    for(Friend friend in friends){
      if(friend.userID == userID){
        friendsIDs.add(friend.friendID);
      }else{
        friendsIDs.add(friend.userID);
      }
    }


    return friendsIDs;
  }

  static Future<int> checkFriendExists(int userID, int friendID) async {
    final db = await DatabaseVersionControl.getDB();
    final List<Map<String, dynamic>> result = await db.query(
      "Friends",
      where: "userID = ? AND friendID = ?",
      whereArgs: [userID, friendID],
    );

    final List<Map<String, dynamic>> result2 = await db.query(
      "Friends",
      where: "userID = ? AND friendID = ?",
      whereArgs: [friendID, userID],
    );

    if (result.isNotEmpty || result2.isNotEmpty) {
      return friendID; // Friend  exists
    }

    return -1; // Friend does not exist
  }

  static Future<void> syncDeleteFriend(int userID, int friendID) async {
    try {
      final db = await DatabaseVersionControl.getDB();
      await db.database.delete('friends', where: 'userID = ? AND friendID = ?', whereArgs: [userID, friendID]);
      await db.database.delete('friends', where: 'userID = ? AND friendID = ?', whereArgs: [friendID, userID]);
      //print("Deleted friend $friendID for user $userID from local database"); // Placeholder
    } catch (e) {
      //print("Error deleting friend locally: $e");
    }
  }

  /// Sync local database with Firestore friends.
  static Future<void> syncLocalDatabase(int userID) async {
    try {
      // Ensure the friendIDs field exists in Firebase
      await FirebaseFriendServices.initializeFriendIDsField(userID);

      // Fetch friend IDs from Firebase and the local database
      List<int> firebaseFriendIDs = await FirebaseFriendServices.getFriendsFromFirestore(userID);
      List<int> localFriendIDs = await getFriendsIDs(userID);

      // Merge the two lists
      Set<int> allFriendIDs = {...firebaseFriendIDs, ...localFriendIDs};

      for(int i in allFriendIDs){
        print("$i \n");
      }

      // Update Firebase if there are new friends locally not present in Firebase
      if (!listEquals(firebaseFriendIDs, allFriendIDs.toList())) {
        await FirebaseFriendServices.updateFriendsInFirestore(userID, allFriendIDs.toList());
      }

      // Update local database if there are new friends in Firebase not present locally
      for (int friendID in allFriendIDs) {
        if (!localFriendIDs.contains(friendID)) {
          await insertFriend(Friend(userID: userID, friendID: friendID));
        }
      }

      // Remove friends from the local database that are no longer in Firebase
      for (int friendID in localFriendIDs) {
        if (!firebaseFriendIDs.contains(friendID)) {
          await syncDeleteFriend(userID, friendID);
        }
      }

      localFriendIDs = await getFriendsIDs(userID);

      for(int friendID in localFriendIDs){
        if(!await UserDatabaseServices.checkUserByID(friendID)){
          Userdb? user = await FirebaseUserServices.fetchUserById(friendID);
          if(user != null){
            UserDatabaseServices.insertUser(user);
          }
        }
      }

    } catch (e) {
      print("Error syncing local database: $e");
    }
  }



}