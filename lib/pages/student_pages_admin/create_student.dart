import 'dart:convert';
import 'dart:math';
import 'package:app1/data/division.dart';
import 'package:app1/data/student.dart';
import 'package:app1/services/auth_services.dart';
import 'package:emailjs/emailjs.dart';
import 'package:emailjs/emailjs.dart' as emailjs;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;
import '../components/audio_button.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:emailjs/emailjs.dart';

class StudentFormScreen extends StatefulWidget {
  @override
  _StudentFormScreenState createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  String? _selectedDivision;

  bool _isLoading = true;
  List<String> _divisions = [];

  Student student = Student();
  @override
  void initState() {
    super.initState();
    _fetchDivisions();
  }

  Future<void> _fetchDivisions() async {
    try {
      // Assuming you have a method to fetch divisions
      final divisions = await Division().getAllDivisionNames();
      setState(() {
        _divisions = divisions.cast<String>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load divisions: $e')),
      );
    }
  }

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
                      hintText: "Enter student name",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter student name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text("ID ",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextFormField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter student ID",
                    ),
                    // ID is optional as per original form
                  ),
                  const SizedBox(height: 10),
                  const Text("Division *",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  _isLoading
                      ? CircularProgressIndicator() // Show loading indicator
                      : DropdownButtonFormField<String>(
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
                          items: _divisions
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                        ),
                  const SizedBox(height: 10),
                  const Text("Email Address *",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter email address",
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email address';
                      }
                      if (!EmailValidator.validate(value)) {
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
                      hintText: "Enter contact number",
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a contact number';
                      }
                      // Basic phone number validation (you can enhance this as needed)
                      if (value.length < 10) {
                        return 'Please enter a valid contact number';
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
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _submitForm,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text("Create"),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    // Validate form
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text;
      String studentId = _codeController.text;
      String email = _emailController.text;
      String contactNumber = _contactController.text;
      String division = _selectedDivision ?? 'No Division';
      // Handle form submission
      const String chars =
          'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()';

      Random random = Random();
      String password =
          List.generate(8, (index) => chars[random.nextInt(chars.length)])
              .join();

      sendEmailDirectly(email, password);
      AuthService auth = AuthService();
      await auth.signupStudent(
          email: email,
          password: password,
          name: name,
          studentId: studentId,
          division: division,
          contactNumber: contactNumber,
          context: context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student is Registered Successfully!')),
      );
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context);
    }
  }

  /*Future<bool> sendEmail(dynamic templateParams) async {
    try {
      await emailjs.send(
        'service_1wp8wkj',
        'template_f1ghq3i',
        templateParams,
        const emailjs.Options(
          publicKey: 'o2LIoEIuHTqkuhDVM',
        ),
      );
      print('SUCCESS!');
      return true;
    } catch (error) {
      if (error is emailjs.EmailJSResponseStatus) {
        print('ERROR... ${error.status}: ${error.text}');
      }
      print(error.toString());
      return false;
    }
  }*/

  Future<bool> sendEmailDirectly(String email, String password) async {
    const serviceId = 'service_1wp8wkj';
    const templateId = 'template_2lmitku';
    const userId = 'o2LIoEIuHTqkuhDVM';

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    final templateParams = {
      'subject': 'Your Login Credentials',
      'from_name': 'Admin',
      'message': '''
Your login credentials are as follows:

Email: $email
Password: $password

Please change your password after first login.
''',
      'email': email,
    };

    final response = await http.post(
      url,
      headers: {
        'origin': 'http://localhost', // Required by EmailJS
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params': templateParams,
      }),
    );

    if (response.statusCode == 200) {
      print('Email sent successfully!');
      return true;
    } else {
      print('Failed with status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    super.dispose();
  }
}
