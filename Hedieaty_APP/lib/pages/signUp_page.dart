import 'package:flutter/material.dart';
import '../custom_widgets/colors.dart';
import 'package:hedieaty_app/models/user.dart';
import 'package:hedieaty_app/database/user_database_services.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final List<String> _preferences = [
    "Books",
    "Clothes",
    "Electronics",
    "Experiences",
    "Food/Gourmet Items",
    "Gift Cards",
    "Home Decor",
    "Jewelry",
    "Personal Care Products",
    "Subscriptions",
    "Toys/Games"
  ];

  List<String> _selectedPreferences = []; // List for selected preferences
  bool _notificationsEnabled = false; // For notification toggle
  IconData _iconImage = Icons.notifications_off_rounded;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  void _showPopup(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _registerUser() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final Cpassword = _confirmPasswordController.text.trim();

    if(name.isEmpty || email.isEmpty || phone.isEmpty
        || password.isEmpty || _selectedPreferences.isEmpty){
      _showPopup(context, "Missing Field(s)", "Please enter the data in all the fields.");
      return;
    }

    if(password != Cpassword){
      _showPopup(context, "Password Mismatch", "Please enter the password again.");
      return;
    }else if(!_isValidEmail(email)){
      _showPopup(context, "Invalid Email", "Please enter a valid email address.");
      return;
    }

    User user = User(
      name: name,
      email: email,
      password: password,
      phoneNumber: phone,
      isNotificationEnabled: _notificationsEnabled,
      preferences: _selectedPreferences,
    );

    int userId = await UserDatabaseServices.insertUser(user);
    user.id = userId;

    if(userId < 0){
      _showPopup(context, "User Already Exists", "Please enter a new email address or sign in.");
      return;
    }else{
      Navigator.pushNamed(context, '/Home', arguments: user);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Ensure the layout adjusts when the keyboard is open
      backgroundColor: Colors.white,
      body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                // Dynamic padding for keyboard
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Image
                    Stack(
                      children: [
                        Container(
                          height: 300,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('asset/SignInImage.jpeg'),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(40),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Form Fields
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "New User?\nRegister Here",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              fontFamily: "playWrite",
                              color: MyColors.orange,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _nameController,
                            label: "Name",
                            icon: Icons.person,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _emailController,
                            label: "Email",
                            icon: Icons.email,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _phoneController,
                            label: "Phone Number",
                            icon: Icons.phone,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _passwordController,
                            label: "Password",
                            icon: Icons.lock,
                            obscureText: !_isPasswordVisible,
                            onVisibilityToggle: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _confirmPasswordController,
                            label: "Confirm Password",
                            icon: Icons.lock,
                            obscureText: !_isConfirmPasswordVisible,
                            onVisibilityToggle: () {
                              setState(() {
                                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                          const SizedBox(height: 20),

                          // Preferences Dropdown
                          const Text(
                            "Select Your Preferences",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: _preferences
                                .map((preference) => DropdownMenuItem<String>(
                              value: preference,
                              child: Text(preference, overflow: TextOverflow.ellipsis),
                            ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null && !_selectedPreferences.contains(value)) {
                                setState(() {
                                  _selectedPreferences.add(value); // Add selected preference
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 20),

                          // Display Selected Preferences as Chips
                          Wrap(
                            spacing: 10,
                            children: _selectedPreferences
                                .map((preference) => Chip(
                              label: Text(preference),
                              onDeleted: () {
                                setState(() {
                                  _selectedPreferences.remove(preference); // Remove preference
                                });
                              },
                            ))
                                .toList(),
                          ),
                          const SizedBox(height: 20),
                          // Notifications Toggle
                          SwitchListTile(
                            title: const Text(
                              "Enable Notifications",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            activeTrackColor: MyColors.orange,
                            secondary: Icon(_iconImage),
                            value: _notificationsEnabled,
                            onChanged: (value) {
                              setState(() {
                                _notificationsEnabled = value; // Toggle notifications
                                if(value){
                                  _iconImage = Icons.notifications_active_rounded;
                                }else{
                                  _iconImage = Icons.notifications_off_rounded;
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: const LinearGradient(colors: [MyColors.orange, MyColors.blue]),
                              ),
                              child: ElevatedButton(
                                onPressed: _registerUser,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                child: const Text(
                                  "Signup",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    fontFamily: "poppins",
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom GestureDetector
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Already Have an Account?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    VoidCallback? onVisibilityToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: onVisibilityToggle != null
            ? GestureDetector(
          onTap: onVisibilityToggle,
          child: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
        )
            : Icon(icon),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
