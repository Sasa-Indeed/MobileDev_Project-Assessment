import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hedieaty_app/custom_widgets/colors.dart';
import 'package:hedieaty_app/database/event_database_services.dart';
import 'package:hedieaty_app/database/gift_database_services.dart';
import 'package:hedieaty_app/firebase_services/firebase_gift_service.dart';
import 'package:hedieaty_app/models/event.dart';
import 'package:hedieaty_app/models/gift.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

class GiftListPage extends StatefulWidget {
  const GiftListPage({super.key});

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  List<Gift> gifts = [];
  List<Event> upcomingEvents = [];
  bool isLoading = true;
  late StreamSubscription _firestoreSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userID = ModalRoute.of(context)!.settings.arguments as int;
      await _fetchEvents(userID);
      await _fetchGifts(userID);

      // Listen for Firestore changes in real-time
      _firestoreSubscription = FirebaseGiftService.getGiftsStreamByUserID(userID).listen((giftList) {
        _syncLocalAndFirestoreGifts(giftList, userID);
      });
    });
  }

  @override
  void dispose() {
    // Cancel the Firestore stream listener when the page is disposed
    _firestoreSubscription.cancel();
    super.dispose();
  }




  /// Real-time Firestore sync with local database.
  Future<void> _syncLocalAndFirestoreGifts(List<Gift> firestoreGifts, int userID) async {
    try {
      // Update local database with the changes from Firestore
      for (var gift in firestoreGifts) {
        if (await GiftDatabaseServices.getGiftByUserID(gift.id!, userID) != null) {
          // If the gift exists locally, update it
          await GiftDatabaseServices.updateGift(gift);
        } else {
          // If the gift doesn't exist locally, insert it
          await GiftDatabaseServices.insertGift(gift);
        }
      }
      // Refresh the list of gifts after syncing
      _fetchGifts(userID);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sync gifts: $e')),
      );
    }
  }

  Future<void> _fetchEvents(int userID) async {
    try {
      upcomingEvents = await EventDatabaseServices.getUpcomingEventsByUserID(userID);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load events: $e')),
      );
    }
  }

  Future<void> _fetchGifts(int userID) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch local gifts
      final localGifts = await GiftDatabaseServices.getAllGiftsByUserID(userID);

      // Fetch published gifts from Firestore
      final firestoreGifts = await FirebaseGiftService.getGiftsByUserID(userID);

      // Combine both lists, avoiding duplicates
      Map<int, Gift> giftMap = {};

      // Add local gifts to the map
      for (var gift in localGifts) {
        giftMap[gift.id!] = gift;
      }

      // Add Firestore gifts only if they are not already in the map
      for (var gift in firestoreGifts) {
        if (!giftMap.containsKey(gift.id)) {
          giftMap[gift.id!] = gift;
        }
      }

      // Convert map back to list
      gifts = giftMap.values.toList();
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

  /// Handles gift deletion.
  Future<void> _deleteGift(Gift gift) async {
    try {
      await GiftDatabaseServices.deleteGift(gift);
      await FirebaseGiftService.deleteGiftByID(gift.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gift deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete gift: $e')),
      );
    }
  }

  /// Publishes local gifts to Firestore.
  Future<void> _publishGifts(List<Gift> localGifts, int userID) async {
    try {
      List<Gift> firestoreGifts = await FirebaseGiftService.getGiftsByUserID(userID);
      Map<int, Gift> firestoreGiftsMap = {
        for (var gift in firestoreGifts) gift.id!: gift,
      };

      for (Gift localGift in localGifts) {
        if (firestoreGiftsMap.containsKey(localGift.id)) {
          await FirebaseGiftService.updateGiftInFirestore(localGift);
        } else {
          await FirebaseGiftService.addGiftToFirestore(localGift);
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gifts published successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to publish gifts: $e')),
      );
    }
  }

  Future<void> _addGift({
    required String name,
    required String description,
    required String category,
    required double price,
    required String status,
    required int eventID,
    required int userID,
    String? imagePath,
  }) async {
    Event? event = await EventDatabaseServices.getEventsByUserIDandEventID(userID, eventID);
    int giftID = DateTime.now().millisecondsSinceEpoch;
    Gift newGift = Gift(
        id: giftID,
        name: name,
        description: description,
        category: category,
        price: price,
        status: status,
        eventID: eventID,
        userID: userID,
        imagePath: imagePath,
        eventName: event?.name??'',
        dueDate: event?.date.subtract(const Duration(days: 3)) ?? DateTime.now()
    );
    await GiftDatabaseServices.insertGift(newGift);
    _fetchGifts(userID); // Refresh the gift list after adding a new gift
  }

  Future<bool> _requestGalleryPermission() async {
    Permission permission;

    if (Platform.isAndroid) {
      permission = Permission.photos; // READ_MEDIA_IMAGES for Android 13+
    } else if (Platform.isIOS) {
      permission = Permission.photos;
    } else {
      return false; // Unsupported platform
    }

    PermissionStatus status = await permission.request();

    if (status.isPermanentlyDenied) {
      await openAppSettings(); // Direct the user to app settings
      return false;
    }

    return status.isGranted;
  }


  void _showAddGiftDialog(int userID) {
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
    String? newImageURL; // To hold the uploaded URL after confirmation
    Event? selectedEvent = upcomingEvents.first; // Default selected event
    File? localImageFile; // Local file for image preview

    final ImagePicker picker = ImagePicker();

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
                    // Gift Name
                    TextField(
                      decoration: const InputDecoration(hintText: "Gift Name"),
                      onChanged: (value) => newName = value,
                    ),
                    const SizedBox(height: 10),

                    // Description
                    TextField(
                      decoration: const InputDecoration(hintText: "Description"),
                      onChanged: (value) => newDescription = value,
                    ),
                    const SizedBox(height: 10),

                    // Category
                    TextField(
                      decoration: const InputDecoration(hintText: "Category"),
                      onChanged: (value) => newCategory = value,
                    ),
                    const SizedBox(height: 10),

                    // Price
                    TextField(
                      decoration: const InputDecoration(hintText: "Price"),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => newPrice = double.tryParse(value) ?? 0.0,
                    ),
                    const SizedBox(height: 10),

                    // Image Preview
                    localImageFile != null
                        ? Image.file(
                      localImageFile!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    )
                        : const Text("No image selected."),
                    const SizedBox(height: 10),

                    // Pick Image Button
                    ElevatedButton(
                      onPressed: () async {
                        // Pick an image file using ImagePicker
                        final XFile? pickedFile =
                        await picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setState(() {
                            localImageFile = File(pickedFile.path);
                            newImageURL = null; // Clear previous URL
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("No image selected.")),
                          );
                        }
                      },
                      child: const Text("Pick Image"),
                    ),
                    const SizedBox(height: 10),

                    // Event Dropdown
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
                // Cancel Button
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.of(context).pop(),
                ),

                // Add Button
                TextButton(
                  child: const Text("Add"),
                  onPressed: () async {
                    // Validate fields
                    if (newName.isNotEmpty &&
                        newDescription.isNotEmpty &&
                        newCategory.isNotEmpty &&
                        newPrice > 0 &&
                        selectedEvent != null &&
                        localImageFile != null) {
                      // Upload image only when all fields are validated
                      String? uploadedImageUrl = await _uploadImageToServer(localImageFile!);

                      if (uploadedImageUrl != null) {
                        newImageURL = uploadedImageUrl;

                        // Add the gift data after image upload
                        await _addGift(
                          name: newName,
                          description: newDescription,
                          category: newCategory,
                          price: newPrice,
                          status: 'Pending',
                          eventID: selectedEvent!.id!,
                          userID: userID,
                          imagePath: newImageURL, // Uploaded URL
                        );
                        Navigator.of(context).pop();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Gift added successfully!")),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Failed to upload image.")),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Please fill out all fields and pick an image."),
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

  /// Function to upload the image to the server
  Future<String?> _uploadImageToServer(File imageFile) async {
    const String apiKey = "64e6fa494339ed948f3532b1d48de822";
    const String uploadUrl = "https://api.imgbb.com/1/upload";

    try {
      // Convert file to base64
      String base64Image = base64Encode(await imageFile.readAsBytes());

      // Prepare POST request
      var response = await http.post(
        Uri.parse("$uploadUrl?key=$apiKey"),
        body: {
          'image': base64Image,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['data']['url']; // Return the uploaded image URL
      } else {
        return null; // Upload failed
      }
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }




  @override
  Widget build(BuildContext context) {
    final userID = ModalRoute.of(context)!.settings.arguments as int;

    return Scaffold(
      backgroundColor: MyColors.gray,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: MyColors.orange),
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
              style: TextStyle(fontSize: 25, color: MyColors.orange),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: gifts.length,
        itemBuilder: (context, index) {
          final gift = gifts[index];
          return GestureDetector(
            onTap: () async {
              final result = await Navigator.pushNamed(
                context,
                '/GiftDetailsPage',
                arguments: gift,
              );

              if (result is Gift) {
                FirebaseGiftService.updateGiftInFirestore(result);
              }
            },
            child: Card(
              color: gift.status == "Pledged" ? Colors.orange : Colors.blue,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: (gift.imagePath == null )
                          ? const AssetImage('asset/gift.png') // Default asset image
                          : NetworkImage(gift.imagePath!) as ImageProvider<Object>,
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
                            "Pledge Status: ${gift.status}",
                            style: const TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Description: ${gift.description}",
                            style: const TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () {
                      if (gift.status != "Pledged") {
                        _deleteGift(gift);
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
        onPressed: () => _showAddGiftDialog(userID),
        backgroundColor: MyColors.navy,
        child: const Icon(Icons.add, color: MyColors.orange),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: MyColors.navy,
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          ),
          onPressed: () async {
            if (gifts.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No gifts to publish!')),
              );
              return;
            }

            await _publishGifts(gifts, userID);
          },
          child: const Text(
            "Publish Gifts",
            style: TextStyle(fontSize: 18, color: MyColors.orange, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}


