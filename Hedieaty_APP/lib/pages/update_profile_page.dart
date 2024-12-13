import 'package:flutter/material.dart';
import 'package:hedieaty_app/database/user_database_services.dart';

import '../models/user.dart';


class UpdateProfilePage extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneNumberController;
  final TextEditingController emailController;
  Userdb user;

  UpdateProfilePage({required String name, required String phoneNumber, required String email,required Userdb user})
      : nameController = TextEditingController(text: name),
        phoneNumberController = TextEditingController(text: phoneNumber),
        emailController = TextEditingController(text: email),
        user = user;

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: phoneNumberController,
              decoration: const InputDecoration(labelText: "Phone Number"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    user.name = nameController.text.trim();
                    if(_isValidEmail(emailController.text.trim())){
                      user.email = emailController.text.trim();
                    }
                    user.phoneNumber = phoneNumberController.text.trim();

                    UserDatabaseServices.updateUser(user);
                    Navigator.pop(context);
                  },
                  child: Text("Save"),
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
