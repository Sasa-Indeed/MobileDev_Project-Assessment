class Gift {
  final int? id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String status; // "Pending" or "Pledged"
  final int eventID;
  final String? imagePath; // Local path for the image, nullable


  const Gift({required this.name, required this.description, required this.category,
  required this.price, required this.status, required this.eventID,
  this.id, this.imagePath});

  factory Gift.fromJson(Map<String, dynamic> json) => Gift(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    category: json['category'],
    price: json['price'],
    status: json['status'],
    eventID: json['eventID'],
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
  'imagePath': imagePath
  };

}