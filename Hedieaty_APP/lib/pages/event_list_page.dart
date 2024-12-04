import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
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
  List<Event> filteredEvents = [];
  int userID = 0;
  bool isLoading = true;
  EventStatus selectedStatus = EventStatus.Current;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (userID == 0) {
      userID = ModalRoute.of(context)!.settings.arguments as int;
      fetchEvents();
    }
  }

  Future<void> fetchEvents() async {
    setState(() {
      isLoading = true;
    });
    events = await EventDatabaseServices.getEventsByUser(userID);
    filterEvents(selectedStatus);
    setState(() {
      isLoading = false;
    });
  }

  void filterEvents(EventStatus status) {
    setState(() {
      selectedStatus = status;
      filteredEvents = events.where((event) {
        final eventStatus = getEventStatus(event.date);
        return eventStatus == status;
      }).toList();
    });
  }

  EventStatus getEventStatus(DateTime eventDate) {
    final currentDate = DateTime.now();
    final currentDateOnly = DateTime(currentDate.year, currentDate.month, currentDate.day);
    final eventDateOnly = DateTime(eventDate.year, eventDate.month, eventDate.day);

    if (eventDateOnly.isBefore(currentDateOnly)) return EventStatus.Past;
    if (eventDateOnly.isAtSameMomentAs(currentDateOnly)) return EventStatus.Current;
    return EventStatus.Upcoming;
  }


  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }


  Future<DateTime?> _pickDateTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        return DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
      return pickedDate; // Return only the date if no time is picked
    }
    return null;
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
                child: Text(newDate != null
                    ? "Date & Time: ${_formatDateTime(newDate!)} ${_formatTime(newDate!)}"
                    : "Pick Date & Time"),
                onPressed: () async {
                  DateTime? pickedDateTime = await _pickDateTime(context);
                  setState(() {
                    newDate = pickedDateTime ?? DateTime.now();
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
                child: Text("Date: ${_formatDateTime(updatedDate)} ${_formatTime(updatedDate)}"),
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

  void _deleteEvent(Event event) async {
    await EventDatabaseServices.deleteEvent(event.id!);
    fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.gray,
      appBar: AppBar(
        title: const Text(
          'Event Calendar',
          style: TextStyle(
            color: MyColors.gray,
            fontFamily: "playWrite",
            fontSize: 30,
          ),
        ),
        backgroundColor: MyColors.navy,
      ),
      body: Column(
        children: [
          // Calendar Widget
          TableCalendar(
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            focusedDay: DateTime.now(),
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: MyColors.orange,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: MyColors.blue,
                shape: BoxShape.circle,
              ),
            ),
            eventLoader: (day) {
              return events
                  .where((event) => isSameDay(event.date, day))
                  .toList();
            },
          ),
          // Tab Section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: EventStatus.values.map((status) {
                return ElevatedButton(
                  onPressed: () => filterEvents(status),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedStatus == status
                        ? MyColors.orange
                        : MyColors.blue,
                  ),
                  child: Text(
                    status.name,
                    style: const TextStyle(
                      color: MyColors.gray,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Event List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredEvents.isEmpty
                ? Center(
              child: Image.asset(
                'asset/images/no_events.jpeg',
                fit: BoxFit.contain,
              ),
            )
                : ListView.builder(
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                final event = filteredEvents[index];
                return Card(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                  ),
                  margin: const EdgeInsets.all(8),
                  color: MyColors.orange,
                  elevation: 4,
                  child: ListTile(
                    title: Text(
                      event.name,
                      style: const TextStyle(
                        fontFamily: "playWrite",
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Category: ${event.category}', style: const TextStyle(fontFamily: "playWrite")),
                        Text('Date: ${_formatDateTime(event.date)}', style: const TextStyle(fontFamily: "playWrite")),
                        Text('Time: ${_formatTime(event.date)}', style: const TextStyle(fontFamily: "playWrite")),
                        Text('Location: ${event.location}', style: const TextStyle(fontFamily: "playWrite")),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () => _editEvent(event),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteEvent(event),
                        ),
                      ],
                    ),
                    onTap: () => _editEvent(event),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
        child: const Icon(Icons.add),
      ),
    );
  }
}


