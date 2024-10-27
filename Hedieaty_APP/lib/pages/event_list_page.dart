import 'package:flutter/material.dart';
import 'package:hedieaty_app/custom_widgets/colors.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class Event {
  String name;
  String category;
  DateTime date;
  String status; // "Upcoming", "Current", "Past"

  Event({
    required this.name,
    required this.category,
    required this.date,
    required this.status,
  });
}

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<Event> events = [
    Event(name: 'Sarah\'s Birthday', category: 'Birthday', date: DateTime.now().add(Duration(days: 10)), status: 'Upcoming'),
    Event(name: 'Wedding', category: 'Family', date: DateTime.now(), status: 'Current'),
    Event(name: 'Reunion', category: 'Friends', date: DateTime.now().subtract(Duration(days: 5)), status: 'Past'),
  ];

  String selectedSortCriteria = 'name';
  DateTime? newDate;

  // Function to sort events
  void _sortEvents(String criteria) {
    setState(() {
      if (criteria == 'name') {
        events.sort((a, b) => a.name.compareTo(b.name));
      } else if (criteria == 'category') {
        events.sort((a, b) => a.category.compareTo(b.category));
      } else if (criteria == 'status') {
        events.sort((a, b) => a.status.compareTo(b.status));
      }
    });
  }

  // Function to delete an event
  void _deleteEvent(int index) {
    setState(() {
      events.removeAt(index);
    });
  }

  // Function to add a new event (this is just a placeholder)
  void _addEvent() {
    showDialog(
        context: context,
        builder: (context) {
          String newName = '';
          String newCategory = '';
          String newStatus = '';
          return AlertDialog(
            title: const Text("Add New Event"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(hintText: "Event Name"),
                  onChanged: (value) => newName = value,
                ),
                TextField(
                  decoration: const InputDecoration(hintText: "Category"),
                  onChanged: (value) => newCategory = value,
                ),
                TextField(
                  decoration: const InputDecoration(hintText: "Status"),
                  onChanged: (value) => newStatus = value,
                ),
                TextButton(
                    child:  Text(newDate != null ? "Date: ${_formatDateTime(newDate!)}" : "Pick a Date"),
                    onPressed: () async {
                      DateTime? pickedDate = await _pickDateTime(context);
                      setState(() {
                        if(pickedDate != null){
                          newDate = pickedDate;
                        }else{
                          newDate = DateTime.now();
                        }
                      });
                      //(context as Element).markNeedsBuild();
                    },
                )
              ],
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text("Add"),
                onPressed: () {
                  if (newName.isNotEmpty && newCategory.isNotEmpty && newCategory.isNotEmpty && (newDate != null)) {
                    setState(() {
                        events.add(Event(name: newName, category: newCategory, status: newStatus, date: newDate!));
                    });
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        });
  }

  // Function to edit an event (this is just a placeholder)
  void _editEvent(int index) {
    // Add your code for editing events here
  }

  // Function to format date and time
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy – kk:mm').format(dateTime);
  }

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

    // Step 2: Pick the time
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    // If no time is selected, return null
    if (pickedTime == null) return null;

    // Step 3: Combine the picked date and time into a DateTime object
    final DateTime combinedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    return combinedDateTime;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.gray,
      appBar: AppBar(
        title: const Text(
            'Event List',
            style: TextStyle(
                color: MyColors.gray,
                fontFamily: "playWrite",
                fontSize: 30
            ),
          ),
        backgroundColor: MyColors.navy,
        actions: [
          PopupMenuButton<String>(
            onSelected: _sortEvents,
            iconColor: MyColors.gray,
            color: MyColors.navy,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                )
            ),
            itemBuilder: (BuildContext context) {
              return {'name', 'category', 'status'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(
                      'Sort by $choice',
                      style: const TextStyle(
                        color: MyColors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          return Card(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  )
              ),
              child: ListTile(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    )
                ),
                iconColor: MyColors.orange,
                minVerticalPadding: 10,
                tileColor: MyColors.blue,
                textColor: MyColors.orange,
                title: Text(events[index].name),
                titleTextStyle: const TextStyle(
                    color: MyColors.gray,
                    fontFamily: "playWrite",
                    fontSize: 30,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Category: ${events[index].category}'),
                    Text('Status: ${events[index].status}'),
                    Text('Date: ${_formatDateTime(events[index].date)}'), // Display date and time
                  ],
                ),
                subtitleTextStyle: const  TextStyle(
                    color: MyColors.gray,
                    fontFamily: "poppins",
                    fontSize: 15,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editEvent(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteEvent(index),
                    ),
                  ],
                ),
              )
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
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
