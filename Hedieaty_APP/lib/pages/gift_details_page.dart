import 'package:flutter/material.dart';
import 'package:hedieaty_app/models/gift.dart';
import 'package:hedieaty_app/custom_widgets/colors.dart';
import 'package:hedieaty_app/database/gift_database_services.dart';

class GiftDetailsPage extends StatefulWidget {
  const GiftDetailsPage({super.key});

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late Gift _gift; // Use late to initialize in initState

  // Controllers for text fields to capture changes
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Retrieve the gift from route arguments
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Gift) {
        setState(() {
          _gift = args;
          // Initialize controllers with current gift values
          _nameController = TextEditingController(text: _gift.name);
          _descriptionController = TextEditingController(text: _gift.description);
          _categoryController = TextEditingController(text: _gift.category);
          _priceController = TextEditingController(text: _gift.price.toString());
        });
      }
    });
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Create an updated gift object with new values
      Gift updatedGift = _gift.copyWith(
        name: _nameController.text,
        description: _descriptionController.text,
        category: _categoryController.text,
        price: double.tryParse(_priceController.text) ?? _gift.price,
      );

      try {
        // Update the gift in the database
        await GiftDatabaseServices.updateGift(updatedGift);

        // Pop the screen and return the updated gift
        Navigator.pop(context, updatedGift);
      } catch (e) {
        // Handle any potential errors (optional)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save gift: $e')),
        );
      }
    }
  }

  Future<void> _togglePledgeStatus(bool isPledged) async {
    try {
      // Create a new gift object with updated status
      Gift updatedGift = _gift.copyWith(
        status: isPledged ? "Pledged" : "Pending",
      );

      // Update the gift in the database
      await GiftDatabaseServices.updateGift(updatedGift);

      // Only update the local state after a successful database update
      setState(() {
        _gift = updatedGift;
      });
    } catch (e) {
      // Handle any potential errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }


  Future<void> _showImagePathDialog() async {
    if (_gift.status != "Pledged") {
      final result = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          TextEditingController pathController = TextEditingController();
          return AlertDialog(
            title: const Text('Enter Image Path'),
            content: TextField(
              controller: pathController,
              decoration: const InputDecoration(hintText: "Image path"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, pathController.text),
                child: const Text('OK'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );

      if (result != null) {
        try {
          // Create an updated gift object with new image path
          Gift updatedGift = _gift.copyWith(imagePath: result);

          // Update the gift in the database and local state
          await GiftDatabaseServices.updateGift(updatedGift);
          setState(() {
            _gift = updatedGift;
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update image path: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if _gift is initialized
    if (_nameController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
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
            "Gift Details",
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
          children: [
            GestureDetector(
              onTap: _showImagePathDialog,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: (_gift.imagePath == null )
                        ? const AssetImage('asset/gift.png') // Default asset image
                        : NetworkImage(_gift.imagePath!) as ImageProvider<Object>,
                  ),
                  CircleAvatar(
                    backgroundColor: MyColors.navy,
                    radius: 15,
                    child: Icon(
                      _gift.status == "Pledged" ? Icons.close : Icons.edit,
                      size: 20,
                      color: MyColors.orange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    style: TextStyle(
                      color: _gift.status == "Pledged"
                          ? MyColors.gray.withOpacity(0.5)
                          : MyColors.gray,
                      fontSize: 20,
                    ),
                    enabled: _gift.status != "Pledged",
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: MyColors.blue,
                      labelText: 'Gift Name',
                      labelStyle: TextStyle(
                        color: _gift.status == "Pledged"
                            ? MyColors.orange.withOpacity(0.5)
                            : MyColors.orange,
                        fontFamily: "playWrite",
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the gift name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _descriptionController,
                    style: TextStyle(
                      color: _gift.status == "Pledged"
                          ? MyColors.gray.withOpacity(0.5)
                          : MyColors.gray,
                      fontSize: 20,
                    ),
                    enabled: _gift.status != "Pledged",
                    maxLines: 5,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: MyColors.blue,
                      labelText: 'Description',
                      labelStyle: TextStyle(
                        color: _gift.status == "Pledged"
                            ? MyColors.orange.withOpacity(0.5)
                            : MyColors.orange,
                        fontFamily: "playWrite",
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _categoryController,
                    style: TextStyle(
                      color: _gift.status == "Pledged"
                          ? MyColors.gray.withOpacity(0.5)
                          : MyColors.gray,
                      fontSize: 20,
                    ),
                    enabled: _gift.status != "Pledged",
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: MyColors.blue,
                      labelText: 'Category',
                      labelStyle: TextStyle(
                        color: _gift.status == "Pledged"
                            ? MyColors.orange.withOpacity(0.5)
                            : MyColors.orange,
                        fontFamily: "playWrite",
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _priceController,
                    style: TextStyle(
                      color: _gift.status == "Pledged"
                          ? MyColors.gray.withOpacity(0.5)
                          : MyColors.gray,
                      fontSize: 20,
                    ),
                    enabled: _gift.status != "Pledged",
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: MyColors.blue,
                      labelText: 'Price',
                      labelStyle: TextStyle(
                        color: _gift.status == "Pledged"
                            ? MyColors.orange.withOpacity(0.5)
                            : MyColors.orange,
                        fontFamily: "playWrite",
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.navy,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                    onPressed: _saveChanges, // Always enabled
                    child: const Text(
                      'Save Gift',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: "playWrite",
                        color: MyColors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}