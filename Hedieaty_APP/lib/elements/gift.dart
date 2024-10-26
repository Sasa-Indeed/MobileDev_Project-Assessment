// Gift Model
class Gift {
  String giftName;
  String category;
  String status; // "Pending" or "Pledged"
  String description;
  String imagePath; // Local path for the image, nullable
  bool isPledged;
  double price;

  Gift({
    required this.giftName,
    required this.category,
    required this.status,
    this.isPledged = false,
    this.imagePath = 'asset/gift.png', // Optional image path
    this.description = "Description",
    this.price = 0.0
  });

}