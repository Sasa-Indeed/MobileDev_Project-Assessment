import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty_app/Controller/n_service.dart';
import 'package:hedieaty_app/custom_widgets/colors.dart';
import 'package:hedieaty_app/database/friends_database_services.dart';
import 'package:hedieaty_app/database/user_database_services.dart';
import 'package:hedieaty_app/firebase_services/firebase_event_service.dart';
import 'package:hedieaty_app/firebase_services/firebase_friend_services.dart';
import 'package:hedieaty_app/firebase_services/firebase_user_services.dart';
import 'package:hedieaty_app/models/friends.dart';
import 'package:hedieaty_app/models/user.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:flutter/cupertino.dart';

import '../custom_widgets/friend_card.dart';
import '../models/event.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Userdb user;
  List<FriendCard> friendCards = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupFriendsListener();
    });

  }

  Event? _getMostRecentFutureEvent(List<Event> events) {
    final today = DateTime.now();

    // Filter out past and today's events, and keep only future events
    final futureEvents = events.where((event) => event.date.isAfter(today)).toList();

    // Return the event with the earliest future date, or null if no future events exist
    return futureEvents.isNotEmpty
        ? futureEvents.reduce((a, b) => a.date.isBefore(b.date) ? a : b)
        : null;
  }


  void _setupFriendsListener() {
    FirebaseFriendServices.friendsStream(user.id).listen((friendIDs) async {
      // Ensure `friendIDs` field exists in Firestore
      await FirebaseFriendServices.initializeFriendIDsField(user.id);

      // Sync local database and Firestore
      await FriendsDatabaseServices.syncLocalDatabase(user.id);

      // Fetch and update friend cards for UI
      List<FriendCard> cards = [];
      for (int friendID in friendIDs) {
        String name = await UserDatabaseServices.getUserNameByID(friendID);
        String profileImagePath = await UserDatabaseServices.getUserProfileImagePath(friendID);
        List<Event> events = await FirebaseEventService.getEventsByUserID(friendID);
        String mostRecentEvent = 'No upcoming events';


        if(events.isNotEmpty) {
          Event? recentEvent = _getMostRecentFutureEvent(events);
          if(recentEvent != null){
            mostRecentEvent = recentEvent.name;
          }
        }


        cards.add(
          FriendCard(
            name: name,
            image: profileImagePath,
            eventStatus: mostRecentEvent,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/FriendGiftListPage',
                arguments: {'user': user, 'friendID': friendID, 'friendName': name},
              );
            },
          ),
        );
      }

      setState(() {
        friendCards = cards;
      });
    });
  }

  void _showAddFriendPopup(BuildContext context, int currentUserID) {
    final TextEditingController inputController = TextEditingController();
    bool isUsingEmail = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add Friend"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => setState(() => isUsingEmail = true),
                        style: TextButton.styleFrom(
                          backgroundColor: isUsingEmail ? MyColors.orange : MyColors.navy,
                        ),
                        child: const Text("Email"),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () => setState(() => isUsingEmail = false),
                        style: TextButton.styleFrom(
                          backgroundColor: isUsingEmail ? MyColors.navy : MyColors.orange,
                        ),
                        child: const Text("Phone"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    key: const Key("Add Friend Input"),
                    controller: inputController,
                    decoration: InputDecoration(
                      labelText: isUsingEmail
                          ? "Enter Friend's Email"
                          : "Enter Friend's Phone Number",
                    ),
                    keyboardType: isUsingEmail
                        ? TextInputType.emailAddress
                        : TextInputType.phone,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  key: const Key("Add Friend Button"),
                  onPressed: () async {
                    String input = inputController.text.trim();
                    if (input.isEmpty) {
                      _showErrorDialog(context, "Invalid Input", "Please enter valid information.");
                      return;
                    }

                    // Check if the user exists in Firestore
                    int friendID = isUsingEmail
                        ? await FirebaseUserServices.findUserByEmail(input)
                        : await FirebaseUserServices.findUserByPhoneNumber(input);

                    if (friendID == -1) {
                      _showErrorDialog(context, "Friend Not Found", "No user matches the provided information.");
                      return;
                    }

                    // Check if already friends
                    bool isAlreadyFriend = await FriendsDatabaseServices.checkFriendExists(currentUserID, friendID) != -1;

                    if (isAlreadyFriend) {
                      _showErrorDialog(context, "Friend Exists", "This friend is already in your list.");
                      return;
                    }

                    try {
                      // Initialize `friendIDs` field for both users
                      await FirebaseFriendServices.initializeFriendIDsField(currentUserID);
                      await FirebaseFriendServices.initializeFriendIDsField(friendID);

                      // Add friend to Firestore for both users
                      await FirebaseFriendServices.addFriendToFirestore(currentUserID, friendID);
                      await FirebaseFriendServices.addFriendToFirestore(friendID, currentUserID);

                      // Add to the local database
                      Friend newFriend = Friend(userID: currentUserID, friendID: friendID);
                      await FriendsDatabaseServices.insertFriend(newFriend);

                      Navigator.pop(context);
                      _showSuccessDialog(context, "Friend Added", "Friend has been successfully added!");
                    } catch (e) {
                      _showErrorDialog(context, "Error", "Failed to add friend. Please try again.");
                    }
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }


  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    user = ModalRoute.of(context)!.settings.arguments as Userdb;

    return Scaffold(
        backgroundColor: MyColors.gray,
        appBar: AppBar(
          title: const Text(
            "Hedieaty",
            style: TextStyle(
              color: MyColors.gray,
              fontFamily: "playWrite",
              fontSize: 30,
            ),
          ),
          centerTitle: true,
          backgroundColor: MyColors.navy,
        ),
        body: Center(
          child: Stack(
            children: [
              friendCards.isEmpty
                  ? const Center(
                child: Text(
                  "No friends yet,\n Add Friends to have fun!",
                  style: TextStyle(fontSize: 25, color: MyColors.orange),
                ),
              )
                  : ListView(children: friendCards),
                /*Align(
                  key: const Key("circularMenu"),
                  alignment: Alignment.bottomCenter,
                  child: CircularMenu(
                    toggleButtonColor: MyColors.orange,
                    items: [
                      CircularMenuItem(
                        color: MyColors.navy,
                        icon: Icons.person_2_outlined,
                        onTap: () => Navigator.pushNamed(context, '/ProfilePage', arguments: user),
                      ),
                      CircularMenuItem(
                        color: MyColors.navy,
                        icon: Icons.add,
                        onTap: () => _showAddFriendPopup(context, user.id!),
                      ),
                      CircularMenuItem(
                        color: MyColors.navy,
                        icon: CupertinoIcons.gift,
                        onTap: () => Navigator.pushNamed(context, '/GiftListPage', arguments: user.id),
                      ),
                      CircularMenuItem(
                        color: MyColors.navy,
                        icon: CupertinoIcons.calendar_badge_plus,
                        onTap: () => Navigator.pushNamed(context, '/EventListPage', arguments: user.id),
                      ),
                    ],
                  ),
                ),*/
            ],
          ),
        ),
        /*floatingActionButton: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 40),
          child: CircularMenu(
            radius: 100,
            alignment: Alignment.bottomCenter,
            toggleButtonColor: MyColors.orange,
            items: [
              CircularMenuItem(
                color: MyColors.navy,
                icon: Icons.person_2_outlined,
                onTap: () => Navigator.pushNamed(context, '/ProfilePage', arguments: user),
              ),
              CircularMenuItem(
                color: MyColors.navy,
                icon: Icons.add,
                onTap: () => _showAddFriendPopup(context, user.id!),
              ),
              CircularMenuItem(
                color: MyColors.navy,
                icon: CupertinoIcons.gift,
                onTap: () => Navigator.pushNamed(context, '/GiftListPage', arguments: user.id),
              ),
              CircularMenuItem(
                color: MyColors.navy,
                icon: CupertinoIcons.calendar_badge_plus,
                onTap: () => Navigator.pushNamed(context, '/EventListPage', arguments: user.id),
              ),
            ],
          ),
        )*/

        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: MyColors.blue,
          color: MyColors.orange,
          items: const <Widget>[
            Icon(Icons.person_2_outlined, size: 30, key: Key('profileIcon'),),
            Icon(Icons.add, size: 30, key: Key('addIcon'),),
            Icon(CupertinoIcons.gift, size: 30, key: Key('giftIcon'),),
            Icon(CupertinoIcons.calendar_badge_plus, size: 30, key: Key('eventIcon'),),
          ],
          onTap: (index) {
            switch(index){
              case 0:
                Navigator.pushNamed(context, '/ProfilePage', arguments: user);
                break;
              case 1:
                _showAddFriendPopup(context, user.id);
                break;
              case 2:
                Navigator.pushNamed(context, '/GiftListPage', arguments: user.id);
                break;
              case 3:
                Navigator.pushNamed(context, '/EventListPage', arguments: user.id);
                break;
            }
          },
        )
      );
  }
}


