import 'package:flutter/material.dart';
import 'pages/home_screen.dart';
import 'pages/od pages/divisions.dart';
import 'pages/homeTest.dart';
import 'pages/create_student.dart';
import 'pages/create_division.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Colors.blue), // Change theme color
        useMaterial3: true, // Enables Material 3 styling
      ),
      home: HomeScreen(),
      //home: Divisions(),
    );
  }
}
