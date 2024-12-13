import 'package:hedieaty_app/database/databaseVersionControl.dart';
import 'package:hedieaty_app/models/user.dart';
import 'package:sqflite/sqflite.dart';

class UserDatabaseServices {

  static Future<int> insertUser(Userdb user) async {
    final db = await DatabaseVersionControl.getDB();
    int userId = -1;
    // Insert the user
    try{
      userId = await db.insert("User", user.toJson());
    } on DatabaseException catch(e){
      print("Error");
      return -1;
    }


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
  static Future<int> updateUser(Userdb user) async {
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

  static Future<List<Userdb>> getAllUsers() async {
    final db = await DatabaseVersionControl.getDB();

    // Fetch all users
    final List<Map<String, dynamic>> userMaps = await db.query("User");

    if (userMaps.isEmpty) return [];

    List<Userdb> users = List.generate(
      userMaps.length,
          (index) => Userdb.fromJson(userMaps[index]),
    );

    for (Userdb user in users) {
      user.preferences = await _getUserPreferences(user.id!);
    }

    return users;
  }

  static Future<int> findUserByPhoneNumber(String phoneNumber) async{
    final db = await DatabaseVersionControl.getDB(); // Assumes a function to connect to your database
    final List<Map<String, dynamic>> userResult = await db.query('User',  where: "phoneNumber = ?", whereArgs: [phoneNumber],);

    if(userResult.isEmpty){
      return -1;
    }

    final userData = userResult.first;

    Userdb user = Userdb.fromJson(userData);

    return user.id!;
  }

  static Future<int> findUserByEmail(String email) async{
    final db = await DatabaseVersionControl.getDB(); // Assumes a function to connect to your database
    final List<Map<String, dynamic>> userResult = await db.query('User',  where: "email = ?", whereArgs: [email],);

    if(userResult.isEmpty){
      return -1;
    }
    final userData = userResult.first;

    Userdb user = Userdb.fromJson(userData);

    return user.id!;
  }

  static Future<Userdb?> getUserByEmail(String email, String password) async {
    final db = await DatabaseVersionControl.getDB(); // Assumes a function to connect to your database
    final List<Map<String, dynamic>> userResult = await db.query(
      'User',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (userResult.isNotEmpty) {
      final userData = userResult.first;

      final List<String> preferences = await _getUserPreferences(userData['id']);

      Userdb user = Userdb.fromJson(userData);
      user.preferences = preferences;

      return user;
    }

    return null;
  }

  static Future<String> getUserProfileImagePath(int userID) async {
    final db = await DatabaseVersionControl.getDB(); // Assumes a function to connect to your database
    final List<Map<String, dynamic>> userResult = await db.query(
      'User',
      where: 'id = ?',
      whereArgs: [userID],
    );

    if (userResult.isNotEmpty) {
      final userData = userResult.first;

      Userdb user = Userdb.fromJson(userData);

      return user.profileImagePath;
    }

    return "";
  }

  static Future<String> getUserNameByID(int userID) async {
    final db = await DatabaseVersionControl.getDB(); // Assumes a function to connect to your database
    final List<Map<String, dynamic>> userResult = await db.query(
      'User',
      where: 'id = ?',
      whereArgs: [userID],
    );

    if (userResult.isNotEmpty) {
      final userData = userResult.first;

      Userdb user = Userdb.fromJson(userData);

      return user.name;
    }

    return "";
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



}
