import 'package:hedieaty_app/database/databaseVersionControl.dart';
import 'package:hedieaty_app/models/gift.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class GiftDatabaseServices{

    static Future<Database> _getDB() async{
      return openDatabase(join(await getDatabasesPath(), DatabaseVersionControl.dbName),
          version: DatabaseVersionControl.version,
      onCreate: (db, version) async =>
      await db.execute("""CREATE TABLE IF NOT EXISTS Gift (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          category TEXT NOT NULL,
          price REAL NOT NULL,
          status TEXT NOT NULL,
          eventID INTEGER NOT NULL,
          imagePath TEXT,
          FOREIGN KEY (eventID) REFERENCES Event(id) ON DELETE CASCADE
      );
        """)
      );
    }

    static Future<int> insertGift(Gift gift) async {
      final db = await _getDB();
      return await db.insert("Gift", gift.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    static Future<int> updateGift(Gift gift) async{
      final db = await _getDB();
      return await db.update("Gift", gift.toJson(), where: "id = ?" ,whereArgs: [gift.id],
      conflictAlgorithm: ConflictAlgorithm.replace);
    }

    static Future<int> deleteGift(Gift gift) async{
      final db = await _getDB();
      return await db.delete("Gift", where: "id = ?" ,whereArgs: [gift.id]);
    }

    static Future<List<Gift>?> getAllGifts() async{
      final db = await _getDB();

      final List<Map<String, dynamic>> maps = await db.query("Gift");

      if(maps.isEmpty){
        return null;
      }
      
      return List.generate(maps.length, (index) => Gift.fromJson(maps[index]));
    }

}