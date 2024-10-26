import 'package:flutter/material.dart';
import 'package:hedieaty_app/elements/gift.dart';
import 'package:hedieaty_app/custom_widgets/colors.dart';

class GiftDetailsPage extends StatefulWidget {
  const GiftDetailsPage({super.key});

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final Gift gift = Gift(
      giftName: "Teddy Bear",
      category: "Toys",
      status: "Pending",
      imagePath: "asset/teddyBear.jpg");

 /* @override
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
  }*/

  // Function to display dialog to input image path
  Future<void> showImagePathDialog() async {
    if (!gift.isPledged) {
      final result = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          TextEditingController pathController = TextEditingController();
          return AlertDialog(
            title: Text('Enter Image Path'),
            content: TextField(
              controller: pathController,
              decoration: InputDecoration(hintText: "Image path"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, pathController.text),
                child: Text('OK'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: Text('Cancel'),
              ),
            ],
          );
        },
      );
      if (result != null) {
        setState(() {
          gift.imagePath = result;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (gift == null) return CircularProgressIndicator();

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
        child: Column(
          children: [
            // Profile Picture with Edit/Remove Icon
            GestureDetector(
              onTap: () async {
                if (!gift.isPledged) {
                  await showImagePathDialog();
                }
              },
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(gift.imagePath),
                  ),
                  CircleAvatar(
                    backgroundColor: MyColors.navy,
                    radius: 15,
                    child: Icon(
                      gift.isPledged ? Icons.close : Icons.edit,
                      size: 20,
                      color: MyColors.orange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Form Fields
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(//Gift Name
                    initialValue: gift.giftName,
                    style: TextStyle(
                      color: gift.isPledged ? MyColors.gray.withOpacity(0.5) : MyColors.gray,
                      fontSize: 20,
                    ),
                    enabled: !gift.isPledged,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: MyColors.blue,
                        labelText: 'Gift Name',
                        labelStyle: TextStyle(
                          color: gift.isPledged ? MyColors.orange.withOpacity(0.5) : MyColors.orange,
                          fontFamily: "playWrite",
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          backgroundColor: MyColors.blue,
                        ),
                        border: const OutlineInputBorder(),
                    ),
                    onSaved: (value) => gift.giftName = value ?? '',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the gift name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  TextFormField( //Category
                    initialValue: gift.category,
                    style: TextStyle(
                      color: gift.isPledged ? MyColors.gray.withOpacity(0.5) : MyColors.gray,
                      fontSize: 20,
                    ),
                    enabled: !gift.isPledged,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: MyColors.blue,
                        labelText: 'Category',
                        labelStyle: TextStyle(
                          color: gift.isPledged ? MyColors.orange.withOpacity(0.5) : MyColors.orange,
                          fontFamily: "playWrite",
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          backgroundColor: MyColors.blue,
                        ),
                        border: const OutlineInputBorder(),
                    ),
                    onSaved: (value) => gift.category = value ?? '',
                  ),
                  const SizedBox(height: 30),
                  TextFormField(// Price
                    initialValue: gift.price.toString(),
                    style: TextStyle(
                      color: gift.isPledged ? MyColors.gray.withOpacity(0.5) : MyColors.gray,
                      fontSize: 20,
                    ),
                    enabled: !gift.isPledged,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: MyColors.blue,
                        labelText: 'Price',
                        labelStyle: TextStyle(
                          color: gift.isPledged ? MyColors.orange.withOpacity(0.5) : MyColors.orange,
                          fontFamily: "playWrite",
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          backgroundColor: MyColors.blue,
                        ),
                        border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => gift.price = double.tryParse(value ?? '') ?? 0.0,
                  ),
                  const SizedBox(height: 30),
                  TextFormField( //Description
                    initialValue: gift.description,
                    style: TextStyle(
                      color: gift.isPledged ? MyColors.gray.withOpacity(0.5) : MyColors.gray,
                      fontSize: 20,
                    ),
                    enabled: !gift.isPledged,
                    maxLines: 5, // Makes the field tall
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: MyColors.blue,
                      labelText: 'Description',
                      labelStyle: TextStyle(
                          color: gift.isPledged ? MyColors.orange.withOpacity(0.5) : MyColors.orange,
                          fontFamily: "playWrite",
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          backgroundColor: MyColors.blue,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    onSaved: (value) => gift.description = value ?? '',
                  ),
                  const SizedBox(height: 16),
                  Container(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      decoration: BoxDecoration(
                        color: MyColors.blue,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              'Status: ${gift.isPledged ? 'Pledged' : 'Available'}',
                              style: const TextStyle(
                                color: MyColors.orange,
                                fontFamily: "playWrite",
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                          ),
                          Switch(
                            activeTrackColor: MyColors.orange,
                            value: gift.isPledged,
                            onChanged: (value) {
                              setState(() {
                                gift.isPledged = value;
                              });
                            },
                          ),
                        ],
                      ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.navy,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                    onPressed: !gift.isPledged
                        ? () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _formKey.currentState?.save();
                        Navigator.pop(context, gift);
                      }
                    }
                        : null,
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
