class Userdb{
  int? id;
  String name;
  List<String> preferences;
  String email;
  final String password;
  String phoneNumber;
  String profileImagePath;
  bool isNotificationEnabled;


  Userdb({required this.name,
        required this.preferences,
        required this.email,
        required this.password,
        required this.phoneNumber,
        required this.profileImagePath,
        required this.isNotificationEnabled,
        this.id});

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
}