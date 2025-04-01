import 'dart:ffi';

import 'package:app1/data/exam.dart';
import 'package:flutter/material.dart';

class ExamFormScreen extends StatefulWidget {
  @override
  _ExamFormScreenState createState() => _ExamFormScreenState();
}

class _ExamFormScreenState extends State<ExamFormScreen> {
  int _currentStep = 0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _examDateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _sectionCountController = TextEditingController();
  final TextEditingController _totalMarksController = TextEditingController();
  final TextEditingController _examGuidelinesController =
      TextEditingController();

  ExamFirebaseService examFirebaseService = ExamFirebaseService();

  // Added for questions section
  List<Map<String, dynamic>> sections = [];
  String fileContent = '';
  TextEditingController fileContentController = TextEditingController();

  String _selectedDivision = "Faculty of Management (FOM)";
  String _selectedSubject = "Economics";
  List<String> students = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create New Exam")),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 3) {
            setState(() {
              _currentStep++;
            });
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep--;
            });
          }
        },
        steps: [
          _buildStep(
            title: "",
            content: _buildBasicForm(),
            isActive: _currentStep >= 0,
          ),
          _buildStep(
            title: "",
            content: _buildStudentsForm(),
            isActive: _currentStep >= 1,
          ),
          _buildStep(
            title: "",
            content: _buildGuidelinesForm(),
            isActive: _currentStep >= 2,
          ),
          _buildStep(
            title: "",
            content: _buildQuestionsForm(),
            isActive: _currentStep >= 3,
          ),
        ],
      ),
    );
  }

  Step _buildStep({
    required String title,
    required Widget content,
    required bool isActive,
  }) {
    return Step(
      title: Column(
        mainAxisSize: MainAxisSize.min, // Minimize the column size
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14), // Adjust font size if needed
          ),
          SizedBox(height: 4), // Add some spacing between title and number
        ],
      ),
      content: content,
      isActive: isActive,
    );
  }

  Widget _buildBasicForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Basic',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
        _buildTextField("Name", _nameController),
        _buildDropdown(
            "Division",
            [
              "Faculty of Management (FOM)",
              "Faculty of Science",
              "Faculty of Arts"
            ],
            _selectedDivision, (value) {
          setState(() {
            _selectedDivision = value!;
          });
        }),
        _buildDropdown(
            "Subject",
            ["Economics", "Mathematics", "History", "Computer Science"],
            _selectedSubject, (value) {
          setState(() {
            _selectedSubject = value!;
          });
        }),
        _buildDatePicker("Exam Date", _examDateController),
        _buildTimePicker("Start Time", _startTimeController),
        _buildTimePicker("End Time", _endTimeController),
        _buildButtons(),
      ],
    );
  }

  Widget _buildStudentsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Students',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
        Wrap(
          spacing: 8.0,
          children: students.map((subject) {
            return Chip(
              label: Text(subject),
              onDeleted: () {
                setState(() {
                  students.remove(subject);
                });
              },
            );
          }).toList(),
        ),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          hint: const Text("Add Students"),
          onChanged: (value) {
            if (value != null && !students.contains(value)) {
              setState(() {
                students.add(value);
              });
            }
          },
          items: [
            "HS/2020/0012",
            "HS/2020/0045",
            "HS/2020/0712",
            "HS/2020/4012"
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        ),
        _buildButtons(),
      ],
    );
  }

  Widget _buildGuidelinesForm() {
    return Column(
      children: [
        Text(
          'Guidelines',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
        _buildTextField("Number of Section", _sectionCountController),
        _buildTextField("Total Marks", _totalMarksController),
        _buildTextField("Exam Guidelines", _examGuidelinesController),
        _buildButtons(),
      ],
    );
  }

  // New function to add a subquestion
  void _addNewQuestion(int sectionIndex) {
    setState(() {
      int questionCount = sections[sectionIndex]['questions'].length;
      sections[sectionIndex]['questions'].add({
        'title': 'QUESTION ${(questionCount + 1).toString().padLeft(2, '0')}',
        'subQuestions': [],
      });
    });
  }

  void _addNewSubquestion(int sectionIndex, int questionIndex) {
    setState(() {
      sections[sectionIndex]['questions'][questionIndex]['subQuestions'].add({
        'text': 'New Subquestion',
        'marks': 0,
      });
    });
  }

  Widget _buildQuestionsForm() {
    // Create a list to hold all the sections
    List<Widget> sectionWidgets = [
      Text(
        'Questions',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          letterSpacing: 0.5,
        ),
      )
    ];
    int sectionCount = int.tryParse(_sectionCountController.text) ?? 0;

    // Initialize the sections list if it's empty or has wrong number of sections
    if (sections.length != sectionCount) {
      _initializeSections(sectionCount);
    }

    // Loop through each section in the sections list
    for (int sectionIndex = 0; sectionIndex < sections.length; sectionIndex++) {
      var section = sections[sectionIndex];

      sectionWidgets.add(Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: ExpansionTile(
          title: Text(section['title']),
          initiallyExpanded: true,
          children: [
            // Button to add a new question to this section
            Center(
              child: FilledButton(
                onPressed: () => _addNewQuestion(sectionIndex),
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text("Add New Question"),
              ),
            ),
            const SizedBox(height: 16),

            // Questions list for this section
            ...section['questions'].asMap().entries.map((entry) {
              int questionIndex = entry.key;
              var question = entry.value;

              return ExpansionTile(
                title: Text(question["title"]),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      initialValue: question["title"],
                      decoration: InputDecoration(
                        labelText: "Question Text",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            _addNewSubquestion(sectionIndex, questionIndex),
                        child: Text("Add Subquestion"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            sections[sectionIndex]['questions']
                                .removeAt(questionIndex);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade100,
                          foregroundColor: Colors.red.shade900,
                        ),
                        child: Text("Delete Question"),
                      ),
                    ],
                  ),

                  // Subquestions for this question
                  ...question["subQuestions"]
                      .asMap()
                      .entries
                      .map<Widget>((subEntry) {
                    int subIndex = subEntry.key;
                    var subQuestion = subEntry.value;

                    return ListTile(
                      title: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          children: [
                            TextFormField(
                              initialValue: subQuestion["text"],
                              decoration: InputDecoration(
                                labelText: "Subquestion ${subIndex + 1}",
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  sections[sectionIndex]['questions']
                                          [questionIndex]["subQuestions"]
                                      [subIndex]["text"] = value;
                                });
                              },
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              initialValue: subQuestion["marks"].toString(),
                              decoration: InputDecoration(
                                labelText: "Marks",
                                border: OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      sections[sectionIndex]['questions']
                                              [questionIndex]["subQuestions"]
                                          .removeAt(subIndex);
                                    });
                                  },
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  sections[sectionIndex]['questions']
                                              [questionIndex]["subQuestions"]
                                          [subIndex]["marks"] =
                                      int.tryParse(value) ?? 0;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          ],
        ),
      ));
    }
    sectionWidgets.add(_buildQuestionButtons());
    // Return all the sections in a column
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sectionWidgets,
    );
  }

  void _initializeSections(int count) {
    setState(() {
      // Create a new list with the desired number of sections
      sections = List.generate(
          count,
          (index) => {
                'title': 'SECTION ${(index + 1).toString().padLeft(2, '0')}',
                'questions': [],
              });
    });
  }
