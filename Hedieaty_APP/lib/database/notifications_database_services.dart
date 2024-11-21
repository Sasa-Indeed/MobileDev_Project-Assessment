import 'package:hedieaty_app/database/databaseVersionControl.dart';
import 'package:hedieaty_app/models/notifications.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class NotificationDatabaseServices {
  static const int _version = 1;
  static const String _dbName = "AppDatabase.db";

  static Future<Database> _getDB() async {
    return openDatabase(
      join(await getDatabasesPath(), DatabaseVersionControl.dbName),
      version: DatabaseVersionControl.version,
      onCreate: (db, version) async {
        await db.execute("""
          CREATE TABLE Notifications (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            body TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            status INTEGER NOT NULL
          );
        """);
      },
    );
  }

  // Insert a notification
  static Future<int> insertNotification(Notifications notification) async {
    final db = await _getDB();
    return await db.insert(
      "Notifications",
      notification.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update a notification
  static Future<int> updateNotification(Notifications notification) async {
    final db = await _getDB();
    return await db.update(
      "Notifications",
      notification.toJson(),
      where: "id = ?",
      whereArgs: [notification.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Delete a notification
  static Future<int> deleteNotification(int notificationId) async {
    final db = await _getDB();
    return await db.delete("Notifications", where: "id = ?", whereArgs: [notificationId]);
  }

  // Get all notifications
  static Future<List<Notifications>> getAllNotifications() async {
    final db = await _getDB();

    final List<Map<String, dynamic>> notificationMaps = await db.query("Notifications");

    return List.generate(
      notificationMaps.length,
          (index) => Notifications.fromJson(notificationMaps[index]),
    );
  }

  // Get unread notifications
  static Future<List<Notifications>> getUnreadNotifications() async {
    final db = await _getDB();

    final List<Map<String, dynamic>> notificationMaps = await db.query(
      "Notifications",
      where: "status = ?",
      whereArgs: [0], // Unread
    );

    return List.generate(
      notificationMaps.length,
          (index) => Notifications.fromJson(notificationMaps[index]),
    );
  }
}
