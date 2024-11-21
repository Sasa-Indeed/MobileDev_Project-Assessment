class User{
  final int? id;
  final String name;
  final List<String> preferences;
  final String email;
  final String phoneNumber;
  final bool isNotificationEnabled;


  User({required this.name,
        required this.preferences,
        required this.email,
        required this.phoneNumber,
        required this.isNotificationEnabled,
        this.id});

  factory User.fromJson(Map<String, dynamic> json) => User(
      id: json['id'],
      name: json['name'],
      preferences: List<String>.from(json['preferences']),
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      isNotificationEnabled: json['isNotificationEnabled'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'preferences': preferences,
    'email': email,
    'phoneNumber': phoneNumber,
    'isNotificationEnabled': isNotificationEnabled,
  };
}