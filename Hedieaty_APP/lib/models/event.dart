import 'package:cloud_firestore/cloud_firestore.dart';

class Event{
  int? id;
  final String name;
  final DateTime date;
  final String location;
  final String category;
  final String description;
  final int userID;

  Event({required this.name,
         required this.date,
         required this.location,
         required this.category,
         required this.description,
         required this.userID,
         this.id});

  factory Event.fromJson(Map<String, dynamic> json) => Event(
      id: json['id'],
      name: json['name'],
      date: DateTime.parse(json['date']),
      location: json['location'],
      category: json['category'],
      description: json['description'],
      userID: json['userID']
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'date': date.toIso8601String(),
    'location': location,
    'category': category,
    'description': description,
    'userID': userID
  };

  @override
  String toString() {
    return "{ID: $id Name: $name Date: $date Location: $location Category: $category Description: $description UserID: $userID}";
  }

  // Convert Firestore data to a Event object
  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Event(
      id: data['id'],
      name: data['name'],
      date: (data['date'] as Timestamp).toDate(),
      location: data['location'],
      description: data['description'],
      category: data['category'],
      userID: data['userID'],
    );
  }

  // Convert Event object to Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'date': Timestamp.fromDate(date),
      'location': location,
      'description': description,
      'category': category,
      'userID': userID,
    };
  }


}