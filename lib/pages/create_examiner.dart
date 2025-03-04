import 'package:flutter/material.dart';

class ExaminerFormScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Exam Schedule"),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Tabs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFilterTab("All", true),
                _buildFilterTab("Upcoming", false),
                _buildFilterTab("Completed", false),
              ],
            ),
            const SizedBox(height: 10),

            // Exam Schedule List
            Expanded(
              child: ListView(
                children: [
                  _buildExamTile("Sinhala Part II", "01/04/2025"),
                  _buildExamTile("2nd Year 2nd Sem Economics", "05/04/2025"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String text, bool isSelected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExamTile(String title, String date) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(date, style: const TextStyle(color: Colors.grey)),
          ],
        ),
        children: [_buildExamDetails()],
      ),
    );
  }

  Widget _buildExamDetails() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow("Time", "10:00AM - 12:00PM"),
          _buildDetailRow("Subject", "Economics"),
          _buildDetailRow("Division", "Faculty of Management"),
          _buildDetailRow("Status", "Upcoming", textColor: Colors.orange),
          const SizedBox(height: 10),
          const Text("Enrolled Students",
              style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: [
              "AR/21/4483",
              "AR/21/4484",
              "AR/21/4485",
              "AR/21/4486",
              "AR/21/4487"
            ]
                .map((id) =>
                    Chip(label: Text(id, style: TextStyle(color: Colors.blue))))
                .toList(),
          ),
          const SizedBox(height: 10),
          _buildDetailRow("Created by", "Mr. John Doe"),
          _buildDetailRow("Created Date", "01/04/2025"),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: Text("More"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text("View Submissions",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {Color textColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: textColor)),
        ],
      ),
    );
  }
}
