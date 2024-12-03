import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code/Screens/studyPlanCreation_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Screens/loginSignUp_page.dart';
import 'Screens/studyHistory_page.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print('Firebase Initialized Successfully');
  } catch (e) {
    print('Firebase Initialization Failed: $e');
  }
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => LoginSignUpScreen(),
      '/studyPlan': (context) => StudyPlanScreen(),
      '/studyHistory': (context) => StudyHistoryScreen(),
    },
  ));
}


