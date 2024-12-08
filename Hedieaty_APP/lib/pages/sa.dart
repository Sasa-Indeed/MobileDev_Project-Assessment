/*
void showEditGiftDialog(Gift gift) {
  String newName = gift.name;
  String newDescription = gift.description;
  String newCategory = gift.category;
  double newPrice = gift.price;
  String newStatus = gift.status;
  String? newImagePath = gift.imagePath;

  Event? selectedEvent = upcomingEvents.isNotEmpty
      ? upcomingEvents.firstWhere(
        (event) => event.id == gift.eventID,
    orElse: () => upcomingEvents.first,
  )
      : null;

  if (upcomingEvents.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("No events available to assign to the gift."),
    ));
    return;
  }

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Edit Gift"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(hintText: "Gift Name"),
                    controller: TextEditingController(text: newName),
                    onChanged: (value) => newName = value,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: const InputDecoration(hintText: "Description"),
                    controller: TextEditingController(text: newDescription),
                    onChanged: (value) => newDescription = value,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: const InputDecoration(hintText: "Category"),
                    controller: TextEditingController(text: newCategory),
                    onChanged: (value) => newCategory = value,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: const InputDecoration(hintText: "Price"),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: newPrice.toString()),
                    onChanged: (value) => newPrice = double.tryParse(value) ?? 0.0,
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: newStatus,
                    isExpanded: true,
                    onChanged: (value) {
                      setState(() {
                        newStatus = value!;
                      });
                    },
                    items: ['Pending', 'Pledged'].map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: const InputDecoration(hintText: "Image Path (optional)"),
                    controller: TextEditingController(text: newImagePath),
                    onChanged: (value) => newImagePath = value,
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<Event>(
                    value: selectedEvent,
                    isExpanded: true,
                    onChanged: (value) {
                      setState(() {
                        selectedEvent = value!;
                      });
                    },
                    items: upcomingEvents.map((event) {
                      return DropdownMenuItem<Event>(
                        value: event,
                        child: Text("${event.name} (${event.date})"),
                      );
                    }).toList(),
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
                  if (newName.isNotEmpty &&
                      newDescription.isNotEmpty &&
                      newCategory.isNotEmpty &&
                      newPrice > 0 &&
                      newStatus.isNotEmpty &&
                      selectedEvent != null) {
                    Gift updatedGift = Gift(
                      id: gift.id,
                      name: newName,
                      description: newDescription,
                      category: newCategory,
                      price: newPrice,
                      status: newStatus,
                      eventID: selectedEvent?.id ?? 0,
                      imagePath: newImagePath,
                    );
                    await editGift(updatedGift);
                    Navigator.of(context).pop();
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
@TODo
  -Restore the original style of the page
  -Make the edit gift change the price in the database
  -Make the changes appear in both edit gift and gift list page

*/
