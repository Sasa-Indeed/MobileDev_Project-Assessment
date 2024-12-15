import 'package:hedieaty_app/database/databaseVersionControl.dart';
import 'package:hedieaty_app/models/pledges.dart';
import 'package:sqflite/sqflite.dart';

class PledgeDatabaseServices {

  // Insert a pledge
  static Future<int> insertPledge(Pledges pledge) async {
    final db = await DatabaseVersionControl.getDB();
    return await db.insert("Pledges", pledge.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update a pledge
  static Future<int> updatePledge(Pledges pledge) async {
    final db = await DatabaseVersionControl.getDB();
    return await db.update("Pledges", pledge.toJson(), where: "id = ?", whereArgs: [pledge.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Delete a pledge
  static Future<int> deletePledge(int pledgeId) async {
    final db = await DatabaseVersionControl.getDB();
    return await db.delete("Pledges", where: "id = ?", whereArgs: [pledgeId]);
  }

  // Get all pledges
  static Future<List<Pledges>> getAllPledges() async {
    final db = await DatabaseVersionControl.getDB();

    final List<Map<String, dynamic>> pledgeMaps = await db.query("Pledges");

    return List.generate(pledgeMaps.length, (index) => Pledges.fromJson(pledgeMaps[index]));
  }

  // Get pledges by userID
  static Future<List<Pledges>> getPledgesByUserID(int userID) async {
    final db = await DatabaseVersionControl.getDB();

    final List<Map<String, dynamic>> pledgeMaps = await db.query("Pledges", where: "userID = ?", whereArgs: [userID]);

    return List.generate(pledgeMaps.length, (index) => Pledges.fromJson(pledgeMaps[index]));
  }

  // In PledgeDatabaseServices
  static Future<List<Pledges>> getPledgesByGiftID(int giftID) async {
    final db = await DatabaseVersionControl.getDB();
    final List<Map<String, dynamic>> pledgeMaps =
    await db.query("Pledges", where: "giftID = ?", whereArgs: [giftID]);

    if(pledgeMaps.isEmpty){
      return [];
    }

    return List.generate(pledgeMaps.length, (index) => Pledges.fromJson(pledgeMaps[index]));
  }

}
