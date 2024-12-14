import 'package:flutter/material.dart';
import 'package:hedieaty_app/custom_widgets/colors.dart';
import 'package:hedieaty_app/database/event_database_services.dart';
import 'package:hedieaty_app/database/gift_database_services.dart';
import 'package:hedieaty_app/firebase_services/firebase_gift_service.dart';
import 'package:hedieaty_app/models/event.dart';
import 'package:hedieaty_app/models/gift.dart';

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

    // Delay fetch operations until the context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userID = ModalRoute.of(context)!.settings.arguments as int;
      fetchGifts(userID);
      getEvents(userID);
    });
  }

  Future<void> fetchGifts(int userID) async {
    setState(() {
      isLoading = true;
    });

    try {
      gifts = await GiftDatabaseServices.getAllGiftsByUserID(userID);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load gifts: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> publishGifts(List<Gift> localGifts, int userID) async {
    try {
      // Fetch all gifts from Firestore for the current user
      List<Gift> firestoreGifts = await FirebaseGiftService.getGiftsByUserID(userID);

      // Convert Firestore gifts to a map for quick lookup
      Map<int, Gift> firestoreGiftsMap = {
        for (var gift in firestoreGifts) gift.id!: gift,
      };

      // Loop through local gifts for the current user
      for (Gift gift in localGifts.where((gift) => gift.userID == userID)) {
        if (firestoreGiftsMap.containsKey(gift.id)) {
          // If the gift exists in Firestore, update it
          await FirebaseGiftService.updateGiftInFirestore(gift);
        } else {
          // If the gift doesn't exist in Firestore, add it
          await FirebaseGiftService.addGiftToFirestore(gift);
        }
      }
    } catch (e) {
      throw Exception('Failed to publish gifts for user $userID: $e');
    }
  }




  Future<void> getEvents(int userID) async {
    try {
      // Fetch the upcoming events for the user
      upcomingEvents = await EventDatabaseServices.getUpcomingEventsByUserID(userID);

      // Update the UI
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load events: $e')),
      );
    }
  }

  Future<void> addGift({
    required String name,
    required String description,
    required String category,
    required double price,
    required String status,
    required int eventID,
    required int userID,
    String? imagePath,
  }) async {
    Gift newGift = Gift(
      name: name,
      description: description,
      category: category,
      price: price,
      status: status,
      eventID: eventID,
      userID: userID,
      imagePath: imagePath,
    );
    await GiftDatabaseServices.insertGift(newGift);
    fetchGifts(userID);
  }

  Future<void> deleteGift(Gift gift) async {
    try {
      await GiftDatabaseServices.deleteGift(gift);
      await FirebaseGiftService.deleteGiftByID(gift.id!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete gift: $e')),
      );
    }
    fetchGifts(gift.userID);
  }

  void showAddGiftDialog(int userID) {
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
    Event? selectedEvent = upcomingEvents.first; // Initialize with the first event

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
                        selectedEvent != null &&
                        selectedEvent?.id != null) {
                      await addGift(
                        name: newName,
                        description: newDescription,
                        category: newCategory,
                        price: newPrice,
                        status: 'Pending',
                        eventID: selectedEvent?.id ??0,
                        userID: userID,
                        imagePath: newImagePath,
                      );
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Please fill out all fields."),
                      ));
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

  Future<void> _navigateAndRefreshGift(Gift gift) async {
    // Navigate to gift details and wait for result
    final result = await Navigator.pushNamed(
      context,
      '/GiftDetailsPage',
      arguments: gift,
    );

    // If the result is a Gift object, it means the gift was updated
    if (result is Gift) {
      fetchGifts(result.userID); // Refresh the entire gift list
      FirebaseGiftService.updateGiftInFirestore(result);
    }
}

    @override
  Widget build(BuildContext context) {
    final userID = ModalRoute.of(context)!.settings.arguments as int;
    return Scaffold(
      backgroundColor: MyColors.gray,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: MyColors.orange,
        ),
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
      body: Column(
        children: [
          Expanded(
              child: isLoading
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
                    onTap: () => _navigateAndRefreshGift(gift),
                    child: Card(
                      color: gift.status == "Pledged" ? Colors.orange : Colors.blue,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundImage: AssetImage(
                                gift.imagePath ?? 'asset/gift.png',
                              ),
                            ),
                          ),
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
                    ),
                  );
                },
              ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.navy,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onPressed: () async {
                try {
                  await publishGifts(gifts, userID); // Call the publish function
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gifts published successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to publish gifts: $e')),
                  );
                }
              },
              child: const Text(
                "Publish Gifts",
                style: TextStyle(
                  fontSize: 18,
                  color: MyColors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddGiftDialog(userID),
        backgroundColor: MyColors.navy,
        child: const Icon(
          Icons.add,
          color: MyColors.orange,
        ),
      ),
    );
  }
}
