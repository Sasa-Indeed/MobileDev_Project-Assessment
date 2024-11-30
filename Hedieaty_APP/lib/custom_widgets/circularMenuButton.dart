import 'package:flutter/material.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:flutter/cupertino.dart';
import 'colors.dart';

class CircularMenuButton extends StatefulWidget {
  const CircularMenuButton({super.key});

  @override
  State<CircularMenuButton> createState() => _CircularMenuButtonState();
}

class _CircularMenuButtonState extends State<CircularMenuButton> {
  void _goToProfilePage() {
    Navigator.pushNamed(context, '/ProfilePage');
  }

  @override
  Widget build(BuildContext context) {
    return CircularMenu(
      alignment: Alignment.bottomCenter,
      toggleButtonColor: MyColors.orange,
      items: [
        CircularMenuItem(
          color: MyColors.navy,
          icon: Icons.person_2_outlined,
          onTap: _goToProfilePage, // Uses the correct context
        ),
        CircularMenuItem(
          color: MyColors.navy,
          icon: Icons.add,
          onTap: () {
            print("Add Friends");
          },
        ),
        CircularMenuItem(
          color: MyColors.navy,
          icon: CupertinoIcons.gift,
          onTap: () {
            print("Add Gift List");
          },
        ),
        CircularMenuItem(
          color: MyColors.navy,
          icon: CupertinoIcons.calendar_badge_plus,
          onTap: () {
            print("Add Event");
          },
        ),
      ],
    );
  }
}
