import 'package:flutter/material.dart';
import 'pages/home_screen.dart';
import 'pages/divisions.dart';
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
      home: HomeScreen(),
      //home: Divisions(),
    );
  }
}
