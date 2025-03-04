import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'create_Examiner.dart';

class Examiners extends StatefulWidget {
  const Examiners({super.key});

  @override
  State<Examiners> createState() => _ExaminersState();
}

class _ExaminersState extends State<Examiners> {
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
        title: const Text("Examiners"),
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
            MaterialPageRoute(builder: (context) => ExaminerFormScreen()),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Create Examiner",
            style: TextStyle(color: Colors.white)),
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
    List<Map<String, dynamic>> allExaminers = [
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

    List<Map<String, dynamic>> activeExaminers =
        allExaminers.where((div) => div["status"] == "Active").toList();
    List<Map<String, dynamic>> deletedExaminers = [];

    List<Map<String, dynamic>> displayList;
    switch (value) {
      case 1:
        displayList = activeExaminers;
        break;
      case 2:
        displayList = deletedExaminers;
        break;
      default:
        displayList = allExaminers;
    }

    return ListView.builder(
      itemCount: displayList.length,
      itemBuilder: (context, index) {
        var examiner = displayList[index];
        return buildExaminerCard(examiner);
      },
    );
  }

  // Examiner Card Widget
  Widget buildExaminerCard(Map<String, dynamic> examiner) {
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
                Text("Examiner (ID))",
                    style: const TextStyle(color: Colors.black54)),
                Text("\n${examiner["name"]}\n(${examiner["id"]})")
              ],
            ),
            Column(
              children: [
                Text("Division", style: const TextStyle(color: Colors.black54)),
                Text(examiner["division"])
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
                        Text(examiner["email"])
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
                        Text(examiner["mobile"])
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
                        Text(examiner["createdBy"])
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Created Date",
                            style: const TextStyle(color: Colors.black54)),
                        Text(examiner["createdDate"])
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
                            examiner["status"],
                            style: TextStyle(
                              color: examiner["status"] == "Active"
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ])
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
