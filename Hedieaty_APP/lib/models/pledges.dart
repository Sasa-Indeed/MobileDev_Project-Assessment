import 'package:cloud_firestore/cloud_firestore.dart';

class Pledges{
  final int? id;
  final int giftID;
  final int userID;
  final int friendID;
  final DateTime dueDate;
  final String friendName;
  final String eventName;

  Pledges({required this.giftID,
          required this.userID,
          required this.friendID,
          required this.dueDate,
          required this.friendName,
          required this.eventName,
          this.id});

  factory Pledges.fromJson(Map<String, dynamic> json) => Pledges(
      id: json['id'],
      giftID: json['giftID'],
      userID: json['userID'],
      friendID: json['friendID'],
      dueDate: DateTime.parse(json['dueDate']),
      friendName: json['friendName'],
      eventName: json['eventName']
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'giftID': giftID,
    'userID': userID,
    'friendID': friendID,
    'dueDate': dueDate.toIso8601String(),
    'friendName': friendName,
    'eventName': eventName
  };


  // Convert Firestore data to a Pledges object
  factory Pledges.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Pledges(
        giftID: data['giftID'],
        userID: data['userID'],
        friendID: data['friendID'],
        dueDate: (data['dueDate'] as Timestamp).toDate(),
        friendName: data['friendName'],
        eventName: data['eventName']
    );
  }

  // Convert Gift object to Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'giftID': giftID,
      'userID': userID,
      'friendID': friendID,
      'dueDate': Timestamp.fromDate(dueDate),
      'friendName': friendName,
      'eventName': eventName
    };
  }

}