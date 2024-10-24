import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/gift_page.dart';
import 'pages/event_list_page.dart';


void main() {
  runApp(
      MaterialApp(
        title: "Hedieaty",
        home:  EventListPage(),
        routes: {
          "/Home" : (context) => HomeScreen(),
          "/ProfilePage": (context) => ProfileScreen(),
          "/GiftPage": (context) => GiftListPage(),
          "/EventListPage" : (context) => EventListPage(),
        },
      )
  );
}