// Helper method for adding new questions

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String currentValue,
      Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        value: currentValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDatePicker(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(),
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          );
          if (pickedDate != null) {
            setState(() {
              controller.text =
                  "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
            });
          }
        },
      ),
    );
  }

  Widget _buildTimePicker(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: Icon(Icons.access_time),
          border: OutlineInputBorder(),
        ),
        onTap: () async {
          TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (pickedTime != null) {
            setState(() {
              controller.text = pickedTime.format(context);
            });
          }
        },
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        SizedBox(height: 20),
        SizedBox(height: 20),
        SizedBox(
          width: double.infinity, // Make the button take full width
          child: OutlinedButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4), // Small border radius
              ),
            ),
            child: Text("Save as Draft"),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionButtons() {
    return Column(
      children: [
        SizedBox(height: 20),
        SizedBox(
          width: double.infinity, // Make the button take full width
          child: OutlinedButton(
            onPressed: () {
              String name = _nameController.text;
              String examDate = _examDateController.text;
              String startTime = _startTimeController.text;
              String endTime = _endTimeController.text;
              int sectionCount =
                  int.tryParse(_sectionCountController.text) ?? 0;
              int totalMarks = int.tryParse(_totalMarksController.text) ?? 0;
              String guidelines = _examGuidelinesController.text;

              // Call Firebase service
              examFirebaseService
                  .createExam(
                name: name,
                division: _selectedDivision,
                subject: _selectedSubject,
                examDate: examDate,
                startTime: startTime,
                endTime: endTime,
                studentIds: students,
                sections: sectionCount,
                totalMarks: totalMarks,
                guidelines: guidelines,
                // Replace with actual user ID
              )
                  .then((examId) {
                // Save the questions
                examFirebaseService.saveExamQuestions(
                  examId: examId,
                  sections: sections,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Exam saved as draft")),
                );
              });
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4), // Small border radius
              ),
            ),
            child: Text("Save as Draft"),
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          width: double.infinity, // Make the button take full width
          child: FilledButton(
            onPressed: () {
              String name = _nameController.text;
              String examDate = _examDateController.text;
              String startTime = _startTimeController.text;
              String endTime = _endTimeController.text;
              int sectionCount =
                  int.tryParse(_sectionCountController.text) ?? 0;
              int totalMarks = int.tryParse(_totalMarksController.text) ?? 0;
              String guidelines = _examGuidelinesController.text;

              examFirebaseService
                  .createExam(
                name: name,
                division: _selectedDivision,
                subject: _selectedSubject,
                examDate: examDate,
                startTime: startTime,
                endTime: endTime,
                studentIds: students,
                sections: sectionCount,
                totalMarks: totalMarks,
                guidelines: guidelines,
              )
                  .then((examId) {
                // Save the questions
                examFirebaseService
                    .saveExamQuestions(
                  examId: examId,
                  sections: sections,
                )
                    .then((_) {
                  // Publish the exam
                  examFirebaseService.publishExam(examId);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Exam published successfully")),
                  );

                  // Navigate back after publishing
                  Navigator.pop(context);
                });
              });
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4), // Small border radius
              ),
            ),
            child: Text("Publish"),
          ),
        ),
      ],
    );
  }
}
