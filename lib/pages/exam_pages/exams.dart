import 'package:app1/data/exam.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'create_exam2.dart';

class Exam extends StatefulWidget {
  const Exam({super.key});

  @override
  State<Exam> createState() => _ExamState();
}

class _ExamState extends State<Exam> {
  int? value = 0;

  String formatDateFromTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('yyyy/MM/dd')
          .format(dateTime); // Using intl's DateFormat
    }
    return timestamp.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Exams"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search button tap
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // Sliding Segmented Control
          Center(
            child: CupertinoSlidingSegmentedControl<int>(
              children: {
                0: buildSegment("All"),
                1: buildSegment("Active"),
                2: buildSegment("Deleted")
              },
              thumbColor: Colors.white,
              groupValue: value,
              onValueChanged: (newValue) {
                setState(() {
                  value = newValue;
                });
              },
            ),
          ),
          const SizedBox(height: 20),

          // Examiner List
          Expanded(child: getSelectedContent()),
        ],
      ),

      // Floating Action Button for Creating a New Examiner
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExamFormScreen()),
            //MaterialPageRoute(builder: (context) => QuestionFormScreen()),
            //MaterialPageRoute(builder: (context) => QuestionsBulkUpload()),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Create Exam", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // UI for Sliding Segmented Tabs
  Widget buildSegment(String text) => Container(
        padding: const EdgeInsets.all(12),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      );

  // Function to Filter Content Based on Selection
  Widget getSelectedContent() {
    /*List<Map<String, dynamic>> allExam = [
      {
        "exam": "Sinhala Part II",
        "date": "01/04/2025",
        "time": "10.00AM - 12.00PM",
        "division": "FOA",
        "status": "Active",
        "subject": "Sinhala",
        "createdBy": "Mr. John Doe",
        "createdDate": "01/04/2025",
        "students": [
          "HS/2021/002",
          "HS/2021/003",
          "HS/2022/005",
          "HS/2023/005"
        ],
        // Placeholder image
      },
      {
        "exam": "Sinhala Part II",
        "date": "01/04/2025",
        "time": "10.00AM - 12.00PM",
        "division": "FOA",
        "status": "Active",
        "subject": "Sinhala",
        "createdBy": "Mr. John Doe",
        "createdDate": "01/04/2025",
        "students": [
          "HS/2021/002",
          "HS/2021/003",
          "HS/2022/005",
          "HS/2023/005"
        ],
      },
    ];*/
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ExamFirebaseService().getUpcomingExams(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No exams found'));
        }

        // Now we have the data and can work with it
        List<Map<String, dynamic>> allExams = snapshot.data!;
        List<Map<String, dynamic>> activeExams =
            allExams.where((div) => div["status"] == "Active").toList();
        List<Map<String, dynamic>> deletedExams =
            allExams.where((div) => div["status"] != "Active").toList();

        List<Map<String, dynamic>> displayList;
        switch (value) {
          case 1:
            displayList = activeExams;
            break;
          case 2:
            displayList = deletedExams;
            break;
          default:
            displayList = allExams;
        }

        return ListView.builder(
          itemCount: displayList.length,
          itemBuilder: (context, index) {
            var examiner = displayList[index];
            return buildExaminerCard(examiner);
          },
        );
      },
    );
  }

  // Examiner Card Widget
  Widget buildExaminerCard(Map<String, dynamic> exam) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Exam", style: const TextStyle(color: Colors.black54)),
                Text(exam["name"])
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Date", style: const TextStyle(color: Colors.black54)),
                Text(formatDateFromTimestamp(exam["examDate"]))
              ],
            )
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Time",
                            style: const TextStyle(color: Colors.black54)),
                        Text('${exam['startTime']} - ${exam['endTime']}')
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Subject",
                            style: const TextStyle(color: Colors.black54)),
                        Text(exam["subject"])
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Division",
                            style: const TextStyle(color: Colors.black54)),
                        Text(exam["division"])
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Status",
                            style: const TextStyle(color: Colors.black54)),
                        Text(
                          exam["status"],
                          style: TextStyle(
                            color: exam["status"] == "Active"
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                const Text("Enrolled Students",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8,
                  children: exam["studentIds"]
                      .map<Widget>((student) => Chip(
                            label: Text(student),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Created By",
                            style: const TextStyle(color: Colors.black54)),
                        Text(exam["createdBy"])
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Created Date",
                            style: const TextStyle(color: Colors.black54)),
                        Text(formatDateFromTimestamp(exam["createdAt"]))
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          showCupertinoModalPopup(
                            context: context,
                            builder: (BuildContext context) {
                              return CupertinoActionSheet(
                                //title: const Text("More Options"),
                                //message: const Text("Select an action"),
                                actions: [
                                  CupertinoActionSheetAction(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      // Perform some action
                                    },
                                    child: const Text("View Submissions"),
                                  ),
                                  CupertinoActionSheetAction(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      // Perform some action
                                    },
                                    child: const Text("Edit"),
                                  ),
                                  CupertinoActionSheetAction(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      // Perform some action
                                    },
                                    child: const Text("View Password"),
                                  ),
                                  CupertinoActionSheetAction(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      // Perform some action
                                    },
                                    isDestructiveAction: true,
                                    child: const Text("Delete"),
                                  ),
                                ],
                                /*cancelButton: CupertinoActionSheetAction(
                                  isDefaultAction: true,
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Cancel"),
                                ),*/
                              );
                            },
                          );
                        },
                        child: const Text("More"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {},
                        child: const Text(
                          "View Submissions",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
