import 'package:hedieaty_app/database/databaseVersionControl.dart';
import 'package:hedieaty_app/models/notifications.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class NotificationDatabaseServices {

  // Insert a notification
  static Future<int> insertNotification(Notifications notification) async {
    final db = await DatabaseVersionControl.getDB();
    return await db.insert(
      "Notifications",
      notification.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update a notification
  static Future<int> updateNotification(Notifications notification) async {
    final db = await DatabaseVersionControl.getDB();
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
    final db = await DatabaseVersionControl.getDB();
    return await db.delete("Notifications", where: "id = ?", whereArgs: [notificationId]);
  }

  // Get all notifications
  static Future<List<Notifications>> getAllNotifications() async {
    final db = await DatabaseVersionControl.getDB();

    final List<Map<String, dynamic>> notificationMaps = await db.query("Notifications");

    return List.generate(
      notificationMaps.length,
          (index) => Notifications.fromJson(notificationMaps[index]),
    );
  }

  // Get unread notifications
  static Future<List<Notifications>> getUnreadNotifications() async {
    final db = await DatabaseVersionControl.getDB();

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
