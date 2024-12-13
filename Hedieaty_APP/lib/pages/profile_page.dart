import 'package:flutter/material.dart';
import 'package:hedieaty_app/custom_widgets/colors.dart';
import 'package:hedieaty_app/database/user_database_services.dart';
import 'package:hedieaty_app/database/event_database_services.dart';
import 'package:hedieaty_app/database/gift_database_services.dart';
import '../models/user.dart';
import '../models/event.dart';
import '../models/gift.dart';
import 'update_profile_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreen createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {
  IconData iconImage = Icons.notifications_active_rounded;
  bool _notification = true;

  List<Event> _upcomingEvents = [];
  Map<int, List<Gift>> _eventGifts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      Userdb user = ModalRoute.of(context)!.settings.arguments as Userdb; // Get user
      int userID = user.id!; // Extract userID
      List<Event> events = await EventDatabaseServices.getUpcomingEventsByUserID(userID);
      Map<int, List<Gift>> giftsMap = {};

      for (var event in events) {
        giftsMap[event.id!] = await GiftDatabaseServices.getGiftsByEventID(event.id!);
      }

      setState(() {
        _upcomingEvents = events;
        _eventGifts = giftsMap;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load events: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    Userdb user = ModalRoute.of(context)!.settings.arguments as Userdb;

    // Fetch data if it's the first build
    if (_isLoading) {
      _fetchData(); // Now we can safely access user.id
    }

    _notification = user.isNotificationEnabled;
    if (!_notification) {
      iconImage = Icons.notifications_off_rounded;
    }

    return Scaffold(
      backgroundColor: MyColors.gray,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: MyColors.orange, // Set the back arrow color
        ),
        title: const Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: Text(
            "Profile",
            style: TextStyle(
              color: MyColors.gray,
              fontFamily: "playWrite",
              fontSize: 50,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: MyColors.navy,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(user.profileImagePath),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(user.phoneNumber,
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.navy,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UpdateProfilePage(
                                name: user.name,
                                email: user.email,
                                phoneNumber: user.phoneNumber,
                                user: user,
                              )),
                        );
                      },
                      child: const Text("Update Profile",
                          style: TextStyle(
                            fontFamily: "playWrite",
                            color: MyColors.orange,
                          )),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Notification Settings
            const Text(
              "Notification Settings",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              activeTrackColor: MyColors.orange,
              title: const Text("Receive notifications"),
              value: _notification,
              onChanged: (bool value) {
                setState(() {
                  _notification = value;
                  iconImage = value
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_off_rounded;
                  user.isNotificationEnabled = value;
                  UserDatabaseServices.updateUser(user);
                });
              },
              secondary: Icon(iconImage),
            ),
            const SizedBox(height: 24),
            // Events Section
            const Text(
              "My Events",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _upcomingEvents.length,
                itemBuilder: (context, index) {
                  Event event = _upcomingEvents[index];
                  List<Gift> gifts = _eventGifts[event.id] ?? [];
                  return ExpansionTile(
                    title: Text(event.name),
                    subtitle: Text(
                        "${gifts.length} associated gift(s)"),
                    children: gifts
                        .map((gift) => ListTile(
                      title: Text(gift.name),
                      leading: const Icon(Icons.card_giftcard),
                    ))
                        .toList(),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Pledged Gifts Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.navy,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 15),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/PledgedGiftsPage');
                },
                child: const Text("My Pledged Gifts",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: "playWrite",
                      color: MyColors.orange,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
