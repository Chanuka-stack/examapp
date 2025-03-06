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

  List<String> students = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create New Exam")),
      body: Stepper(
        type: StepperType.vertical,
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
            title: "Basic",
            content: _buildBasicForm(),
            isActive: _currentStep >= 0,
          ),
          _buildStep(
            title: "Students",
            content: _buildStudentsForm(),
            isActive: _currentStep >= 1,
          ),
          _buildStep(
            title: "Guidelines",
            content: _buildGuidelinesForm(),
            isActive: _currentStep >= 2,
          ),
          _buildStep(
            title: "Questions",
            content: _buildQuestionsForm(),
            isActive: _currentStep >= 3,
          ),
        ],
      ),
    );
  }

  Step _buildStep(
      {required String title,
      required Widget content,
      required bool isActive}) {
    return Step(
      title: Column(
        children: [
          Text(title, textAlign: TextAlign.center),
        ],
      ),
      content: content,
      isActive: isActive,
    );
  }

  Widget _buildBasicForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField("Name", _nameController),
        _buildDropdown("Division", ["Faculty of Management (FOM)"]),
        _buildDropdown("Subject", ["Economics"]),
        _buildDatePicker("Exam Date", _examDateController),
        _buildTimePicker("Start Time", _startTimeController),
        _buildTimePicker("End Time", _endTimeController),
        _buildButtons(),
      ],
    );
  }

  Widget _buildStudentsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          hint: const Text("Add a subject"),
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
        _buildTextField("Number of Section", _nameController),
        _buildTextField("Total Marks", _nameController),
        _buildTextField("Exam Guidelines", _nameController),
        _buildButtons(),
      ],
    );
  }

  Widget _buildQuestionsForm() {
    return Column(
      children: [
        Text("Add questions here..."),
        _buildButtons(),
      ],
    );
  }

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

  Widget _buildDropdown(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
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
        onChanged: (newValue) {},
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
        SizedBox(
          width: double.infinity, // Make the button take full width
          child: FilledButton(
            onPressed: () {
              if (_currentStep < 3) {
                setState(() {
                  _currentStep++;
                });
              }
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4), // Small border radius
              ),
            ),
            child: const Text("Next"),
          ),
        ),
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
}
