class Friend{
  final int userID;
  final int friendID;


  Friend({required this.userID, required this.friendID});

  factory Friend.fromJson(Map<String, dynamic> json) => Friend(
      userID: json['userID'],
      friendID: json['friendID']
  );

  Map<String, dynamic> toJson() => {
    'userID': userID,
    'friendID': friendID
  };

}