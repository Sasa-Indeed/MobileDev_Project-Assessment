import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:hedieaty_app/models/notifications.dart';
import 'package:hedieaty_app/database/notifications_database_services.dart';


void main() {
  setUpAll(() {
    // Initialize the FFI database factory
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('Test Notifications CRUD Operations', () async {


    // Insert a notification
    final newNotification = Notifications(
      title: "Welcome",
      body: "This is your first notification!",
      timestamp: DateTime.now(),
      status: false, // Unread
    );

    // Test insertion
    final notificationId = await NotificationDatabaseServices.insertNotification(newNotification);
    expect(notificationId, greaterThan(0));

    // Test retrieval
    final allNotifications = await NotificationDatabaseServices.getAllNotifications();
    expect(allNotifications.length, 1);
    expect(allNotifications.first.title, newNotification.title);

    // Test update
    final updatedNotification = Notifications(
      id: notificationId,
      title: "Updated Title",
      body: newNotification.body,
      timestamp: newNotification.timestamp,
      status: true, // Read
    );
    final rowsUpdated = await NotificationDatabaseServices.updateNotification(updatedNotification);
    expect(rowsUpdated, 1);

    // Verify the update
    final updatedNotifications = await NotificationDatabaseServices.getAllNotifications();
    expect(updatedNotifications.first.title, "Updated Title");
    expect(updatedNotifications.first.status, true);

    // Test unread filter
    final unreadNotifications = await NotificationDatabaseServices.getUnreadNotifications();
    expect(unreadNotifications.length, 0);

    // Test delete
    final rowsDeleted = await NotificationDatabaseServices.deleteNotification(notificationId);
    expect(rowsDeleted, 1);

    // Verify deletion
    final remainingNotifications = await NotificationDatabaseServices.getAllNotifications();
    expect(remainingNotifications.isEmpty, true);
  });
}
