import 'package:flutter/material.dart';
import 'package:hedieaty_app/firebase_services/firebase_event_service.dart';
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
    final List<String> categories = [
      "Birthday",
      "Baby Shower",
      "Wedding",
      "Engagement Ceremony",
      "House Party",
      "Holiday Gathering",
      "Family Gathering",
      "Graduation"
    ];

    showDialog(
      context: context,
      builder: (context) {
        String newName = '';
        String newLocation = '';
        String newCategory = categories.first; // Default to first category
        String newDescription = '';
        DateTime? newDate;

        return StatefulBuilder(  // Added StatefulBuilder to handle dropdown state
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add New Event"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(hintText: "Event Name"),
                      onChanged: (value) => newName = value,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(hintText: "Location"),
                      onChanged: (value) => newLocation = value,
                    ),
                    const SizedBox(height: 10),

                    // Category Dropdown
                    DropdownButton<String>(
                      value: newCategory,
                      isExpanded: true,
                      onChanged: (String? value) {
                        setState(() {
                          newCategory = value!;
                        });
                      },
                      items: categories.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      decoration: const InputDecoration(hintText: "Description"),
                      onChanged: (value) => newDescription = value,
                    ),
                    const SizedBox(height: 10),
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
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text("Add"),
                  onPressed: () async {
                    if (newName.isNotEmpty &&
                        newLocation.isNotEmpty &&
                        newDescription.isNotEmpty &&
                        newDate != null) {  // Removed newCategory check since it always has a value
                      final newEvent = Event(
                        name: newName,
                        date: newDate!,
                        location: newLocation,
                        category: newCategory,
                        description: newDescription,
                        userID: userID,
                      );

                      // Save to local database
                      int eventID = await EventDatabaseServices.insertEvent(newEvent);
                      newEvent.id = eventID;

                      // Save to Firebase
                      try {
                        await FirebaseEventService.addEventToFirebase(newEvent);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to add event: $e')),
                        );
                      }

                      fetchEvents(); // Refresh the event list
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please fill out all fields and pick a date."),
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }


  void _editEvent(Event event) {
    final List<String> categories = [
      "Birthday",
      "Baby Shower",
      "Wedding",
      "Engagement Ceremony",
      "House Party",
      "Holiday Gathering",
      "Family Gathering",
      "Graduation"
    ];

    showDialog(
      context: context,
      builder: (context) {
        String updatedName = event.name;
        String updatedLocation = event.location;
        String updatedCategory = event.category;
        String updatedDescription = event.description;
        DateTime updatedDate = event.date;

        // Validate that the existing category is in the list, otherwise use the first category
        if (!categories.contains(updatedCategory)) {
          updatedCategory = categories.first;
        }

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Edit Event"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(hintText: "Event Name"),
                      controller: TextEditingController(text: event.name),
                      onChanged: (value) => updatedName = value,
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      decoration: const InputDecoration(hintText: "Location"),
                      controller: TextEditingController(text: event.location),
                      onChanged: (value) => updatedLocation = value,
                    ),
                    const SizedBox(height: 10),

                    // Category Dropdown
                    DropdownButton<String>(
                      value: updatedCategory,
                      isExpanded: true,
                      onChanged: (String? value) {
                        setState(() {
                          updatedCategory = value!;
                        });
                      },
                      items: categories.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      decoration: const InputDecoration(hintText: "Description"),
                      controller: TextEditingController(text: event.description),
                      onChanged: (value) => updatedDescription = value,
                    ),
                    const SizedBox(height: 10),

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
                        updatedDescription.isNotEmpty) {
                      try {
                        // Update in local database
                        await EventDatabaseServices.updateEvent(Event(
                          id: event.id,
                          name: updatedName,
                          location: updatedLocation,
                          category: updatedCategory,
                          description: updatedDescription,
                          date: updatedDate,
                          userID: userID,
                        ));

                        // Update in Firebase
                        try {
                          await FirebaseEventService.updateEventInFirestore(Event(
                            id: event.id,
                            name: updatedName,
                            location: updatedLocation,
                            category: updatedCategory,
                            description: updatedDescription,
                            date: updatedDate,
                            userID: userID,
                          )
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to update event in Firebase: $e')),
                          );
                        }

                        fetchEvents();
                        Navigator.of(context).pop();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Failed to update event. Please try again."),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please fill out all fields."),
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteEvent(Event event) async {
    try{
      await EventDatabaseServices.deleteEvent(event.id!);
      await FirebaseEventService.deleteEventByID(event.id!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete event: $e')),
      );
    }
    fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.gray,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: MyColors.orange, // Set the back arrow color
        ),
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
        backgroundColor: MyColors.navy,
        child: const Icon(
          Icons.add,
          color: MyColors.orange,
        ),
      ),
    );
  }
}


