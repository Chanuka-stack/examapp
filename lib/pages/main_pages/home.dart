import 'package:app1/pages/exam_pages/exams.dart';
import 'package:app1/pages/student_pages/sudent_home.dart';
import 'package:flutter/material.dart';
import '../divisoin_pages/divisions2.dart';
import '../examiner_pages/examiners.dart';
import '../student_pages_admin/students.dart';
import 'package:app1/data/user.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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

    // Navigate to another page if the role is 'student'
  }

  @override
  Widget build(BuildContext context) {
    if (userRole == 'student') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StudentHome()),
        );
      });
    }
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Navigation Buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (userRole == 'superadmin')
                  _buildIconButton(
                      context, Icons.apartment, "Divisions", const Divisions()),
                if (userRole == 'superadmin')
                  _buildIconButton(context, Icons.account_circle, "Examiners",
                      const Examiners()),
                if (userRole == 'superadmin' || userRole == 'admin')
                  _buildIconButton(
                      context, Icons.school, "Students", const Students()),
                if (userRole == 'superadmin' || userRole == 'admin')
                  _buildIconButton(context, Icons.book, "Exams", const Exam()),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Upcoming Exams",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 4,
              itemBuilder: (context, index) {
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.image, color: Colors.blue),
                    title: Text(
                      index % 2 == 0
                          ? "2nd Year 2nd Semester Economics"
                          : "4th Year 1st Semester Social Science",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text("02/10/2025, 10.00AM - 12.00PM"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(
      BuildContext context, IconData icon, String label, Widget screen) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 32, color: Colors.blue),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => screen));
          },
        ),
        Text(label),
      ],
    );
  }
}
