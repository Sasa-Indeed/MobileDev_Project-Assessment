import 'package:hedieaty_app/database/databaseVersionControl.dart';
import 'package:hedieaty_app/models/friends.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class FriendsDatabaseServices{
  static Future<Database> _getDB() async{
    return openDatabase(join(await getDatabasesPath(), DatabaseVersionControl.dbName),
        onCreate: (db, version) async =>
        await db.execute("""CREATE TABLE IF NOT EXISTS Friends (
          userID INTEGER NOT NULL,
          friendID INTEGER NOT NULL,
          PRIMARY KEY (userID, friendID),
          FOREIGN KEY (userID) REFERENCES User(id) ON DELETE CASCADE,
          FOREIGN KEY (friendID) REFERENCES User(id) ON DELETE CASCADE
      );
        """),
        version: DatabaseVersionControl.version
    );
  }

  static Future<int> insertFriend(Friend friend) async {
    final db = await _getDB();
    return await db.insert("Friend", friend.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> updateFriend(Friend friend) async{
    final db = await _getDB();
    return await db.update("Friend", friend.toJson(), where: "id = ?" ,whereArgs: [friend.userID],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> deleteFriend(Friend friend) async{
    final db = await _getDB();
    return await db.delete("Friend", where: "id = ?" ,whereArgs: [friend.userID]);
  }

  static Future<List<Friend>?> getAllFriends() async{
    final db = await _getDB();

    final List<Map<String, dynamic>> maps = await db.query("Friend");

    if(maps.isEmpty){
      return null;
    }

    return List.generate(maps.length, (index) => Friend.fromJson(maps[index]));
  }
}