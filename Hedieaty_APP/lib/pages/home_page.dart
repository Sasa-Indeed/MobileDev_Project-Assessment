import 'package:flutter/material.dart';
import 'package:hedieaty_app/custom_widgets/colors.dart';
import 'package:hedieaty_app/database/event_database_services.dart';
import 'package:hedieaty_app/database/friends_database_services.dart';
import 'package:hedieaty_app/database/user_database_services.dart';
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
  late User user;
  List<FriendCard> friendCards = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchFriends();
    });
  }

  Future<void> _fetchFriends() async {
    try {
      List<int> friendIDs = await FriendsDatabaseServices.getFriendsIDs(user.id!);
      for(int i in friendIDs){
        print(i);
      }
      List<FriendCard> cards = [];

      for (int friendID in friendIDs) {
        String name = await UserDatabaseServices.getUserNameByID(friendID);
        String profileImagePath = await UserDatabaseServices.getUserProfileImagePath(friendID);
        List<Event> events = await EventDatabaseServices.getUpcomingEventsByUserID(friendID);
        String mostRecentEvent = events.isNotEmpty ? events.first.name : 'No upcoming events';

        cards.add(
          FriendCard(
            name: name,
            image: profileImagePath,
            eventStatus: mostRecentEvent,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/FriendDetailsPage',
                arguments: {'user': user, 'friendID': friendID},
              );
            },
          ),
        );
      }

      setState(() {
        friendCards = cards;
      });
    } catch (error) {
      print("Error fetching friends: $error");
    }
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
                          backgroundColor: isUsingEmail ? Colors.blue : Colors.grey,
                        ),
                        child: const Text("Email"),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () => setState(() => isUsingEmail = false),
                        style: TextButton.styleFrom(
                          backgroundColor: isUsingEmail ? Colors.grey : Colors.blue,
                        ),
                        child: const Text("Phone"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
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
                  onPressed: () async {
                    String input = inputController.text.trim();
                    if (input.isEmpty) {
                      _showErrorDialog(context, "Invalid Input", "Please enter valid information.");
                      return;
                    }

                    int friendID = isUsingEmail
                        ? await UserDatabaseServices.findUserByEmail(input)
                        : await UserDatabaseServices.findUserByPhoneNumber(input);

                    if (friendID == -1) {
                      _showErrorDialog(context, "Friend Not Found", "No user matches the provided information.");
                      return;
                    }

                    bool isAlreadyFriend = await FriendsDatabaseServices.checkFriendExists(user.id!, friendID) != -1;

                    if (isAlreadyFriend) {
                      _showErrorDialog(context, "Friend Exists", "This friend is already in your list.");
                      return;
                    }

                    await FriendsDatabaseServices.insertFriend(Friend(userID: user.id!, friendID: friendID));
                    Navigator.pop(context);
                    _showSuccessDialog(context, "Friend Added", "Friend has been successfully added!");
                    _fetchFriends(); // Refresh the friends list
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
    user = ModalRoute.of(context)!.settings.arguments as User;

    return MaterialApp(
      title: "Home",
      home: Scaffold(
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
        body: friendCards.isEmpty
            ? const Center(
          child: Text(
            "No friends yet, Add Friends to have fun!",
            style: TextStyle(fontSize: 20, color: Colors.grey),
          ),
        )
            : ListView(children: friendCards),
        floatingActionButton: CircularMenu(
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
      ),
    );
  }
}


