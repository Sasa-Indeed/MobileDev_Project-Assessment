import 'package:flutter/material.dart';
import 'colors.dart';

// FriendCard widget
class FriendCard extends StatelessWidget {
  final String name;
  final String image;
  final String eventStatus;
  final VoidCallback onTap;

  const FriendCard({
    required this.name,
    required this.image,
    required this.eventStatus,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: MyColors.blue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage(image),
        ),
        title: Text(
          name,
          style: const TextStyle(
            color: MyColors.orange,
            fontFamily: "playWrite",
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: MyColors.navy,
            ),
            child: Text(
              'Upcoming Event: $eventStatus',
              style: const TextStyle(
                color: MyColors.orange,
                fontSize: 20,
              ),
            ),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: MyColors.orange,
        ),
        onTap: onTap,
      ),
    );
  }
}