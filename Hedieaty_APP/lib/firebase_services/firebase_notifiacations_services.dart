import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty_app/models/notifications.dart';

class FirebaseNotificationsService {
  // Firestore collection reference
  static final CollectionReference notificationsCollection =
  FirebaseFirestore.instance.collection('notifications');

  /// Add a new notification
  static Future<void> addNotification(Notifications notification) async {
    try {
      await notificationsCollection.add(notification.toFirestore());
      print("Notification added successfully!");
    } catch (e) {
      print("Error adding notification: $e");
    }
  }

  /// Update an existing notification using receiverID and id
  static Future<void> updateNotification(
      int receiverID, int id, Notifications updatedNotification) async {
    try {
      QuerySnapshot snapshot = await notificationsCollection
          .where('receiverID', isEqualTo: receiverID)
          .where('id', isEqualTo: id)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.update(updatedNotification.toFirestore());
        print("Notification updated successfully!");
      }
    } catch (e) {
      print("Error updating notification: $e");
    }
  }

  /// Delete a notification using receiverID and id
  static Future<void> deleteNotification(int receiverID, int id) async {
    try {
      QuerySnapshot snapshot = await notificationsCollection
          .where('receiverID', isEqualTo: receiverID)
          .where('id', isEqualTo: id)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
        print("Notification deleted successfully!");
      }
    } catch (e) {
      print("Error deleting notification: $e");
    }
  }

  /// Fetch all notifications for a specific receiverID
  static Stream<List<Notifications>> getNotificationsByReceiverID(int receiverID) {
    return notificationsCollection
        .where('receiverID', isEqualTo: receiverID)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Notifications.fromFirestore(doc))
        .toList());
  }

  /// Fetch a single notification using receiverID and id
  static Future<Notifications?> getNotificationByReceiverIDAndID(
      int receiverID, int id) async {
    try {
      QuerySnapshot snapshot = await notificationsCollection
          .where('receiverID', isEqualTo: receiverID)
          .where('id', isEqualTo: id)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Notifications.fromFirestore(snapshot.docs.first);
      } else {
        print("Notification not found!");
        return null;
      }
    } catch (e) {
      print("Error fetching notification: $e");
      return null;
    }
  }
}
