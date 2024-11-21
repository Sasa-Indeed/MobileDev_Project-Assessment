import 'package:hedieaty_app/database/databaseVersionControl.dart';
import 'package:hedieaty_app/models/user.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class UserDatabaseServices {

  // Get the database instance
  static Future<Database> _getDB() async {
    return openDatabase(
      join(await getDatabasesPath(), DatabaseVersionControl.dbName),
      version: DatabaseVersionControl.version,
      onCreate: (db, version) async {
        // Create the User table
        await db.execute("""
          CREATE TABLE IF NOT EXISTS User (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL,
            phoneNumber TEXT NOT NULL,
            isNotificationEnabled INTEGER NOT NULL
          );
        """);

        // Create the Preferences table
        await db.execute("""
          CREATE TABLE IF NOT EXISTS Preferences (
            userId INTEGER NOT NULL,
            preference TEXT NOT NULL,
            PRIMARY KEY (userId, preference),
            FOREIGN KEY (userId) REFERENCES User(id) ON DELETE CASCADE
          );
        """);
      },
    );
  }

  // Insert a user and their preferences
  static Future<int> insertUser(User user) async {
    final db = await _getDB();

    // Start a transaction
    return await db.transaction((txn) async {
      // Insert the user
      int userId = await txn.insert(
        "User",
        {
          'name': user.name,
          'email': user.email,
          'phoneNumber': user.phoneNumber,
          'isNotificationEnabled': user.isNotificationEnabled ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insert preferences
      for (String preference in user.preferences) {
        await txn.insert(
          "Preferences",
          {'userId': userId, 'preference': preference},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      return userId;
    });
  }

  // Update a user and their preferences
  static Future<int> updateUser(User user) async {
    final db = await _getDB();

    // Start a transaction
    return await db.transaction((txn) async {
      // Update the user
      int updated = await txn.update(
        "User",
        {
          'name': user.name,
          'email': user.email,
          'phoneNumber': user.phoneNumber,
          'isNotificationEnabled': user.isNotificationEnabled ? 1 : 0,
        },
        where: "id = ?",
        whereArgs: [user.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Clear old preferences
      await txn.delete("Preferences", where: "userId = ?", whereArgs: [user.id]);

      // Insert new preferences
      for (String preference in user.preferences) {
        await txn.insert(
          "Preferences",
          {'userId': user.id, 'preference': preference},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      return updated;
    });
  }

  // Delete a user and their preferences
  static Future<int> deleteUser(int userId) async {
    final db = await _getDB();
    return await db.delete("User", where: "id = ?", whereArgs: [userId]);
  }

  // Get all users with their preferences
  static Future<List<User>> getAllUsers() async {
    final db = await _getDB();

    // Get users
    final List<Map<String, dynamic>> userMaps = await db.query("User");

    if (userMaps.isEmpty) return [];

    // Generate User objects with their preferences
    List<User> users = [];
    for (var userMap in userMaps) {
      // Get preferences for the user
      final List<Map<String, dynamic>> preferenceMaps = await db.query(
        "Preferences",
        where: "userId = ?",
        whereArgs: [userMap['id']],
      );

      List<String> preferences =
      preferenceMaps.map((map) => map['preference'] as String).toList();

      users.add(User(
        id: userMap['id'],
        name: userMap['name'],
        email: userMap['email'],
        phoneNumber: userMap['phoneNumber'],
        isNotificationEnabled: userMap['isNotificationEnabled'] == 1,
        preferences: preferences,
      ));
    }

    return users;
  }
}
