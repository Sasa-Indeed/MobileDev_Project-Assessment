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
  Gift? gift;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Gift) {
        setState(() {
          gift = args;
        });
      }
    });
  }

  // Save changes to the database
  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      if (gift != null) {
        await GiftDatabaseServices.updateGift(gift!);
      }
      Navigator.pop(context, gift);
    }
  }

  // Update pledge status
  Future<void> _togglePledgeStatus(bool isPledged) async {
    if (gift != null) {
      setState(() {
        gift = gift!.copyWith(status: isPledged ? "Pledged" : "Pending");
      });
      await GiftDatabaseServices.updateGift(gift!);
    }
  }

  // Function to display dialog to input image path
  Future<void> showImagePathDialog() async {
    if (gift != null && gift!.status != "Pledged") {
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
        setState(() {
          gift = gift!.copyWith(imagePath: result);
        });
        await GiftDatabaseServices.updateGift(gift!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (gift == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: MyColors.gray,
      appBar: AppBar(
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
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    if (gift!.status != "Pledged") {
                      await showImagePathDialog();
                    }
                  },
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(gift!.imagePath ?? 'asset/gift.png'),
                      ),
                      CircleAvatar(
                        backgroundColor: MyColors.navy,
                        radius: 15,
                        child: Icon(
                          gift!.status == "Pledged" ? Icons.close : Icons.edit,
                          size: 20,
                          color: MyColors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Name
                TextFormField(
                  initialValue: gift!.name,
                  decoration: _buildInputDecoration('Gift Name'),
                  enabled: gift!.status != "Pledged",
                  onSaved: (value) {
                    if (value != null) {
                      gift = gift!.copyWith(name: value);
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the gift name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Description
                TextFormField(
                  initialValue: gift!.description,
                  decoration: _buildInputDecoration('Description'),
                  enabled: gift!.status != "Pledged",
                  maxLines: 5,
                  onSaved: (value) {
                    if (value != null) {
                      gift = gift!.copyWith(description: value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Category
                TextFormField(
                  initialValue: gift!.category,
                  decoration: _buildInputDecoration('Category'),
                  enabled: gift!.status != "Pledged",
                  onSaved: (value) {
                    if (value != null) {
                      gift = gift!.copyWith(category: value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Price
                TextFormField(
                  initialValue: gift!.price.toString(),
                  decoration: _buildInputDecoration('Price'),
                  enabled: gift!.status != "Pledged",
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    if (value != null) {
                      gift = gift!.copyWith(price: double.tryParse(value) ?? 0.0);
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Status: ${gift!.status}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: MyColors.orange,
                      ),
                    ),
                    Switch(
                      activeTrackColor: MyColors.orange,
                      value: gift!.status == "Pledged",
                      onChanged: (value) => _togglePledgeStatus(value),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Save Button
                ElevatedButton(
                  onPressed: gift!.status != "Pledged" ? _saveChanges : null,
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String labelText) {
    return InputDecoration(
      filled: true,
      fillColor: MyColors.blue,
      labelText: labelText,
      labelStyle: const TextStyle(
        color: MyColors.orange,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      border: const OutlineInputBorder(),
    );
  }
}
