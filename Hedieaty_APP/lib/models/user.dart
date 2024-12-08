class User{
  int? id;
  String name;
  List<String> preferences;
  String email;
  final String password;
  String phoneNumber;
  bool isNotificationEnabled;


  User({required this.name,
        required this.preferences,
        required this.email,
        required this.password,
        required this.phoneNumber,
        required this.isNotificationEnabled,
        this.id});

  factory User.fromJson(Map<String, dynamic> json) => User(
      id: json['id'],
      name: json['name'],
      preferences: [],
      email: json['email'],
      password: json['password'],
      phoneNumber: json['phoneNumber'],
      isNotificationEnabled: json['isNotificationEnabled'] == 1,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
    'phoneNumber': phoneNumber,
    'isNotificationEnabled': isNotificationEnabled ? 1 : 0,
  };
}