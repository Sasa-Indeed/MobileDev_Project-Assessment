import 'package:flutter/material.dart';
import 'package:hedieaty_app/custom_widgets/colors.dart';
import 'package:hedieaty_app/database/event_database_services.dart';
import 'package:hedieaty_app/models/event.dart';
import 'package:intl/intl.dart';

enum EventStatus { Past, Current, Upcoming }

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<Event> events = [];
  int userID = 0;
  String selectedSortCriteria = 'name';
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (userID == 0) {
      // Ensure we only set the userID once
      userID = ModalRoute.of(context)!.settings.arguments as int;
      fetchEvents();
    }
  }

  Future<void> fetchEvents() async {
    setState(() {
      isLoading = true;
    });
    events = await EventDatabaseServices.getEventsByUser(userID);
    setState(() {
      isLoading = false;
    });
  }

  EventStatus getEventStatus(DateTime eventDate) {
    final currentDate = DateTime.now();
    if (eventDate.isBefore(currentDate)) return EventStatus.Past;
    if (eventDate.isAtSameMomentAs(currentDate) || eventDate.isAfter(currentDate)) return EventStatus.Current;
    return EventStatus.Upcoming;
  }

  void _sortEvents(String criteria) {
    setState(() {
      if (criteria == 'name') {
        events.sort((a, b) => a.name.compareTo(b.name));
      } else if (criteria == 'category') {
        events.sort((a, b) => a.category.compareTo(b.category));
      } else if (criteria == 'status') {
        events.sort((a, b) {
          EventStatus statusA = getEventStatus(a.date);
          EventStatus statusB = getEventStatus(b.date);
          return statusA.index.compareTo(statusB.index);
        });
      }
    });
  }

  void _deleteEvent(Event event) async {
    await EventDatabaseServices.deleteEvent(event.id!);
    fetchEvents();
  }

  void _editEvent(Event event) {
    showDialog(
      context: context,
      builder: (context) {
        String updatedName = event.name;
        String updatedLocation = event.location;
        String updatedCategory = event.category;
        String updatedDescription = event.description;
        DateTime updatedDate = event.date;

        return AlertDialog(
          title: const Text("Edit Event"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(hintText: "Event Name"),
                controller: TextEditingController(text: event.name),
                onChanged: (value) => updatedName = value,
              ),
              TextField(
                decoration: const InputDecoration(hintText: "Location"),
                controller: TextEditingController(text: event.location),
                onChanged: (value) => updatedLocation = value,
              ),
              TextField(
                decoration: const InputDecoration(hintText: "Category"),
                controller: TextEditingController(text: event.category),
                onChanged: (value) => updatedCategory = value,
              ),
              TextField(
                decoration: const InputDecoration(hintText: "Description"),
                controller: TextEditingController(text: event.description),
                onChanged: (value) => updatedDescription = value,
              ),
              TextButton(
                child: Text("Date: ${_formatDateTime(updatedDate)}"),
                onPressed: () async {
                  DateTime? pickedDate = await _pickDateTime(context);
                  if (pickedDate != null) {
                    setState(() {
                      updatedDate = pickedDate;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Save"),
              onPressed: () async {
                if (updatedName.isNotEmpty &&
                    updatedLocation.isNotEmpty &&
                    updatedCategory.isNotEmpty &&
                    updatedDescription.isNotEmpty) {
                  await EventDatabaseServices.updateEvent(Event(
                    id: event.id,
                    name: updatedName,
                    location: updatedLocation,
                    category: updatedCategory,
                    description: updatedDescription,
                    date: updatedDate,
                    userID: userID,
                  ));
                  fetchEvents();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _addEvent() {
    showDialog(
      context: context,
      builder: (context) {
        String newName = '';
        String newLocation = '';
        String newCategory = '';
        String newDescription = '';
        DateTime? newDate;

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
                decoration: const InputDecoration(hintText: "Location"),
                onChanged: (value) => newLocation = value,
              ),
              TextField(
                decoration: const InputDecoration(hintText: "Category"),
                onChanged: (value) => newCategory = value,
              ),
              TextField(
                decoration: const InputDecoration(hintText: "Description"),
                onChanged: (value) => newDescription = value,
              ),
              TextButton(
                child: Text(newDate != null ? "Date: ${_formatDateTime(newDate!)}" : "Pick a Date"),
                onPressed: () async {
                  DateTime? pickedDate = await _pickDateTime(context);
                  setState(() {
                    newDate = pickedDate ?? DateTime.now();
                  });
                },
              ),
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
                if (newName.isNotEmpty &&
                    newLocation.isNotEmpty &&
                    newCategory.isNotEmpty &&
                    newDescription.isNotEmpty &&
                    newDate != null) {
                  EventDatabaseServices.insertEvent(
                    Event(
                      name: newName,
                      date: newDate!,
                      location: newLocation,
                      category: newCategory,
                      description: newDescription,
                      userID: userID,
                    ),
                  );
                  fetchEvents();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy – kk:mm').format(dateTime);
  }

  Future<DateTime?> _pickDateTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return null;

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return null;

    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
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
            fontSize: 30,
          ),
        ),
        backgroundColor: MyColors.navy,
        actions: [
          PopupMenuButton<String>(
            onSelected: _sortEvents,
            itemBuilder: (context) {
              return {'name', 'category', 'status'}.map((choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text("Sort by $choice"),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : events.isEmpty
          ? Center(
        child: Image.asset(
          'asset/images/no_events.jpeg',
          fit: BoxFit.contain,
        ),
      )
          : ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          return Card(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            child: ListTile(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              iconColor: MyColors.orange,
              minVerticalPadding: 10,
              tileColor: MyColors.blue,
              textColor: MyColors.orange,
              title: Text(
                events[index].name,
                style: const TextStyle(
                  color: MyColors.gray,
                  fontFamily: "playWrite",
                  fontSize: 30,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date: ${_formatDateTime(events[index].date)}'),
                  Text('Location: ${events[index].location}'),
                  Text('Category: ${events[index].category}'),
                  Text('Description: ${events[index].description}'),
                ],
              ),
              subtitleTextStyle: const TextStyle(
                color: MyColors.gray,
                fontFamily: "poppins",
                fontSize: 15,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editEvent(events[index]),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteEvent(events[index]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
