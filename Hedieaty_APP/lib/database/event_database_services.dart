import 'package:hedieaty_app/database/databaseVersionControl.dart';
import 'package:hedieaty_app/models/event.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class EventDatabaseServices{

  // Get the database instance
  static Future<Database> _getDB() async {
    return openDatabase(
      join(await getDatabasesPath(), DatabaseVersionControl.dbName),
      version: DatabaseVersionControl.version,
      onCreate: (db, version) async {
        // Create the Event table
        await db.execute("""
          CREATE TABLE IF NOT EXISTS Event (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            date TEXT NOT NULL,
            location TEXT NOT NULL,
            description TEXT NOT NULL,
            userID TEXT NOT NULL,
            FOREIGN KEY (userId) REFERENCES User(id) ON DELETE CASCADE
          );
        """);
      },
    );
  }

  // Insert an event
  static Future<int> insertEvent(Event event) async {
    final db = await _getDB();
    return await db.insert("Event", event.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update an event
  static Future<int> updateEvent(Event event) async {
    final db = await _getDB();
    return await db.update(
      "Event", event.toJson(), where: "id = ?", whereArgs: [event.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Delete an event
  static Future<int> deleteEvent(int eventId) async {
    final db = await _getDB();
    return await db.delete("Event", where: "id = ?", whereArgs: [eventId]);
  }

  // Get all events for a user
  static Future<List<Event>> getEventsByUser(String userId) async {
    final db = await _getDB();

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
    final db = await _getDB();

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
