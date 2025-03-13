import 'package:app1/pages/login.dart';
import 'package:flutter/material.dart';
import 'pages/home_screen.dart';
import 'pages/od pages/divisions.dart';
import 'pages/homeTest.dart';
import 'pages/create_student.dart';
import 'pages/create_division.dart';
import 'pages/components/audio_button.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: LoginPage(),
      //home: Center(child: AudioRecordButton()),
    );
  }
}
