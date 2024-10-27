import 'package:flutter/material.dart';
import 'package:hedieaty_app/custom_widgets/colors.dart';
import '../custom_widgets/circularMenuButton.dart';
import '../custom_widgets/friend.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreen();

}

class _HomeScreen extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
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
        body: const Friend(image: "asset/man.jpg", name: "Sasa", eventStatus: "Birthday"),
        floatingActionButton:circularMenuButton(),
      ),
    );
  }
}

