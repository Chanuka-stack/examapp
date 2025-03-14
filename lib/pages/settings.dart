import 'package:app1/pages/create_new_password.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
      children: [
        ListTile(
          title: Text('Create New Password'),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => CreatePassword()));
          },
        )
      ],
    ));
  }
}
