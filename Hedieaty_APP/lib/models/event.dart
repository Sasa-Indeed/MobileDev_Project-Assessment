class Event{
  final int? id;
  final String name;
  final DateTime date;
  final String location;
  final String description;
  final String userID;

  Event({required this.name,
         required this.date,
         required this.location,
         required this.description,
         required this.userID,
         this.id});

  factory Event.fromJson(Map<String, dynamic> json) => Event(
      id: json['id'],
      name: json['name'],
      date: DateTime.parse(json['date']),
      location: json['location'],
      description: json['description'],
      userID: json['userID']
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'date': date.toIso8601String(),
    'location': location,
    'description': description,
    'userID': userID
  };
}