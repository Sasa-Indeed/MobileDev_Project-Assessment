import 'package:flutter/material.dart';
import 'package:hedieaty_app/custom_widgets/colors.dart';
import 'package:hedieaty_app/models/gift.dart';
import '../database/gift_database_services.dart';

class GiftListPage extends StatefulWidget {
  const GiftListPage({super.key});

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  List<Gift> gifts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGifts();
  }

  // Fetch gifts from the database
  Future<void> fetchGifts() async {
    setState(() {
      isLoading = true;
    });
    gifts = await GiftDatabaseServices.getAllGifts();
    setState(() {
      isLoading = false;
    });
  }

  // Add a new gift
  Future<void> addGift(String name, String category, {String? imagePath}) async {
    Gift newGift = Gift(
      name: name,
      description: '',
      category: category,
      price: 0.0,
      status: 'Pending',
      eventID: 0,
      imagePath: imagePath,
    );
    await GiftDatabaseServices.insertGift(newGift);
    fetchGifts();
  }

  // Edit an existing gift
  Future<void> editGift(Gift gift) async {
    await GiftDatabaseServices.updateGift(gift);
    fetchGifts();
  }

  // Delete a gift
  Future<void> deleteGift(Gift gift) async {
    await GiftDatabaseServices.deleteGift(gift);
    fetchGifts();
  }

  void showAddGiftDialog() {
    String newName = '';
    String newCategory = '';
    String? newImagePath;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Gift"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(hintText: "Gift Name"),
                onChanged: (value) => newName = value,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(hintText: "Category"),
                onChanged: (value) => newCategory = value,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(hintText: "Image Path (optional)"),
                onChanged: (value) => newImagePath = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Add"),
              onPressed: () async {
                if (newName.isNotEmpty && newCategory.isNotEmpty) {
                  await addGift(newName, newCategory, imagePath: newImagePath);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Sorting function
  void sortGifts(String option) {
    setState(() {
      if (option == 'name') {
        gifts.sort((a, b) => a.name.compareTo(b.name));
      } else if (option == 'category') {
        gifts.sort((a, b) => a.category.compareTo(b.category));
      } else if (option == 'status') {
        gifts.sort((a, b) => a.status.compareTo(b.status));
      }
    });
  }

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
            fontSize: 30,
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
              ),
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
                ),
              ),
              const PopupMenuItem(
                value: 'category',
                child: Text(
                  'Sort by Category',
                  style: TextStyle(
                    color: MyColors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const PopupMenuItem(
                value: 'status',
                child: Text(
                  'Sort by Status',
                  style: TextStyle(
                    color: MyColors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : gifts.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('asset/empty_gift.png', width: 250, height: 400,),
            const Text(
              'No Gifts to Display!',
              style: TextStyle(
                  fontSize: 25,
                  color: MyColors.orange),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: gifts.length,
        itemBuilder: (context, index) {
          Gift gift = gifts[index];
          return Card(
            color: gift.status == "Pledged" ? Colors.green[100] : null,
            child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(
                    gift.imagePath ?? 'asset/gift.png'),
              ),
              title: Text(gift.name),
              subtitle: Text("${gift.category} - ${gift.status}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      if (gift.status != "Pledged") {
                        // Call editGift dialog here
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      if (gift.status != "Pledged") {
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
        onPressed: showAddGiftDialog,
        backgroundColor: MyColors.navy,
        child: const Icon(
          Icons.add,
          color: MyColors.orange,
        ),
      ),
    );
  }
}
