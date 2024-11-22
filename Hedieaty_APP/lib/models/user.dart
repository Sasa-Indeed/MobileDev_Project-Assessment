class User{
  final int? id;
  final String name;
  List<String> preferences;
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
      preferences: [],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      isNotificationEnabled: json['isNotificationEnabled'] == 1,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phoneNumber': phoneNumber,
    'isNotificationEnabled': isNotificationEnabled ? 1 : 0,
  };
}