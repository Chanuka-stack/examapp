import 'dart:math';

import 'package:app1/data/examiner.dart';
import 'package:app1/services/auth_services.dart';
import 'package:flutter/material.dart';

class ExaminerFormScreen extends StatefulWidget {
  @override
  _ExaminerFormScreenState createState() => _ExaminerFormScreenState();
}

class _ExaminerFormScreenState extends State<ExaminerFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String? _selectedDivision;

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
        body: SafeArea(
            child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text("ID *",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextFormField(
                    controller: _idController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an ID';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text("Division *",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text("Select a Division"),
                    value: _selectedDivision,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a division';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedDivision = value;
                        });
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
                    controller: _emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email address';
                      }
                      // Basic email validation
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text("Contact Number *",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextFormField(
                    controller: _contactController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a contact number';
                      }
                      return null;
                    },
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
                        onPressed: () async {
                          print('onPressed');
                          // Validate form befor
                          //e submission
                          if (_formKey.currentState!.validate()) {
                            String name = _nameController.text;
                            String examinerId = _idController.text;
                            String email = _emailController.text;
                            String contactNumber = _contactController.text;
                            String division =
                                _selectedDivision ?? 'No Division';
                            // Handle form submission
                            const String chars =
                                'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()';
                            Random random = Random();
                            String password = List.generate(
                                8,
                                (index) =>
                                    chars[random.nextInt(chars.length)]).join();
                            AuthService().signupExaminer(
                                email: email,
                                password: password,
                                name: name,
                                examinerId: examinerId,
                                division: division,
                                contactNumber: contactNumber,
                                context: context);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Examiner is Registered Successfully!')),
                          );
                          await Future.delayed(const Duration(seconds: 2));
                          Navigator.pop(context);
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
          ),
        )));
  }
}
