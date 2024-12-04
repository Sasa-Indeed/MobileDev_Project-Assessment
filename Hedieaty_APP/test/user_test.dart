import 'package:flutter_test/flutter_test.dart';
import 'package:hedieaty_app/database/databaseVersionControl.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:hedieaty_app/models/user.dart';
import 'package:hedieaty_app/database/user_database_services.dart';

void main() {

  setUpAll(() {
    // Initialize the FFI database factory
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });


  test('Test User CRUD Operations Insert operation', () async {

    DatabaseVersionControl.deleteDBs();

    final user = User(
      name: "John Doe",
      email: "johndoe@example.com",
      password: "sex",
      phoneNumber: "1234567890",
      isNotificationEnabled: true,
      preferences: ["Sports", "Technology", "Music"],
    );

    // Test insertion
    final userId = await UserDatabaseServices.insertUser(user);
    expect(userId, greaterThan(0));

    final user2 = User(
      name: "Sasa",
      email: "jondoe@example.com",
      password: "sex",
      phoneNumber: "1234567890",
      isNotificationEnabled: true,
      preferences: ["Sports", "Technology", "Music"],
    );

    // Test insertion
    final userId2 = await UserDatabaseServices.insertUser(user2);
    expect(userId2, greaterThan(0));

    /*List<User> users = await UserDatabaseServices.getAllUsers();

    print(users[0].name);*/

    // Create a user with preferences
    /*final user = User(
      name: "John Doe",
      email: "johndoe@example.com",
      phoneNumber: "1234567890",
      isNotificationEnabled: true,
      preferences: ["Sports", "Technology", "Music"],
    );

    // Test insertion
    final userId = await UserDatabaseServices.insertUser(user);
    expect(userId, greaterThan(0));

    // Test retrieval
    final allUsers = await UserDatabaseServices.getAllUsers();
    expect(allUsers.length, 4);
    final retrievedUser = allUsers.first;
    expect(retrievedUser.name, user.name);
    expect(retrievedUser.email, user.email);
    expect(retrievedUser.phoneNumber, user.phoneNumber);
    expect(retrievedUser.isNotificationEnabled, user.isNotificationEnabled);
    expect(
        List.from(retrievedUser.preferences)..sort((a, b) => a.compareTo(b)),
        List.from(user.preferences)..sort((a, b) => a.compareTo(b))
    );


    // Test update
    final updatedUser = User(
      id: retrievedUser.id,
      name: "Jane Doe",
      email: "janedoe@example.com",
      phoneNumber: "0987654321",
      isNotificationEnabled: false,
      preferences: ["Travel", "Cooking"], // New preferences
    );


    final rowsUpdated = await UserDatabaseServices.updateUser(updatedUser);
    expect(rowsUpdated, 1);

    // Verify the update
    final updatedUsers = await UserDatabaseServices.getAllUsers();
    expect(updatedUsers.length, 1);
    final updatedRetrievedUser = updatedUsers.first;
    expect(updatedRetrievedUser.name, "Jane Doe");
    expect(updatedRetrievedUser.email, "janedoe@example.com");
    expect(updatedRetrievedUser.phoneNumber, "0987654321");
    expect(updatedRetrievedUser.isNotificationEnabled, false);
    expect(updatedRetrievedUser.preferences, ["Travel", "Cooking"]);

    // Test deletion
    final rowsDeleted = await UserDatabaseServices.deleteUser(updatedRetrievedUser.id!);
    expect(rowsDeleted, 1);

    // Verify deletion
    final remainingUsers = await UserDatabaseServices.getAllUsers();
    expect(remainingUsers.isEmpty, true);*/
  });
}
