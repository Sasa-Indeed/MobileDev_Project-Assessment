import 'dart:math';
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

  final List<String> _profileImages = List.generate(8, (index) => 'asset/profile_images/P${index + 1}.png',);

  List<String> _selectedPreferences = [];
  bool _notificationsEnabled = false;
  IconData _iconImage = Icons.notifications_off_rounded;

  String? _selectedProfileImage;

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

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        _selectedPreferences.isEmpty ||
        _selectedProfileImage == null) {
      _showPopup(context, "Missing Field(s)", "Please enter all the data.");
      return;
    }

    if (password != Cpassword) {
      _showPopup(context, "Password Mismatch", "Please enter the password again.");
      return;
    } else if (!_isValidEmail(email)) {
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
      profileImagePath: _selectedProfileImage!,
    );

    int userId = await UserDatabaseServices.insertUser(user);
    user.id = userId;

    if (userId < 0) {
      _showPopup(context, "User Already Exists", "Please enter a new email address or sign in.");
      return;
    } else {
      Navigator.pushNamed(context, '/Home', arguments: user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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
                        const Text(
                          "Choose Your Profile Image",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return GridView.builder(
                                  padding: const EdgeInsets.all(16),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                  ),
                                  itemCount: _profileImages.length,
                                  itemBuilder: (context, index) {
                                    final imagePath = _profileImages[index];
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedProfileImage = imagePath;
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: _selectedProfileImage == imagePath
                                                ? Colors.blue
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Image.asset(imagePath),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                _selectedProfileImage == null
                                    ? "Select Profile Image"
                                    : "Image Selected",
                                style: const TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Other form fields and buttons go here...
                      ],
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
