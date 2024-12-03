import 'package:hedieaty_app/database/databaseVersionControl.dart';
import 'package:hedieaty_app/models/gift.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class GiftDatabaseServices{

    static Future<int> insertGift(Gift gift) async {
      final db = await DatabaseVersionControl.getDB();
      return await db.insert("Gift", gift.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    static Future<int> updateGift(Gift gift) async{
      final db = await DatabaseVersionControl.getDB();
      return await db.update("Gift", gift.toJson(), where: "id = ?" ,whereArgs: [gift.id],
      conflictAlgorithm: ConflictAlgorithm.replace);
    }

    static Future<int> deleteGift(Gift gift) async{
      final db = await DatabaseVersionControl.getDB();
      return await db.delete("Gift", where: "id = ?" ,whereArgs: [gift.id]);
    }

    static Future<List<Gift>> getAllGifts() async{
      final db = await DatabaseVersionControl.getDB();

      final List<Map<String, dynamic>> maps = await db.query("Gift");

      if(maps.isEmpty){
        return [];
      }
      
      return List.generate(maps.length, (index) => Gift.fromJson(maps[index]));
    }

}