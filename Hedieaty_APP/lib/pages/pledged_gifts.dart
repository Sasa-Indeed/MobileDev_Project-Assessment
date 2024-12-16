import 'package:flutter/material.dart';
import 'package:hedieaty_app/database/gift_database_services.dart';
import 'package:hedieaty_app/database/pledges_database_services.dart';
import 'package:hedieaty_app/firebase_services/firebase_pledges_service.dart';
import 'package:intl/intl.dart';
import 'package:hedieaty_app/custom_widgets/colors.dart';
import 'package:hedieaty_app/models/pledges.dart';

class PledgedGiftsPage extends StatefulWidget {
  const PledgedGiftsPage({super.key});

  @override
  _PledgedGiftsPageState createState() => _PledgedGiftsPageState();
}

class _PledgedGiftsPageState extends State<PledgedGiftsPage> {
  List<Pledges> pledgedGifts = [];
  bool isLoading = true;
  late int userID;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        setState(() {
          userID = args;
        });
        fetchPledges(); // Fetch data only after `userID` is set
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID is missing.')),
        );
      }
    });
  }


  /// Fetch pledges from the database
  Future<void> fetchPledges() async {
    setState(() {
      isLoading = true;
    });
    try {
      List<Pledges> pledges = await PledgeDatabaseServices.getPledgesByUserID(userID);
      setState(() {
        pledgedGifts = pledges;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load pledges: $e')),
      );
    }
  }

  /// Remove a pledge from both the Firebase and the local database
  Future<void> _removePledge(int index) async {
    final Pledges pledge = pledgedGifts[index];
    final DateTime fourDaysAfterDue = pledge.dueDate.add(const Duration(days: 4));

    if (DateTime.now().isBefore(fourDaysAfterDue)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only delete a pledge 4 days after its due date.'),
        ),
      );
      return;
    }

    setState(() {
      pledgedGifts.removeAt(index);
    });

    try {
      // Remove from Firebase
      await FirebasePledgesService.deletePledgeByUserID(userID);

      // Remove from local database
      await PledgeDatabaseServices.deletePledge(pledge.id!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pledge for ${pledge.friendName} deleted successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete pledge: $e')),
      );
    }
  }

  /// Format the date for display
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.gray,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: MyColors.orange,
        ),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pledgedGifts.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'asset/empty_gift.png',
              width: 250,
              height: 400,
            ),
            const Text(
              'No Pledges to Display!',
              style: TextStyle(
                fontSize: 25,
                color: MyColors.orange,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: pledgedGifts.length,
        itemBuilder: (context, index) {
          final pledge = pledgedGifts[index];
          final bool isPastDue = pledge.dueDate.isBefore(DateTime.now());
          final bool canDelete =
          DateTime.now().isAfter(pledge.dueDate.add(const Duration(days: 4)));

          return Card(
            color: MyColors.blue,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(
                pledge.giftName,
                style: TextStyle(
                  color: isPastDue
                      ? MyColors.orange.withOpacity(0.5)
                      : MyColors.orange,
                  fontFamily: "playWrite",
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text(
                    "Event: ${pledge.eventName}",
                    style: TextStyle(
                      color: isPastDue
                          ? MyColors.gray.withOpacity(0.5)
                          : MyColors.gray,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Friend: ${pledge.friendName}",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: isPastDue ? Colors.red : Colors.green,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text("Due Date: ${_formatDateTime(pledge.dueDate)}",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                color: MyColors.gray,
                onPressed: canDelete
                    ? () => _removePledge(index)
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
