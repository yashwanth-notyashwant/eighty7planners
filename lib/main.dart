import 'package:flutter/material.dart';
import 'dart:async';

import 'screens/HomeScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(), // Display the splash screen initially.
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String displayedText = ''; // Initially, the displayed text is empty.
  int currentIndex = 0; // Keeps track of the current letter being added.
  List<String> fullText = [
    'H',
    'e',
    'l',
    'l',
    'o',
    ' ',
    '!'
  ]; // The full text to display.

  @override
  void initState() {
    super.initState();

    // Use a Timer to add one letter at a time with a delay.
    Timer.periodic(Duration(milliseconds: 150), (timer) {
      if (currentIndex < fullText.length) {
        setState(() {
          displayedText += fullText[currentIndex];
          currentIndex++;
        });
      } else {
        // After all letters are displayed, navigate to the main screen.
        timer.cancel();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                HomeScreen(), // Replace with your main screen widget.
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          displayedText,
          style: TextStyle(
            fontSize: 40.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
