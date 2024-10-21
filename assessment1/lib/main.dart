import 'package:flutter/material.dart';
import 'dart:math';


void main() {
  runApp( MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyApp();

}


class _MyApp extends State<MyApp> {

  double temperature = 0.0;
  double convtemp = 0.0;
  late String fromTemp;
  late String toTemp;
  bool showImage = false;
  String imagePath = "asset/C.png";

  void resetValues() {
    setState(() {
      temperature = 0.0;
      convtemp = 0.0;
      fromTemp = "";
      toTemp = "";
      showImage = false;
      imagePath = "asset/C.png";

    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Temperature Converter",
      home: Scaffold(
        backgroundColor:  const Color(0xffd9d9d9),
        appBar: AppBar(
          title: const Text(
            "Temperature Converter",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xff8da7dd),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row( //From Temperature
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
                    child: DropdownMenu(
                      width: 150,
                      hintText: "From",
                      dropdownMenuEntries: const [
                        DropdownMenuEntry(value: "Celsius", label: 'Celsius'),
                        DropdownMenuEntry(value: "Fahrenheit", label: 'Fahrenheit'),
                        DropdownMenuEntry(value: "Kelvin", label: 'Kelvin'),
                      ],
                      onSelected: (num){
                        if(num != null){
                          fromTemp = num;
                        }
                      },
                    ),
                  ),
                  InputTextField(
                    label: 'From',
                    onSubmitted: (text){
                      temperature = double.parse(text);
                      print(temperature);
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Row( // To Temperature
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
                    child: DropdownMenu(
                      width: 150,
                      hintText: "To",
                      dropdownMenuEntries: const [
                        DropdownMenuEntry(value: "Celsius", label: 'Celsius'),
                        DropdownMenuEntry(value: "Fahrenheit", label: 'Fahrenheit'),
                        DropdownMenuEntry(value: "Kelvin", label: 'Kelvin'),
                      ],
                      onSelected: (num){
                        if(num != null){
                          toTemp = num;
                        }
                      },
                    ),
                  ),
                  Container(
                    width: 250,
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    child: Text("$convtemp"),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(// Convert Button
                    width: 150,
                    height: 50,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff65558f),
                        ),
                        onPressed: () {
                          setState(() {
                            convtemp = convertTemperature(fromTemp, toTemp, temperature);
                            showImage = true;
                            if(toTemp == "Celsius"){
                              imagePath = "asset/C.png";
                            }else if(toTemp == "Fahrenheit"){
                              imagePath = "asset/F.png";
                            }else{
                              imagePath = "asset/K.png";
                            }
                          });
                        },
                        child: const Text(
                          "Convert",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        )
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  SizedBox( // Reset Button
                    width: 150,
                    height: 50,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () {
                          resetValues();
                        },
                        child: const Text(
                          "Reset",
                          style: TextStyle(
                            fontSize: 20,
                            color: const Color(0xff65558f),
                          ),
                        )
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Visibility(
                visible: showImage,
                child:  CircleAvatar(
                  radius: 100,
                  backgroundImage: AssetImage(imagePath),

                ) ,
              )
            ],

          ),
        ),
      ),
    );
  }

}

class InputTextField extends StatefulWidget {
  final String label;
  final Function(String) onSubmitted; // Callback to return the input

  const InputTextField({super.key, required this.label, required this.onSubmitted});

  @override
  State<InputTextField> createState() => _InputTextFieldState();
}

class _InputTextFieldState extends State<InputTextField> {
  // Create a controller to track the input text
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose(); // Clean up the controller when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: TextField(
        controller: _controller, // Use the controller to handle input
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: widget.label,
        ),
        onSubmitted: (value) {
          // Return the input using the callback
          widget.onSubmitted(value);
        },
      ),
    );
  }
}


double convertTemperature(String from, String to, double value) {
  double result = 0.0;

  if (from == "Celsius") {
    if (to == "Fahrenheit") {
      result = (value * 9 / 5) + 32;
    } else if (to == "Kelvin") {
      result = value + 273.15;
    } else {
      result = value; // No conversion needed
    }
  } else if (from == "Fahrenheit") {
    if (to == "Celsius") {
      result = (value - 32) * 5 / 9;
    } else if (to == "Kelvin") {
      result = ((value - 32) * 5 / 9) + 273.15;
    } else {
      result = value; // No conversion needed
    }
  } else if (from == "Kelvin") {
    if (to == "Celsius") {
      result = value - 273.15;
    } else if (to == "Fahrenheit") {
      result = (value - 273.15) * 9 / 5 + 32;
    } else {
      result = value; // No conversion needed
    }
  } else {
    // Handle invalid input
    throw Exception("Invalid temperature unit: $from");
  }


  return result;
}

