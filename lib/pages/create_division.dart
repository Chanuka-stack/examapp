import 'dart:io';
import 'package:app1/data/division.dart';
import 'package:flutter/material.dart';
import '../services/image_picker_service.dart'; // Update with your actual import path

class DivisionFormScreen extends StatefulWidget {
  @override
  _DivisionFormScreenState createState() => _DivisionFormScreenState();
}

class _DivisionFormScreenState extends State<DivisionFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  List<String> subjects = ["Maths", "Economics"];
  File? _selectedImage;
  final ImagePickerService _imagePickerService = ImagePickerService();
  Division division = Division();

  @override
  void initState() {
    super.initState();
    // Check for lost data when app restarts
    _checkForLostData();
  }

  // Recover lost data if app was killed while picking
  Future<void> _checkForLostData() async {
    final List<File> recoveredFiles =
        await _imagePickerService.retrieveLostData();
    if (recoveredFiles.isNotEmpty) {
      setState(() {
        _selectedImage = recoveredFiles.first;
      });
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
        title: Text("Create New Division"),
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
      body: SingleChildScrollView(
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
                  hintText: "Faculty of Art",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              const Text("Code *",
                  style: TextStyle(fontWeight: FontWeight.bold)),
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
                onTap: () async {
                  final File? image =
                      await _imagePickerService.showImageSourceDialog(
                    context,
                    maxWidth: 800,
                    maxHeight: 800,
                    imageQuality: 85,
                  );

                  if (image != null) {
                    setState(() {
                      _selectedImage = image;
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImage!,
                            width: double.infinity,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload,
                                size: 40, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text(
                              "Tap to upload image",
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                ),
              ),
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextButton.icon(
                    icon: Icon(Icons.delete, color: Colors.red),
                    label: Text("Remove image",
                        style: TextStyle(color: Colors.red)),
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                  ),
                ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        // Show loading indicator or disable button while processing
                        // You could add a loading state here if needed

                        await Division().createDivision(_nameController.text,
                            _codeController.text, subjects, _selectedImage);

                        // Navigate back to divisions page
                        Navigator.pop(context);

                        // Show success message after navigation
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Division created successfully"),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } catch (e) {
                        // Show error message if creation fails
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error creating division: $e"),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
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
    );
  }
}
