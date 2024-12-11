class Gift {
  final int? id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String status; // "Pending" or "Pledged"
  final int eventID;
  final int userID;
  final String? imagePath; // Local path for the image, nullable


  const Gift({required this.name, required this.description, required this.category,
  required this.price, required this.status, required this.eventID, required this.userID,
  this.id, this.imagePath});

  factory Gift.fromJson(Map<String, dynamic> json) => Gift(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    category: json['category'],
    price: json['price'],
    status: json['status'],
    eventID: json['eventID'],
    userID: json['userID'],
    imagePath: json['imagePath']
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
  'imagePath': imagePath
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
    );
  }

}