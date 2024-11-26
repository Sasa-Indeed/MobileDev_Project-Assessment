import 'package:hedieaty_app/database/databaseVersionControl.dart';
import 'package:hedieaty_app/models/event.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class EventDatabaseServices{

  // Insert an event
  static Future<int> insertEvent(Event event) async {
    final db = await DatabaseVersionControl.getDB();
    return await db.insert("Event", event.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update an event
  static Future<int> updateEvent(Event event) async {
    final db = await DatabaseVersionControl.getDB();
    return await db.update(
      "Event", event.toJson(), where: "id = ?", whereArgs: [event.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Delete an event
  static Future<int> deleteEvent(int eventId) async {
    final db = await DatabaseVersionControl.getDB();
    return await db.delete("Event", where: "id = ?", whereArgs: [eventId]);
  }

  // Get all events for a user
  static Future<List<Event>> getEventsByUser(String userId) async {
    final db = await DatabaseVersionControl.getDB();

    final List<Map<String, dynamic>> eventMaps = await db.query(
      "Event",
      where: "userID = ?",
      whereArgs: [userId],
    );

    if (eventMaps.isEmpty) return [];

    return List.generate(
      eventMaps.length,
          (index) => Event.fromJson(eventMaps[index]),
    );
  }

  // Get an event by ID
  static Future<Event?> getEventById(int eventId) async {
    final db = await DatabaseVersionControl.getDB();

    final List<Map<String, dynamic>> eventMaps = await db.query(
      "Event",
      where: "id = ?",
      whereArgs: [eventId],
    );

    if (eventMaps.isEmpty){
      return null;
    }

    return Event.fromJson(eventMaps.first);
  }
}
