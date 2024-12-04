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
    String newStatus = 'Pending'; // Default to 'Pending'
    String? newImagePath;
    Event? selectedEvent = upcomingEvents.first;

    showDialog(
      context: context,
      builder: (context) {
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
                DropdownButton<String>(
                  value: newStatus,
                  isExpanded: true,
                  onChanged: (value) {
                    setState(() {
                      newStatus = value!;
                    });
                  },
                  items: ['Pending', 'Pledged'].map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
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
                    newStatus.isNotEmpty &&
                    selectedEvent != null) {
                  await addGift(
                    newName,
                    newDescription,
                    newCategory,
                    newPrice,
                    newStatus,
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
  }


  void showEditGiftDialog(Gift gift) {
    String newName = gift.name;
    String newDescription = gift.description;
    String newCategory = gift.category;
    double newPrice = gift.price;
    String newStatus = gift.status;
    String? newImagePath = gift.imagePath;

    Event? selectedEvent = upcomingEvents.isNotEmpty
        ? upcomingEvents.firstWhere(
          (event) => event.id == gift.eventID,
      orElse: () => upcomingEvents.first,
    )
        : null;

    if (upcomingEvents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("No events available to assign to the gift."),
      ));
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Gift"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(hintText: "Gift Name"),
                  controller: TextEditingController(text: newName),
                  onChanged: (value) => newName = value,
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(hintText: "Description"),
                  controller: TextEditingController(text: newDescription),
                  onChanged: (value) => newDescription = value,
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(hintText: "Category"),
                  controller: TextEditingController(text: newCategory),
                  onChanged: (value) => newCategory = value,
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(hintText: "Price"),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: newPrice.toString()),
                  onChanged: (value) => newPrice = double.tryParse(value) ?? 0.0,
                ),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  value: newStatus,
                  isExpanded: true,
                  onChanged: (value) {
                    setState(() {
                      newStatus = value!;
                    });
                  },
                  items: ['Pending', 'Pledged'].map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(hintText: "Image Path (optional)"),
                  controller: TextEditingController(text: newImagePath),
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
              child: const Text("Save"),
              onPressed: () async {
                if (newName.isNotEmpty &&
                    newDescription.isNotEmpty &&
                    newCategory.isNotEmpty &&
                    newPrice > 0 &&
                    newStatus.isNotEmpty &&
                    selectedEvent != null) {
                  Gift updatedGift = Gift(
                    id: gift.id,
                    name: newName,
                    description: newDescription,
                    category: newCategory,
                    price: newPrice,
                    status: newStatus,
                    eventID: selectedEvent?.id ?? 0, // Handles nullable id
                    imagePath: newImagePath,
                  );
                  await editGift(updatedGift);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
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
                        showEditGiftDialog(gift);
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
