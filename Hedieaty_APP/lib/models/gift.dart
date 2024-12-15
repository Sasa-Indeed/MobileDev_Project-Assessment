import 'package:cloud_firestore/cloud_firestore.dart';

class Gift {
  final int id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String status; // "Pending" or "Pledged"
  final int eventID;
  final int userID;
  final String? imagePath; // Local path for the image, nullable
  String eventName;
  DateTime dueDate;

  Gift({required this.name, required this.description, required this.category,
  required this.price, required this.status, required this.eventID, required this.userID,
  required this.id, this.imagePath, required this.dueDate, required this.eventName});

  factory Gift.fromJson(Map<String, dynamic> json) => Gift(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    category: json['category'],
    price: json['price'],
    status: json['status'],
    eventID: json['eventID'],
    userID: json['userID'],
    imagePath: json['imagePath'],
    eventName: json['eventName'],
    dueDate: DateTime.parse(json['dueDate'])
  );

  Map<String, dynamic> toJson() => {
  'id': id,
  'name': name,
  'description': description,
  'category': category,
  'price': price,
  'status': status,
  'eventID': eventID,
  'userID': userID,
  'imagePath': imagePath,
  'eventName':eventName,
  'dueDate': dueDate.toIso8601String()
  };

  Gift copyWith({int? id, String? name, String? description, String? category,
    double? price, String? status, int? eventID, int? userID,String? imagePath,}) {
    return Gift(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      status: status ?? this.status,
      eventID: eventID ?? this.eventID,
      userID: userID ?? this.userID,
      imagePath: imagePath ?? this.imagePath,
      eventName: eventName ?? this.eventName,
      dueDate:  dueDate ?? this.dueDate
    );
  }

  // Convert Firestore data to a Gift object
  factory Gift.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Gift(
      id: data['id'],
      name: data['name'],
      description: data['description'],
      category: data['category'],
      price: data['price'],
      status: data['status'],
      eventID: data['eventID'],
      userID: data['userID'],
      imagePath: data['imagePath'],
      eventName: data['eventName'],
      dueDate: (data['dueDate'] as Timestamp).toDate()
    );
  }

  // Convert Gift object to Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'status': status,
      'eventID': eventID,
      'userID': userID,
      'imagePath': imagePath,
      'eventName': eventName,
      'dueDate': Timestamp.fromDate(dueDate)
    };
  }


}