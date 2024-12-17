import 'package:cloud_firestore/cloud_firestore.dart';

class Notifications{

  int? id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool status; // Read ture - Unread false
  final int receiverID;

  Notifications({required this.title, required this.body, required this.timestamp,
    required this.status,required this.receiverID, this.id}); // Read (true) Unread (false)

  factory Notifications.fromJson(Map<String, dynamic> json) => Notifications(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      timestamp: DateTime.parse(json['timestamp']),
      status: json['status'] == 1,
      receiverID: json['receiverID'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'timestamp': timestamp.toIso8601String(),
    'status': status ? 1 : 0,
    'receiverID': receiverID,
  };

  // Convert Firestore data to a Notifications object
  factory Notifications.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Notifications(
        title: data['title'],
        body: data['body'],
        timestamp: (data['dueDate'] as Timestamp).toDate(),
        status: data['status'],
        receiverID: data['receiverID']
    );
  }

  // Convert Notifications object to Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      'status': status,
      'receiverID': receiverID,
      'timestamp': Timestamp.fromDate(timestamp)
    };
  }

}