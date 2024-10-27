import 'package:flutter/material.dart';
import 'package:hedieaty_app/custom_widgets/colors.dart';
import 'update_profile_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreen createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {
  // Replace with actual user data retrieval
  final String username = "Sasa123";
  final String firstName = "Sasa";
  final String lastName = "Pizza";
  final String email = "hotChicken@example.com";
  IconData iconImage = Icons.notifications_active_rounded;
  bool _notification = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.gray,
      appBar: AppBar(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('asset/man.jpg'),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "$firstName $lastName",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(email, style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 8),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.navy,
                        ),
                      onPressed: () {
                        // Uncomment to navigate to update page
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UpdateProfilePage(
                              firstName: firstName,
                              lastName: lastName,
                              email: email,
                            )
                          ),
                        );
                      },
                      child: const Text(
                          "Update Profile",
                          style: TextStyle(
                            fontFamily: "playWrite",
                            color: MyColors.orange,
                          )
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Notification Settings
            const Text(
              "Notification Settings",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold
              ),
            ),
            SwitchListTile(
              activeTrackColor: MyColors.orange,
              title: const Text("Receive notifications"),
              value: _notification,
              onChanged: (bool value) {
                setState(() {
                  _notification = value;
                  if(value){
                    iconImage = Icons.notifications_active_rounded;
                  }else{
                    iconImage = Icons.notifications_off_rounded;
                  }
                });
              },
              secondary:  Icon(iconImage),
            ),
            const SizedBox(height: 24),
            // Events Section
            const Text(
              "My Events",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 3, // Replace with actual list count
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text("Event $index"),
                    subtitle: Text("Associated Gift $index"),
                    leading: const Icon(Icons.event),
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
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                onPressed: () {
                  // Add routing logic here for pledged gifts
                },
                child: const Text("My Pledged Gifts",
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: "playWrite",
                    color: MyColors.orange,
                  )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
