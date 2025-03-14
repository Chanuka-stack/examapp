import 'package:app1/data/user.dart';
import 'package:app1/pages/examiners.dart';
import 'package:app1/pages/students.dart';
import 'package:flutter/material.dart';
import 'divisions2.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // A list of items with image URLs and descriptions
  //String userRole = 'superadmin';
  UserL user = UserL();
  String userRole = '';

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    String role = await user.getUserRole();
    setState(() {
      userRole = role;
    });
  }

  final List<Map<String, String>> items = [
    {
      'image':
          "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/97bdb826-4859-4cbb-b086-47b8e9fae57a",
      'title': 'Second Year Second Semester Economics',
      'subtitle': '10/02/2025 10AM - 12PM',
    },
    {
      'image':
          "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/97bdb826-4859-4cbb-b086-47b8e9fae57a",
      'title': 'Examiners',
      'subtitle': '10/02/2025 10AM - 12PM',
    },
    {
      'image':
          "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/97bdb826-4859-4cbb-b086-47b8e9fae57a",
      'title': 'Students',
      'subtitle': 'Details about Students',
    },
    {
      'image':
          "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/97bdb826-4859-4cbb-b086-47b8e9fae57a",
      'title': 'Exams',
      'subtitle': 'Details about Exams',
    },
    {
      'image':
          "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/97bdb826-4859-4cbb-b086-47b8e9fae57a",
      'title': 'Exams',
      'subtitle': 'Details about Exams',
    },
    {
      'image':
          "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/97bdb826-4859-4cbb-b086-47b8e9fae57a",
      'title': 'Exams',
      'subtitle': 'Details about Exams',
    },
    {
      'image':
          "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/97bdb826-4859-4cbb-b086-47b8e9fae57a",
      'title': 'Exams',
      'subtitle': 'Details about Exams',
    },
    // Add more items here as necessary
  ];

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    double screenWidth = MediaQuery.of(context).size.width;

    // Calculate the width for each button so they stay within the screen width
    double buttonSize =
        (screenWidth - 40) / 4; // 40 for the padding between buttons

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            // Row of buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Space evenly
              children: [
                if (userRole == 'superadmin')
                  _buildButton(
                    "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/1827f470-13cc-44b5-a6c9-7436d2451cfe",
                    'Divisions',
                    buttonSize,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Divisions()),
                      );
                    },
                  ),
                if (userRole == 'superadmin')
                  _buildButton(
                      "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/021dda6b-8414-4f54-a7bc-6ae357a02aa8",
                      'Examiners',
                      buttonSize, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Examiners()),
                    );
                  }),
                if (userRole == 'superadmin')
                  _buildButton(
                      "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/969a41a3-dd63-428a-bd76-490cb3db34b1",
                      'Students',
                      buttonSize, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Students()),
                    );
                  }),
                if (userRole == 'superadmin')
                  _buildButton(
                      "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/969a41a3-dd63-428a-bd76-490cb3db34b1",
                      'Exams',
                      buttonSize,
                      () {}),
              ],
            ),
            // Add a vertical space between the buttons and the list
            SizedBox(height: 20),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.start, // Align to the start (left)
              children: [
                SizedBox(
                  width: 10,
                ),
                Text('Upcoming Exams'),
              ],
            ),
            // Expanded widget ensures the list below takes the remaining space
            Expanded(
              child: ListView.builder(
                itemCount: items.length, // Use the length of the list
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    elevation: 5, // Elevation for the "card-like" effect
                    margin: EdgeInsets.symmetric(
                        vertical: 8, horizontal: 16), // Margin around the card
                    child: ListTile(
                      leading: Image.network(
                        item['image']!, // Image URL
                        width: 40,
                        height: 40, // Set consistent image size
                      ),
                      title: Text(item['title']!),
                      subtitle: Text(item['subtitle']!),
                      onTap: () {
                        // Handle tap on each list item
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build each button with an image and text
  Widget _buildButton(
      String imageUrl, String text, double buttonSize, VoidCallback onPressed) {
    return SizedBox(
      width: buttonSize, // Use the dynamic size for the button width
      height: buttonSize, // Use the same size for height to keep it square
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              imageUrl,
              width: 40,
              height: 40, // Set consistent image size
            ),
            SizedBox(height: 5),
            FittedBox(
              child: Text(
                text,
                style: TextStyle(fontSize: 12), // Uniform font size
              ),
            ),
          ],
        ),
      ),
    );
  }
}
