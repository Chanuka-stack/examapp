import 'package:app1/pages/auth_pages/login.dart';
import 'package:flutter/material.dart';
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
      //home: StudentHome(),
      //home: Center(child: AudioRecordButton()),
    );
  }
}
