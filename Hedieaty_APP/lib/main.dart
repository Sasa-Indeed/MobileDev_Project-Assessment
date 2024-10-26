import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/gift_page.dart';
import 'pages/event_list_page.dart';
import 'pages/gift_details_page.dart';
import 'elements/gift.dart';


void main() {
  runApp(
      MaterialApp(
        title: "Hedieaty",
        home:  GiftDetailsPage(),
        routes: {
          "/Home" : (context) => HomeScreen(),
          "/ProfilePage": (context) => ProfileScreen(),
          "/GiftPage": (context) => GiftListPage(),
          "/EventListPage" : (context) => EventListPage(),
          "/GiftDetailsPage" : (context) => GiftDetailsPage(),
        },
      )
  );
}
