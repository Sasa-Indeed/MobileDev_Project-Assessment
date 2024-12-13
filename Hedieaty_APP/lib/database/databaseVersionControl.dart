import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseVersionControl{
  static const int _version = 1;
  static const String _dbName = "Hedieaty.db";

  static Future<Database> getDB() async {
    return openDatabase(
      join(await getDatabasesPath(), _dbName),
      version: _version,
      onCreate: (db, version) async {
        // Create the User table
        await db.execute("""
          CREATE TABLE IF NOT EXISTS User (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL,
            phoneNumber TEXT NOT NULL UNIQUE,
            profileImagePath TEXT NOT NULL,
            isNotificationEnabled INTEGER NOT NULL
          );
        """);

        // Create the Preferences table
        await db.execute("""
          CREATE TABLE IF NOT EXISTS Preferences (
            userId INTEGER NOT NULL,
            preference TEXT NOT NULL,
            PRIMARY KEY (userId, preference),
            FOREIGN KEY (userId) REFERENCES User(id) ON DELETE CASCADE
          );
        """);

        // Create the Event table
        await db.execute("""
          CREATE TABLE IF NOT EXISTS Event (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            date TEXT NOT NULL,
            location TEXT NOT NULL,
            category TEXT NOT NULL,
            description TEXT NOT NULL,
            userID INTEGER NOT NULL,
            FOREIGN KEY (userId) REFERENCES User(id) ON DELETE CASCADE
          );
        """);

        // Create the Gift table
        await db.execute("""CREATE TABLE IF NOT EXISTS Gift (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          category TEXT NOT NULL,
          price REAL NOT NULL,
          status TEXT NOT NULL,
          eventID INTEGER NOT NULL,
          userID INTEGER NOT NULL,
          imagePath TEXT,
          FOREIGN KEY (eventID) REFERENCES Event(id) ON DELETE CASCADE
      );
        """);

        // Create the Friends table
        await db.execute("""CREATE TABLE IF NOT EXISTS Friends (
          userID INTEGER NOT NULL,
          friendID INTEGER NOT NULL,
          PRIMARY KEY (userID, friendID),
          FOREIGN KEY (userID) REFERENCES User(id) ON DELETE CASCADE,
          FOREIGN KEY (friendID) REFERENCES User(id) ON DELETE CASCADE
      );
        """);

        // Create the Pledges table
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

        // Create the Notifications table
        await db.execute("""
          CREATE TABLE IF NOT EXISTS Notifications (
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

  static Future<void> deleteDBs() async{
    await deleteDatabase(join(await getDatabasesPath(), _dbName));
  }

  static Future<void> initializeDatabase() async{
    await getDB();
  }

}