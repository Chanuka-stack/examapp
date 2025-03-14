import 'package:flutter/material.dart';
import 'calander.dart';
import 'notifications.dart';
import 'settings.dart';
import 'home2.dart';
import '../services/auth_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPageIndex = 0;
  NavigationDestinationLabelBehavior labelBehavior =
      NavigationDestinationLabelBehavior.alwaysShow;
  List<Widget> pageList = const [
    Home(),
    CalanderPage(),
    NotyPage(),
    SettingsPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Padding(
          padding: EdgeInsets.only(left: 10),
          child: Image.network(
            "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/30e6638c-66dc-4f26-9c63-a18063356e7e",
            fit: BoxFit.fitWidth,
          ),
        ),
        actions: [
          /*IconButton(
            icon: Icon(Icons.account_circle, size: 30),
            onPressed: () {
              // Handle profile button tap
            },
            
          ),*/
          IconButton(
            icon: Icon(Icons.logout, size: 30),
            onPressed: () async {
              // Handle profile button tap
              await AuthService().signout(context: context);
            },
            color: Colors.blueAccent,
          )
        ],
      ),
      body: Center(
        child: IndexedStack(
          index: currentPageIndex,
          children: pageList,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        destinations: const <Widget>[
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.calendar_today), label: 'Calander'),
          NavigationDestination(
              icon: Icon(Icons.notifications), label: 'Notifications'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
