import 'package:flutter/material.dart';
import 'package:hedieaty_app/custom_widgets/colors.dart';
import 'package:hedieaty_app/elements/gift.dart';

class GiftListPage extends StatefulWidget {
  const GiftListPage({super.key});

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  List<Gift> gifts = [
    Gift(giftName: "Teddy Bear", category: "Toys", status: "Pending", imagePath: "asset/teddyBear.jpg"),
    Gift(giftName: "Flower Bouquet", category: "Flowers", status: "Pledged", isPledged: true),
    Gift(giftName: "Chocolates", category: "Food", status: "Pending"), // No image, default will be shown
  ];

  String sortOption = 'name';

  // Sorting function
  void sortGifts(String option) {
    setState(() {
      if (option == 'name') {
        gifts.sort((a, b) => a.giftName.compareTo(b.giftName));
      } else if (option == 'category') {
        gifts.sort((a, b) => a.category.compareTo(b.category));
      } else if (option == 'status') {
        gifts.sort((a, b) => a.status.compareTo(b.status));
      }
      sortOption = option;
    });
  }

  // Add, Edit, and Delete functions
  void addGift() {
    showDialog(
        context: context,
        builder: (context) {
          String newName = '';
          String newCategory = '';
          String? newImagePath;
          return AlertDialog(
            title: Text("Add New Gift"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(hintText: "Gift Name"),
                  onChanged: (value) => newName = value,
                ),
                TextField(
                  decoration: InputDecoration(hintText: "Category"),
                  onChanged: (value) => newCategory = value,
                ),
                TextField(
                  decoration: InputDecoration(hintText: "Image Path (optional)"),
                  onChanged: (value) => newImagePath = value,
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text("Add"),
                onPressed: () {
                  if (newName.isNotEmpty && newCategory.isNotEmpty) {
                    setState(() {
                      if(newImagePath == null){
                        gifts.add(Gift(giftName: newName, category: newCategory, status: "Pending",));
                      }else{
                        gifts.add(Gift(giftName: newName, category: newCategory, status: "Pending", imagePath: newImagePath!));
                      }
                    });
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        });
  }

  void editGift(Gift gift) {
    String newName = gift.giftName;
    String newCategory = gift.category;
    String? newImagePath = gift.imagePath;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Edit Gift"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(hintText: "Gift Name"),
                  onChanged: (value) => newName = value,
                  controller: TextEditingController(text: gift.giftName),
                ),
                TextField(
                  decoration: InputDecoration(hintText: "Category"),
                  onChanged: (value) => newCategory = value,
                  controller: TextEditingController(text: gift.category),
                ),
                TextField(
                  decoration: InputDecoration(hintText: "Image Path (optional)"),
                  onChanged: (value) => newImagePath = value,
                  controller: TextEditingController(text: gift.imagePath ?? 'asset/gift.png'),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text("Save"),
                onPressed: () {
                  setState(() {
                    gift.giftName = newName;
                    gift.category = newCategory;
                    gift.imagePath = newImagePath!;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void deleteGift(Gift gift) {
    setState(() {
      gifts.remove(gift);
    });
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.gray,
      appBar: AppBar(
        title: const Text(
            'Gift List',
          style: TextStyle(
              color: MyColors.gray,
              fontFamily: "playWrite",
              fontSize: 30
          ),
        ),
        backgroundColor: MyColors.navy,
        actions: [
          PopupMenuButton<String>(
            onSelected: sortGifts,
            iconColor: MyColors.gray,
            color: MyColors.navy,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              )
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'name',
                  child: Text(
                      'Sort by Name',
                      style: TextStyle(
                          color: MyColors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                      ),
                  )
              ),
              const PopupMenuItem(
                  value: 'category',
                  child: Text(
                    'Sort by Category',
                    style: TextStyle(
                        color: MyColors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 15
                    ),
                  )
              ),
              const PopupMenuItem(
                  value: 'status',
                  child: Text(
                    'Sort by Status',
                    style: TextStyle(
                        color: MyColors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 15
                    ),
                  )
              ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: gifts.length,
        itemBuilder: (context, index) {
          Gift gift = gifts[index];
          return Card(
            color: gift.isPledged ? Colors.green[100] : null, // Color code for pledged gifts
            child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(gift.imagePath), // Use default image if no image is provided
              ),
              title: Text(gift.giftName),
              subtitle: Text("${gift.category} - ${gift.status}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      if (!gift.isPledged) {
                        editGift(gift);
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      if (!gift.isPledged) {
                        deleteGift(gift);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addGift,
        backgroundColor: MyColors.navy,
        child: const Icon(
            Icons.add,
            color: MyColors.orange,
        ),
      ),
    );
  }
}
