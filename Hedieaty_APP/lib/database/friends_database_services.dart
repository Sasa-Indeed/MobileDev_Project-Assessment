import 'package:hedieaty_app/database/databaseVersionControl.dart';
import 'package:hedieaty_app/models/friends.dart';
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

    if (result.isEmpty) {
      return -1; // Friend does not exist
    }

    return friendID; // Friend exists
  }

}