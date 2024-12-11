class Notifications{

  final int? id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool status; // Read ture - Unread false

  Notifications({required this.title, required this.body, required this.timestamp,
    required this.status, this.id}); // Read (true) Unread (false)

  factory Notifications.fromJson(Map<String, dynamic> json) => Notifications(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      timestamp: DateTime.parse(json['timestamp']),
      status: json['status'] == 1
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'timestamp': timestamp.toIso8601String(),
    'status': status ? 1 : 0
  };

}