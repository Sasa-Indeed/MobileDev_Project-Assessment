import 'package:hedieaty_app/database/databaseVersionControl.dart';
import 'package:hedieaty_app/models/user.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class UserDatabaseServices {

  static Future<int> insertUser(User user) async {
    final db = await DatabaseVersionControl.getDB();

    // Insert the user
    int userId = await db.insert("User", user.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);

    // Insert preferences
    for (String preference in user.preferences) {
      await db.insert(
        "Preferences",
        {'userId': userId, 'preference': preference},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    return userId;
  }

  // Update a user and their preferences
  static Future<int> updateUser(User user) async {
    final db = await DatabaseVersionControl.getDB();

    // Update the user
    int updated = await db.update("User", user.toJson(), where: "id = ?" ,  whereArgs: [user.id],
        conflictAlgorithm: ConflictAlgorithm.replace);

    //update preferences
    for (String preference in user.preferences) {
      await db.update(
          "Preferences",
          {'userId': user.id, 'preference': preference},
          where: "id = ?" ,  whereArgs: [user.id],
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    return updated;

  }

  // Delete a user and their preferences
  static Future<int> deleteUser(int userId) async {
    final db = await DatabaseVersionControl.getDB();
    return await db.delete("User", where: "id = ?", whereArgs: [userId]);
  }

  static Future<List<User>> getAllUsers() async {
    final db = await DatabaseVersionControl.getDB();

    // Fetch all users
    final List<Map<String, dynamic>> userMaps = await db.query("User");

    if (userMaps.isEmpty) return [];

    List<User> users = List.generate(
      userMaps.length,
          (index) => User.fromJson(userMaps[index]),
    );

    for (User user in users) {
      user.preferences = await _getUserPreferences(user.id!);
    }

    return users;
  }

  static Future<List<String>> _getUserPreferences(int userId) async {
    final db = await DatabaseVersionControl.getDB();

    final List<Map<String, dynamic>> preferenceMaps = await db.query(
      "Preferences",
      where: "userId = ?",
      whereArgs: [userId],
    );

    return preferenceMaps.map((map) => map['preference'] as String).toList();
  }

  static void testTable() async {
    final db = await DatabaseVersionControl.getDB();
    final result = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
    print("Tables: $result");
  }
}
