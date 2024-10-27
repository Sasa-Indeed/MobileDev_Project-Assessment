import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hedieaty_app/custom_widgets/colors.dart';


class PledgedGiftsPage extends StatefulWidget {
  const PledgedGiftsPage({super.key});

  @override
  _PledgedGiftsPageState createState() => _PledgedGiftsPageState();
}

class _PledgedGiftsPageState extends State<PledgedGiftsPage> {

  List<PledgedGift> pledgedGifts = [
    PledgedGift(giftName: "Watch", friendName: "John Doe", dueDate: DateTime.now().subtract(Duration(days: 5)), isPledged: true),
    PledgedGift(giftName: "Book", friendName: "Jane Smith", dueDate:  DateTime.now().add(Duration(days: 10)), isPledged: false),
    // Add more sample data as needed
  ];

  Future<DateTime?> _pickDateTime(BuildContext context) async {
    // Step 1: Pick the date
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    // If no date is selected, return null
    if (pickedDate == null) return null;

    // Step 2: Combine the picked date and time into a DateTime object
    final DateTime combinedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
    );

    return combinedDateTime;
  }

  void _addGift() {
    setState(() {
      pledgedGifts.add(PledgedGift(
          giftName: "PlaceHolder",
          friendName: "PlaceHolder",
          dueDate: DateTime.now(),
          isPledged: true));
    });
  }

  void _editGift(int index) {
    final gift = pledgedGifts[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Pledge"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Gift Name"),
                onChanged: (value) {
                  setState(() {
                    gift.giftName = value;
                  });
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Friend Name"),
                onChanged: (value) {
                  setState(() {
                    gift.friendName = value;
                  });
                },
              ),
              TextButton(
                child:  Text("Date: ${_formatDateTime(gift.dueDate)}"),
                onPressed: () async {
                  DateTime? pickedDate = await _pickDateTime(context);
                  setState(() {
                    if(pickedDate != null){
                      gift.dueDate = pickedDate;
                    }else{
                      gift.dueDate = DateTime.now();
                    }
                  });
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  pledgedGifts[index] = gift;
                });
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _removeGift(int index) {
    setState(() {
      pledgedGifts.removeAt(index);
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.gray,
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: Text(
            "Pledged Gifts",
            style: TextStyle(
              color: MyColors.gray,
              fontFamily: "playWrite",
              fontSize: 40,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: MyColors.navy,
      ),
      body: ListView.builder(
        itemCount: pledgedGifts.length,
        itemBuilder: (context, index) {
          final gift = pledgedGifts[index];
          return Card(
            color: MyColors.blue,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(
                  gift.giftName,
                  style: TextStyle(
                    color: gift.dueDate.isBefore(DateTime.now()) ? MyColors.orange.withOpacity(0.5) : MyColors.orange,
                    fontFamily: "playWrite",
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5,),
                  Text(
                      "Friend: ${gift.friendName}",
                      style: TextStyle(
                        color: gift.dueDate.isBefore(DateTime.now()) ? MyColors.gray.withOpacity(0.5) : MyColors.gray,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                  ),
                  const SizedBox(height: 8,),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: (gift.dueDate.isBefore(DateTime.now())) ? Colors.red : Colors.green,
                      borderRadius: BorderRadius.circular(15),
                    ),
                      child: Text(
                        "Due Date: ${_formatDateTime(gift.dueDate)}",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!gift.dueDate.isBefore(DateTime.now()))
                    IconButton(
                      icon: const Icon(Icons.edit),
                      color: MyColors.gray,
                      onPressed: () => _editGift(index),
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    color: MyColors.gray,
                    onPressed: () => _removeGift(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: _addGift,
          backgroundColor: MyColors.navy,
          tooltip: 'Add Event',
          child: const Icon(
            Icons.add,
            color: MyColors.orange,
          ),
      ),
    );
  }
}

class PledgedGift {
  String giftName;
  String friendName;
  DateTime dueDate;
  bool isPledged;

  PledgedGift({
      required this.giftName,
      required this.friendName,
      required this.dueDate,
      this.isPledged = false});
}
