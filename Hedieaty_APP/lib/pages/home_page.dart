import 'package:flutter/material.dart';
import 'package:hedieaty_app/custom_widgets/colors.dart';
import 'package:hedieaty_app/models/user.dart';
import '../custom_widgets/friend.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:flutter/cupertino.dart';

import '../database/friends_database_services.dart';
import '../database/user_database_services.dart';
import '../models/friends.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreen();

}

class _HomeScreen extends State<HomeScreen> {

  void _showAddFriendPopup(BuildContext context, int currentUserID) {
    final TextEditingController inputController = TextEditingController();
    bool isUsingEmail = true; // Default to email input

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
                  onPressed: () => Navigator.pop(context), // Close dialog
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    String input = inputController.text.trim();

                    if (input.isEmpty) {
                      _showErrorDialog(context, "Invalid Input", "Please enter a valid email or phone number.");
                      return;
                    }

                    int friendID = -1;

                    if (isUsingEmail) {
                      friendID = await UserDatabaseServices.findUserByEmail(input);
                    } else {
                      friendID = await UserDatabaseServices.findUserByPhoneNumber(input);
                    }

                    if (friendID == -1) {
                      // Show error and keep dialog open
                      _showErrorDialog(context, "Friend Not Found", "No user matches the provided information.");
                      return;
                    }

                    int existingFriend1 = await FriendsDatabaseServices.checkFriendExists(currentUserID, friendID);
                    int existingFriend2 = await FriendsDatabaseServices.checkFriendExists(friendID, currentUserID);
                    print(existingFriend1);
                    print(existingFriend2);
                    if (existingFriend1 == -1 && existingFriend2 == -1) {
                      // Add friend and close dialog
                      Friend newFriend = Friend(userID: currentUserID, friendID: friendID);
                      await FriendsDatabaseServices.insertFriend(newFriend);

                      Navigator.pop(context); // Close the input dialog
                      _showSuccessDialog(context, "Friend Added", "Friend has been successfully added!");
                    }else{
                      // Show error and keep dialog open
                      _showErrorDialog(context, "Friend Exists", "This friend is already in your list.");
                      return;
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
    final User user = ModalRoute.of(context)!.settings.arguments as User;
    return  MaterialApp(
      title: "Home",
      home: Scaffold(
        backgroundColor: MyColors.gray,
        appBar: AppBar(
          title: const Text(
              "Hedieaty",
              style: TextStyle(
                  color: MyColors.gray,
                  fontFamily: "playWrite",
                  fontSize: 30
              ),
          ),
          centerTitle: true,
          backgroundColor: MyColors.navy,
        ),
        body: Column(
          children: [
             const Friends(image: "asset/man.jpg", name: "Sasa", eventStatus: "Birthday"),
              ElevatedButton(
                  onPressed: () async {
                    List<int> friends = await FriendsDatabaseServices.getFriendsIDs(user.id!);
                    for(int f in friends){
                      print(f);
                    }
                  }, 
                  child: const Text("pressme"))
          ],
        ),
        floatingActionButton: CircularMenu(
          alignment: Alignment.bottomCenter,
          toggleButtonColor: MyColors.orange,
          items: [
            CircularMenuItem(
              color: MyColors.navy,
              icon: Icons.person_2_outlined,
              onTap: (){
                Navigator.pushNamed(context, '/ProfilePage',arguments: user);
                }, // Uses the correct context
            ),
            CircularMenuItem(
              color: MyColors.navy,
              icon: Icons.add,
              onTap: () {
                _showAddFriendPopup(context, user.id!);
              },
            ),
            CircularMenuItem(
              color: MyColors.navy,
              icon: CupertinoIcons.gift,
              onTap: () {
                Navigator.pushNamed(context, '/GiftListPage', arguments: user.id);
              },
            ),
            CircularMenuItem(
              color: MyColors.navy,
              icon: CupertinoIcons.calendar_badge_plus,
              onTap: () {
                Navigator.pushNamed(context, '/EventListPage', arguments: user.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

