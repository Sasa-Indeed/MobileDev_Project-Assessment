import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyApp();

}

class _MyApp extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: "Home",
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Testing Area"),
          centerTitle: true,
          backgroundColor: Colors.purple,
        ),
        body: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 4,
          child: ListTile(
            leading:  const CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage('asset/man.jpg'),
            ),
            title: const Text('Randy Rudolph'),
            subtitle: const Text('name@domain.com'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              print("hello");
            },
          ),
        ),
      ),
    );
  }

}