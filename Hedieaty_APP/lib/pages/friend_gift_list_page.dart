import 'package:flutter/material.dart';
import 'package:hedieaty_app/custom_widgets/colors.dart';
import 'package:hedieaty_app/firebase_services/firebase_gift_service.dart';
import 'package:hedieaty_app/models/gift.dart';
import 'package:hedieaty_app/models/user.dart';
import 'package:intl/intl.dart';

class FriendGiftListPage extends StatefulWidget {
  const FriendGiftListPage({super.key});

  @override
  State<FriendGiftListPage> createState() => _FriendGiftListPageState();
}

class _FriendGiftListPageState extends State<FriendGiftListPage> {
  List<Gift> friendGifts = [];
  bool isLoading = true;
  late int friendID;
  late Userdb user;
  late String friendName;

  @override
  void initState() {
    super.initState();

    // Delay fetch operations until the context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      user = args['user'];
      friendID = args['friendID'];
      friendName = args['friendName'];

      fetchFriendGifts();
    });
  }

  /// Fetch gifts from Firestore and listen for real-time updates.
  void fetchFriendGifts() {
    setState(() {
      isLoading = true;
    });

    FirebaseGiftService.getGiftsStreamByUserID(friendID).listen((List<Gift> gifts) {
      setState(() {
        friendGifts = gifts;
        isLoading = false;
      });
    }, onError: (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load friend\'s gifts: $error')),
      );
    });
  }

  /// Toggle pledge status of a gift.
  Future<void> togglePledge(Gift gift) async {
    if (gift.dueDate != null && DateTime.now().isAfter(gift.dueDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot unpledge the gift as the due date has passed.')),
      );
      return;
    }

    try {
      Gift updatedGift = gift.copyWith(
        status: gift.status == "Pledged" ? "Unpledged" : "Pledged",
      );
      await FirebaseGiftService.updateGiftInFirestore(updatedGift);

      // Optionally show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            gift.status == "Pledged" ? "Unpledged gift: ${gift.name}" : "Pledged gift: ${gift.name}",
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update gift: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.gray,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: MyColors.orange),
        title: Text(
          "$friendName's Gifts",
          style: const TextStyle(
            color: MyColors.gray,
            fontFamily: "playWrite",
            fontSize: 30,
          ),
        ),
        backgroundColor: MyColors.navy,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : friendGifts.isEmpty
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
        itemCount: friendGifts.length,
        itemBuilder: (context, index) {
          Gift gift = friendGifts[index];
          bool isPastDue = gift.dueDate != null && DateTime.now().isAfter(gift.dueDate!);

          return Card(
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
                          "Event: ${gift.eventName ?? 'Unknown'}",
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Price: \$${gift.price.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Due Date: ${gift.dueDate != null ? DateFormat('dd/MM/yyyy').format(gift.dueDate!) : 'Not Set'}",
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    Switch(
                      value: gift.status == "Pledged",
                      onChanged: isPastDue
                          ? null
                          : (value) => togglePledge(gift),
                      activeColor: Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
