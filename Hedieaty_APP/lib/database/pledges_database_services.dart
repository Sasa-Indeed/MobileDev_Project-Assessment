import 'package:hedieaty_app/database/databaseVersionControl.dart';
import 'package:hedieaty_app/models/pledges.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class PledgeDatabaseServices {

  static Future<Database> _getDB() async {
    return openDatabase(
      join(await getDatabasesPath(), DatabaseVersionControl.dbName),
      version: DatabaseVersionControl.version,
      onCreate: (db, version) async {
        await db.execute("""
          CREATE TABLE IF NOT EXISTS Pledges (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            giftID INTEGER NOT NULL,
            userID INTEGER NOT NULL,
            friendID INTEGER NOT NULL,
            dueDate TEXT NOT NULL,
            FOREIGN KEY (giftID) REFERENCES Gift(id) ON DELETE CASCADE,
            FOREIGN KEY (userID) REFERENCES User(id) ON DELETE CASCADE,
            FOREIGN KEY (friendID) REFERENCES User(id) ON DELETE CASCADE
          );
        """);
      },
    );
  }

  // Insert a pledge
  static Future<int> insertPledge(Pledges pledge) async {
    final db = await _getDB();
    return await db.insert("Pledges", pledge.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update a pledge
  static Future<int> updatePledge(Pledges pledge) async {
    final db = await _getDB();
    return await db.update("Pledges", pledge.toJson(), where: "id = ?", whereArgs: [pledge.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Delete a pledge
  static Future<int> deletePledge(int pledgeId) async {
    final db = await _getDB();
    return await db.delete("Pledges", where: "id = ?", whereArgs: [pledgeId]);
  }

  // Get all pledges
  static Future<List<Pledges>> getAllPledges() async {
    final db = await _getDB();

    final List<Map<String, dynamic>> pledgeMaps = await db.query("Pledges");

    return List.generate(pledgeMaps.length, (index) => Pledges.fromJson(pledgeMaps[index]));
  }

  // Get pledges by userID
  static Future<List<Pledges>> getPledgesByUser(int userID) async {
    final db = await _getDB();

    final List<Map<String, dynamic>> pledgeMaps = await db.query("Pledges", where: "userID = ?", whereArgs: [userID]);

    return List.generate(pledgeMaps.length, (index) => Pledges.fromJson(pledgeMaps[index]));
  }
}
