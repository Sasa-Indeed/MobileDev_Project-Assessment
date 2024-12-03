import 'package:flutter/material.dart';
import 'package:hedieaty_app/custom_widgets/colors.dart';
import 'package:hedieaty_app/models/user.dart';
import '../custom_widgets/circularMenuButton.dart';
import '../custom_widgets/friend.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:flutter/cupertino.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreen();

}

class _HomeScreen extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final User user = ModalRoute.of(context)!.settings.arguments as User;
    return  MaterialApp(
      title: "Home",
      home: Scaffold(
        backgroundColor: MyColors.gray,
        appBar: AppBar(
          title: const Text(
              "Hedieaty",
              style: TextStyle(
                  color: MyColors.gray,
                  fontFamily: "playWrite",
                  fontSize: 30
              ),
          ),
          centerTitle: true,
          backgroundColor: MyColors.navy,
        ),
        body: const Column(
          children: [
             Friends(image: "asset/man.jpg", name: "Sasa", eventStatus: "Birthday"),
          ],
        ),
        floatingActionButton: CircularMenu(
          alignment: Alignment.bottomCenter,
          toggleButtonColor: MyColors.orange,
          items: [
            CircularMenuItem(
              color: MyColors.navy,
              icon: Icons.person_2_outlined,
              onTap: (){
                Navigator.pushNamed(context, '/ProfilePage');
                }, // Uses the correct context
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
                Navigator.pushNamed(context, '/EventListPage', arguments: user.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

