import 'package:hedieaty_app/database/databaseVersionControl.dart';
import 'package:hedieaty_app/models/friends.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class FriendsDatabaseServices{

  static Future<int> insertFriend(Friend friend) async {
    final db = await DatabaseVersionControl.getDB();
    return await db.insert("Friend", friend.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> updateFriend(Friend friend) async{
    final db = await DatabaseVersionControl.getDB();
    return await db.update("Friend", friend.toJson(), where: "id = ?" ,whereArgs: [friend.userID],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> deleteFriend(Friend friend) async{
    final db = await DatabaseVersionControl.getDB();
    return await db.delete("Friend", where: "id = ?" ,whereArgs: [friend.userID]);
  }

  static Future<List<Friend>?> getAllFriends() async{
    final db = await DatabaseVersionControl.getDB();

    final List<Map<String, dynamic>> maps = await db.query("Friend");

    if(maps.isEmpty){
      return null;
    }

    return List.generate(maps.length, (index) => Friend.fromJson(maps[index]));
  }
}