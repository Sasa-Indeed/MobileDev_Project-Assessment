class Pledges{
  final int? id;
  final int giftID;
  final int userID;
  final int friendID;
  final DateTime dueDate;

  Pledges({required this.giftID,
          required this.userID,
          required this.friendID,
          required this.dueDate,
          this.id});

  factory Pledges.fromJson(Map<String, dynamic> json) => Pledges(
      id: json['id'],
      giftID: json['giftID'],
      userID: json['userID'],
      friendID: json['friendID'],
      dueDate: DateTime.parse(json['dueDate'])
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'giftID': giftID,
    'userID': userID,
    'friendID': friendID,
    'dueDate': dueDate.toIso8601String()
  };

}