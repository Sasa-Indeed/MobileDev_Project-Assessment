import 'package:flutter/material.dart';
import 'home.dart';
import 'products.dart';
import 'cart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Set the initial route to HomeScreen
      routes: {
        '/': (context) => HomeScreen(),
        '/Product': (context) => ProductListScreen(),
        '/Cart': (context) => ShoppingCartScreen(),
      },
    );
  }
}



