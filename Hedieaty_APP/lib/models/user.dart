import 'package:cloud_firestore/cloud_firestore.dart';

class Userdb{
  final int id;
  String name;
  List<String> preferences;
  String email;
  final String password;
  String phoneNumber;
  String profileImagePath;
  bool isNotificationEnabled;


  Userdb({required this.id,
        required this.name,
        required this.preferences,
        required this.email,
        required this.password,
        required this.phoneNumber,
        required this.profileImagePath,
        required this.isNotificationEnabled,
        });

  factory Userdb.fromJson(Map<String, dynamic> json) => Userdb(
      id: json['id'],
      name: json['name'],
      preferences: [],
      email: json['email'],
      password: json['password'],
      phoneNumber: json['phoneNumber'],
      profileImagePath: json['profileImagePath'],
      isNotificationEnabled: json['isNotificationEnabled'] == 1,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
    'phoneNumber': phoneNumber,
    'profileImagePath': profileImagePath,
    'isNotificationEnabled': isNotificationEnabled ? 1 : 0,
  };


  factory Userdb.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Userdb(
      id: data['id'],
      name: data['name'] ?? '',
      preferences: data['preferences'] != null
          ? List<String>.from(data['preferences'])
          : [],
      email: data['email'] ?? '',
      password: '', // Avoid storing password from Firestore
      phoneNumber: data['phoneNumber'] ?? '',
      profileImagePath: data['profileImagePath'] ?? '',
      isNotificationEnabled: data['isNotificationEnabled'] ?? false,
    );
  }

  // Convert Userdb object to Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImagePath': profileImagePath,
      'isNotificationEnabled': isNotificationEnabled,
      'preferences': preferences,
    };
  }


}