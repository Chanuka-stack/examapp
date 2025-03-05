import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'create_student.dart';

class Students extends StatefulWidget {
  const Students({super.key});

  @override
  State<Students> createState() => _StudentsState();
}

class _StudentsState extends State<Students> {
  int? value = 0;

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
        title: const Text("Students"),
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

          // Student List
          Expanded(child: getSelectedContent()),
        ],
      ),

      // Floating Action Button for Creating a New Student
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => StudentFormScreen()),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label:
            const Text("Create Student", style: TextStyle(color: Colors.white)),
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
    List<Map<String, dynamic>> allStudents = [
      {
        "name": "Adam Gilichrist",
        "id": "EX000123",
        "division": "FOA",
        "status": "Active",
        "email": "adam123@gmail.com",
        "mobile": "07512345678",
        "createdBy": "Mr. John Doe",
        "createdDate": "01/04/2025",
        // Placeholder image
      },
      {
        "name": "Thilan Samaraweera",
        "division": "FOM",
        "id": "EX000173",
        "status": "Active",
        "email": "samaraw@gmail.com",
        "mobile": "07512345678",
        "createdBy": "Ms. Jane Smith",
        "createdDate": "05/04/2025",
      },
    ];

    List<Map<String, dynamic>> activeStudents =
        allStudents.where((div) => div["status"] == "Active").toList();
    List<Map<String, dynamic>> deletedStudents = [];

    List<Map<String, dynamic>> displayList;
    switch (value) {
      case 1:
        displayList = activeStudents;
        break;
      case 2:
        displayList = deletedStudents;
        break;
      default:
        displayList = allStudents;
    }

    return ListView.builder(
      itemCount: displayList.length,
      itemBuilder: (context, index) {
        var Student = displayList[index];
        return buildStudentCard(Student);
      },
    );
  }

  // Student Card Widget
  Widget buildStudentCard(Map<String, dynamic> Student) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text("Student (ID))",
                    style: const TextStyle(color: Colors.black54)),
                Text("\n${Student["name"]}\n(${Student["id"]})")
              ],
            ),
            Column(
              children: [
                Text("Division", style: const TextStyle(color: Colors.black54)),
                Text(Student["division"])
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
                        Text("Email Address",
                            style: const TextStyle(color: Colors.black54)),
                        Text(Student["email"])
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Contact Number",
                            style: const TextStyle(color: Colors.black54)),
                        Text(Student["mobile"])
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
                        Text("Created By",
                            style: const TextStyle(color: Colors.black54)),
                        Text(Student["createdBy"])
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Created Date",
                            style: const TextStyle(color: Colors.black54)),
                        Text(Student["createdDate"])
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Status",
                              style: const TextStyle(color: Colors.black54)),
                          Text(
                            Student["status"],
                            style: TextStyle(
                              color: Student["status"] == "Active"
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ])
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text("More"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {},
                        child: const Text(
                          "Reset Password",
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
