import 'package:flutter/material.dart';
import 'components/audio_button.dart';

class StudentFormScreen extends StatefulWidget {
  @override
  _StudentFormScreenState createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

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
        title: Text("Create New Student"),
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Name *",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                const Text("ID ",
                    style: TextStyle(fontWeight: FontWeight.bold)),
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
                  controller:
                      _emailController, // Fixed: using proper controller
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                const Text("Contact Number *",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  controller:
                      _contactController, // Fixed: using proper controller
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                const Text("Record Your Index Number *",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  "Speak clearly and state your index number",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Center(
                  child: AudioRecordButton(),
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

                // Add some extra padding at the bottom to ensure the last widget isn't
                // hidden behind the keyboard when scrolled all the way down
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
