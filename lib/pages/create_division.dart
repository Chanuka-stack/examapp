import 'package:flutter/material.dart';

class DivisionFormScreen extends StatefulWidget {
  @override
  _DivisionFormScreenState createState() => _DivisionFormScreenState();
}

class _DivisionFormScreenState extends State<DivisionFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  List<String> subjects = ["Maths", "Economics"];

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
        title: Text("Create New Divisioin"),
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
                hintText: "Faculty of Art",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            const Text("Code *", style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(
              controller: _codeController,
              decoration: InputDecoration(
                hintText: "FOA",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            const Text("Subjects *",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8.0,
              children: subjects.map((subject) {
                return Chip(
                  label: Text(subject),
                  onDeleted: () {
                    setState(() {
                      subjects.remove(subject);
                    });
                  },
                );
              }).toList(),
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              hint: const Text("Add a subject"),
              onChanged: (value) {
                if (value != null && !subjects.contains(value)) {
                  setState(() {
                    subjects.add(value);
                  });
                }
              },
              items: ["Maths", "Economics", "Marketing", "Science"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
            ),
            const SizedBox(height: 10),
            const Text("Image of the Division",
                style: TextStyle(fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload, size: 40, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text(
                      "Drag & Drop or Choose file to upload",
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: double.infinity, // Make the button take full width
                child: ElevatedButton(
                  onPressed: () {
                    // Handle form submission
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
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
