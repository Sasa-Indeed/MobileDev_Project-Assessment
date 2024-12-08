import 'package:flutter/material.dart';
import 'package:hedieaty_app/custom_widgets/colors.dart';
import 'package:hedieaty_app/database/event_database_services.dart';
import 'package:hedieaty_app/models/event.dart';
import 'package:hedieaty_app/models/gift.dart';
import '../database/gift_database_services.dart';

class GiftListPage extends StatefulWidget {
  const GiftListPage({super.key});

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  List<Gift> gifts = [];
  List<Event> upcomingEvents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGifts();
    getEvents();
  }

  Future<void> fetchGifts() async {
    setState(() {
      isLoading = true;
    });
    gifts = await GiftDatabaseServices.getAllGifts();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getEvents() async {
    upcomingEvents = await EventDatabaseServices.getUpcomingEvents();
    setState(() {}); // Update UI to reflect loaded events
  }

  Future<void> addGift(String name, String description, String category, double price, String status, int? eventID, {String? imagePath}) async {
    Gift newGift = Gift(
      name: name,
      description: description,
      category: category,
      price: price,
      status: status,
      eventID: eventID!,
      imagePath: imagePath,
    );
    await GiftDatabaseServices.insertGift(newGift);
    fetchGifts();
  }

  Future<void> editGift(Gift updatedGift) async {
    await GiftDatabaseServices.updateGift(updatedGift);
    fetchGifts();
  }



  void showAddGiftDialog() {
    if (upcomingEvents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("No events available to add a gift."),
      ));
      return;
    }

    String newName = '';
    String newDescription = '';
    String newCategory = '';
    double newPrice = 0.0;
    String? newImagePath;
    Event? selectedEvent = upcomingEvents.first;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add New Gift"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(hintText: "Gift Name"),
                      onChanged: (value) => newName = value,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(hintText: "Description"),
                      onChanged: (value) => newDescription = value,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(hintText: "Category"),
                      onChanged: (value) => newCategory = value,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(hintText: "Price"),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => newPrice = double.tryParse(value) ?? 0.0,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(hintText: "Image Path (optional)"),
                      onChanged: (value) => newImagePath = value,
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<Event>(
                      value: selectedEvent,
                      isExpanded: true,
                      onChanged: (value) {
                        setState(() {
                          selectedEvent = value!;
                        });
                      },
                      items: upcomingEvents.map((event) {
                        return DropdownMenuItem<Event>(
                          value: event,
                          child: Text("${event.name} (${event.date})"),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text("Add"),
                  onPressed: () async {
                    if (newName.isNotEmpty &&
                        newDescription.isNotEmpty &&
                        newCategory.isNotEmpty &&
                        newPrice > 0 &&
                        selectedEvent != null) {
                      await addGift(
                        newName,
                        newDescription,
                        newCategory,
                        newPrice,
                        'Pending',
                        selectedEvent?.id,
                        imagePath: newImagePath,
                      );
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Delete a gift
  Future<void> deleteGift(Gift gift) async {
    await GiftDatabaseServices.deleteGift(gift);
    fetchGifts();
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
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : gifts.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'asset/empty_gift.png',
              width: 250,
              height: 400,
            ),
            const Text(
              'No Gifts to Display!',
              style: TextStyle(
                fontSize: 25,
                color: MyColors.orange,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: gifts.length,
        itemBuilder: (context, index) {
          Gift gift = gifts[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/GiftDetailsPage',
                arguments: gift, // Passing the selected gift as an argument
              );
            },
            child: Card(
              color: gift.status == "Pledged" ? Colors.orange : Colors.blue,
              child: Row(
                children: [
                  // Gift Image
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage(
                        gift.imagePath ?? 'asset/gift.png',
                      ),
                    ),
                  ),
                  // Gift Attributes
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gift.name,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Description: ${gift.description}",
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Action Buttons
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: () {
                          if (gift.status != "Pledged") {
                            deleteGift(gift);
                          }
                        },
                      ),
                    ],
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
