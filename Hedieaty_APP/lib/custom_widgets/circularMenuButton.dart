import 'package:flutter/material.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:flutter/cupertino.dart';
import 'colors.dart';


class circularMenuButton extends StatefulWidget{
  const circularMenuButton({super.key});

  @override
  State<circularMenuButton> createState() => _circularMenuButton();

}

class _circularMenuButton extends State<circularMenuButton>{
  final circularMenu = CircularMenu(
      alignment: Alignment.bottomCenter,
      toggleButtonColor: MyColors.orange,
      items: [
        CircularMenuItem(
            color: MyColors.navy,
            icon: Icons.add,
            onTap: () {
                // callback
              print("Add Friends");
            }),
        CircularMenuItem(
            color: MyColors.navy,
            icon: Icons.search,
            onTap: () {
              //callback
              print("Search Friends");
        }),
        CircularMenuItem(
            color: MyColors.navy,
            icon: CupertinoIcons.gift,
            onTap: () {
             //callback
              print("Add Gift List");
        }),
        CircularMenuItem(
            color: MyColors.navy,
            icon: CupertinoIcons.calendar_badge_plus,
            onTap: () {
              //callback
              print("Add Event");
            }),
      ]
  );


  @override
  Widget build(BuildContext context) {
    return circularMenu;
  }

}
