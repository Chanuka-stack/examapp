import 'package:flutter/material.dart';

class ExaminerFormScreen extends StatefulWidget {
  @override
  _ExaminerFormScreenState createState() => _ExaminerFormScreenState();
}

class _ExaminerFormScreenState extends State<ExaminerFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Create New Examiner"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Handle search button tap
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Name *", style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            const Text("ID ", style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(
              controller: _codeController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            const Text("Division *",
                style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              hint: const Text("Select a Division"),
              onChanged: (value) {
                if (value != null) {
                  setState(() {});
                }
              },
              items: ["Arts", "Science", "Medicine", "Management"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
            ),
            const SizedBox(height: 10),
            const Text("Email Address *",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(
              controller: _codeController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            const Text("Contact Number *",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(
              controller: _codeController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Upon clicking submit button, login credentials will be sent to your registered email address. System requires password change at first login.",
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: double.infinity, // Make the button take full width
                child: FilledButton(
                  onPressed: () {
                    // Handle form submission
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(4), // Small border radius
                    ),
                  ),
                  child: const Text("Create"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
