import 'package:flutter/material.dart';
import 'colors.dart';

class Friend extends StatefulWidget{
  final String image, name, eventStatus;
  const Friend({super.key, required this.image, required this.name, required this.eventStatus});

  @override
  State<Friend> createState() => _Friend();

}

class _Friend extends State<Friend>{
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
          backgroundImage: AssetImage(widget.image),
        ),
        title: Text(
          widget.name,
          style: const TextStyle(
              color: MyColors.orange,
              fontFamily: "playWrite",
              fontSize: 30,
              fontWeight: FontWeight.bold
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
                'Upcoming Event: ${widget.eventStatus}',
                style: const TextStyle(
                    color: MyColors.orange,
                    fontSize: 20
                )
            ),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color:  MyColors.orange,
        ),
        onTap: () {
          print("hello");
        },
      ),
    );
  }

}
