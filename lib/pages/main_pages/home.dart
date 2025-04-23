import 'package:app1/data/exam.dart';
import 'package:app1/pages/exam_pages/exams.dart';
import 'package:app1/pages/student_pages/sudent_home2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  ExamFirebaseService examFirebaseService = ExamFirebaseService();
  List<Map<String, dynamic>> _upcomingExams = [];
  late Future<List<Map<String, dynamic>>> _examsFuture; // Cached Future

  @override
  void initState() {
    super.initState();
    _examsFuture = _fetchUpcomingExams(); // Fetch once on initialization
    _fetchUserRole();
  }

  String formatDateFromTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('yyyy/MM/dd')
          .format(dateTime); // Using intl's DateFormat
    }
    return timestamp.toString();
  }

  Future<List<Map<String, dynamic>>> _fetchUpcomingExams() async {
    try {
      //final exams = await examFirebaseService.getUpcomingExams();
      final exams = await examFirebaseService.getUpcomingExams();
      setState(() {
        _upcomingExams = exams; // Update local list for other uses if needed
      });
      return exams;
    } catch (e) {
      print("Error fetching upcoming exams: $e");
      return []; // Return empty list on error
    }
  }

  void _refreshExams() {
    setState(() {
      _examsFuture = _fetchUpcomingExams(); // Refresh the Future when needed
    });
  }

  Future<void> _fetchUserRole() async {
    String role = await user.getUserRole();
    setState(() {
      userRole = role;
    });
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
          // Upcoming Exams Header with Refresh Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Upcoming Exams",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _refreshExams, // Manual refresh option
                ),
              ],
            ),
          ),
          // Exam List with FutureBuilder
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future:
                  _examsFuture, // Cached Future, refreshed via _refreshExams
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                final exams = snapshot.data ?? [];
                if (exams.isEmpty) {
                  return const Center(child: Text("No upcoming exams"));
                }
                return ListView.builder(
                  itemCount: exams.length,
                  itemBuilder: (context, index) {
                    final exam = exams[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading:
                            const Icon(Icons.assignment, color: Colors.blue),
                        title: Text(
                          "${exam['division']} ${exam['subject']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                            "${formatDateFromTimestamp(exam['examDate'])}, ${exam['startTime']} - ${exam['endTime']}"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    );
                  },
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
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => screen),
            );
            _refreshExams(); // Refresh exams when returning from any screen
          },
        ),
        Text(label),
      ],
    );
  }
}
