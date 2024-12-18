import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty_app/models/event.dart';

class FirebaseEventService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _eventCollection = _firestore.collection('event');

  /// Save a new event to Firebase
  static Future<void> addEventToFirebase(Event event) async {
    try {
      await _eventCollection.add(event.toFirestore());
    } catch (e) {
      throw Exception('Failed to add event: $e');
    }
  }


  /// Get events for a specific user from Firebase
  static Future<List<Event>> getEventsByUserID(int userID) async {
    try {
      QuerySnapshot snapshot =
      await _eventCollection.where('userID', isEqualTo: userID).get();

      List<Event> events = snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();

      if(events.isEmpty){
        [];
      }

      return events;
    } catch (e) {
      throw Exception('Failed to fetch events: $e');
    }
  }

  /// Delete a gift from Firestore by its `id` field
  static Future<void> deleteEventByID(int eventID) async {
    try {
      QuerySnapshot snapshot = await _eventCollection.where('id', isEqualTo: eventID).get();

      if (snapshot.docs.isEmpty) {
        throw Exception('Event not found in Firestore.');
      }

      // Delete the first matching document
      await snapshot.docs.first.reference.delete();
    } catch (e) {
      throw Exception('Failed to delete: $e');
    }
  }


  static Future<void> updateEventInFirestore(Event event) async {
    try {
      QuerySnapshot snapshot = await _eventCollection
      .where('userID', isEqualTo: event.userID)
      .where('id', isEqualTo: event.id)
      .limit(1)
      .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('Event not found in Firestore.');
      }

      // Update the first matching document
      await snapshot.docs.first.reference.update(event.toFirestore());
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

}
