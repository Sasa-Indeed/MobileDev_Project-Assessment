import 'package:flutter/material.dart';
import 'package:hedieaty_app/custom_widgets/colors.dart';
import 'package:hedieaty_app/database/notifications_database_services.dart';
import 'package:hedieaty_app/database/pledges_database_services.dart';
import 'package:hedieaty_app/firebase_services/firebase_gift_service.dart';
import 'package:hedieaty_app/firebase_services/firebase_notifiacations_services.dart';
import 'package:hedieaty_app/firebase_services/firebase_pledges_service.dart';
import 'package:hedieaty_app/models/gift.dart';
import 'package:hedieaty_app/models/notifications.dart';
import 'package:hedieaty_app/models/pledges.dart';
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

    try {
      final isPledged = gift.status == "Pledged";

      if (isPledged) {
        // Check if the user pledged this gift
        final existingPledges = await PledgeDatabaseServices.getPledgesByGiftID(gift.id!);

        Pledges? matchingPledge;
        try {
          matchingPledge = existingPledges.firstWhere((pledge) => pledge.userID == user.id);
        } catch (e) {
          matchingPledge = null; // No matching pledge found
        }

        if (matchingPledge == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You have not pledged this gift.')),
          );
          return;
        }

        // Remove pledge from database and Firebase
        await PledgeDatabaseServices.deletePledge(matchingPledge.id!);
        await FirebasePledgesService.deletePledgeByUserID(user.id);
        Notifications unPledgeNotifications = Notifications(
          title: "${user.name} unpledged ${gift.name}",
          body: "${user.name} has unpledged ${gift.name} from the event ${gift.eventName}",
          receiverID: friendID,
          status: false,
          timestamp: DateTime.now(),
        );

        int notifID = await NotificationDatabaseServices.insertNotification(unPledgeNotifications);

        unPledgeNotifications.id = notifID;

        await FirebaseNotificationsService.addNotification(unPledgeNotifications);

        // Update gift status in Firebase
        await FirebaseGiftService.updateGiftInFirestore(gift.copyWith(status: "Unpledged"));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unpledged gift: ${gift.name}')),
        );
      } else {
        // Create a new pledge
        final newPledge = Pledges(
          giftID: gift.id,
          userID: user.id,
          friendID: friendID,
          dueDate: gift.dueDate,
          friendName: friendName,
          eventName: gift.eventName ?? "Unknown",
          giftName: gift.name
        );

        // Add pledge to database and Firebase
        await PledgeDatabaseServices.insertPledge(newPledge);
        await FirebasePledgesService.addPledgeToFirestore(newPledge);

        Notifications pledgeNotifications = Notifications(
          title: "${user.name} pledged ${gift.name}",
          body: "${user.name} has pledged ${gift.name} from the event ${gift.eventName}",
          receiverID: friendID,
          status: false,
          timestamp: DateTime.now(),
        );
        int notifID = await NotificationDatabaseServices.insertNotification(pledgeNotifications);

        pledgeNotifications.id = notifID;

        await FirebaseNotificationsService.addNotification(pledgeNotifications);


        // Update gift status in Firebase
        await FirebaseGiftService.updateGiftInFirestore(gift.copyWith(status: "Pledged"));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pledged gift: ${gift.name}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to toggle pledge status: $e')),
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
