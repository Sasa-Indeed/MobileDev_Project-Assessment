import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:hedieaty_app/models/pledges.dart';
import 'package:hedieaty_app/database/pledges_database_services.dart';

/*
void main() {
  // Initialize sqflite FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('Insert, retrieve, update, and delete Pledge', () async {
    // Use an in-memory database for testing
    final databaseFactory = databaseFactoryFfi;
    final db = await databaseFactory.openDatabase(inMemoryDatabasePath);

    // Create the Pledges table
    await db.execute("""
      CREATE TABLE Pledges (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          giftID INTEGER NOT NULL,
          userID INTEGER NOT NULL,
          friendID INTEGER NOT NULL,
          dueDate TEXT NOT NULL
      );
    """);

    // Insert a pledge
    final pledge = Pledges(
      giftID: 101,
      userID: 1,
      friendID: 2,
      dueDate: DateTime.parse("2024-12-25T10:00:00.000Z"),
    );

    final pledgeId = await db.insert('Pledges', pledge.toJson());
    expect(pledgeId, greaterThan(0));

    // Retrieve the inserted pledge
    final result = await db.query('Pledges', where: 'id = ?', whereArgs: [pledgeId]);
    final retrievedPledge = Pledges.fromJson(result.first);

    expect(retrievedPledge.giftID, pledge.giftID);
    expect(retrievedPledge.userID, pledge.userID);
    expect(retrievedPledge.dueDate, pledge.dueDate);

    // Update the pledge
    final updatedPledge = Pledges(
      id: pledgeId,
      giftID: 102,
      userID: 1,
      friendID: 3,
      dueDate: DateTime.parse("2024-12-31T10:00:00.000Z"),
    );

    final rowsUpdated = await db.update(
      'Pledges',
      updatedPledge.toJson(),
      where: 'id = ?',
      whereArgs: [pledgeId],
    );
    expect(rowsUpdated, 1);

    // Verify the update
    final updatedResult = await db.query('Pledges', where: 'id = ?', whereArgs: [pledgeId]);
    final updatedRetrievedPledge = Pledges.fromJson(updatedResult.first);

    expect(updatedRetrievedPledge.giftID, 102);
    expect(updatedRetrievedPledge.friendID, 3);

    // Delete the pledge
    final rowsDeleted = await db.delete('Pledges', where: 'id = ?', whereArgs: [pledgeId]);
    expect(rowsDeleted, 1);

    // Verify deletion
    final emptyResult = await db.query('Pledges', where: 'id = ?', whereArgs: [pledgeId]);
    expect(emptyResult.isEmpty, true);

    // Close the database
    await db.close();
  });
}
*/



