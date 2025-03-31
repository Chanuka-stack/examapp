import 'package:flutter/material.dart';

class NotyPage extends StatefulWidget {
  const NotyPage({super.key});

  @override
  State<NotyPage> createState() => _NotyPageState();
}

class _NotyPageState extends State<NotyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('Noty'),
    );
  }
}
