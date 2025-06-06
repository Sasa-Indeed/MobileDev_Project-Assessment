import 'package:flutter/material.dart';
import 'package:hedieaty_app/Controller/n_service.dart';
import 'pages/friend_gift_list_page.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/gift_list_page.dart';
import 'pages/event_list_page.dart';
import 'pages/gift_details_page.dart';
import 'pages/pledged_gifts.dart';
import 'pages/login_page.dart';
import 'pages/signUp_page.dart';

void main() {
  runApp(
      MaterialApp(
        title: "Hedieaty",
        initialRoute: '/login',
        navigatorKey: NavigationService().navigatorKey,
        routes: {
          "/Home"             : (context) => HomeScreen(),
          "/ProfilePage"      : (context) => ProfileScreen(),
          "/GiftListPage"         : (context) => GiftListPage(),
          "/EventListPage"    : (context) => EventListPage(),
          "/GiftDetailsPage"  : (context) => GiftDetailsPage(),
          "/PledgedGiftsPage" : (context) => PledgedGiftsPage(),
          "/FriendGiftListPage": (context) => FriendGiftListPage(),
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
        },
      )
  );
}

